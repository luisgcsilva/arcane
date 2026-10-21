local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local mercador = require("mercador")
local savegame = require("savegame")
local registo = require("registo")
local ui = require("ui")
local reliquias = require("reliquias")
local sprites = require("sprites")

local loja = {}

local indice
local aviso
local pendente -- indice do item a espera de confirmacao (nil = nenhum)
local brilho = 0 -- segundos que faltam para as moedas deixarem de brilhar a verde

local DOURADO = {1, 0.85, 0.2}
local CINZA = {0.5, 0.5, 0.5}
local VERMELHO = {1, 0.3, 0.3}
local VERDE = {0.4, 1, 0.4}
local corAviso = {1, 1, 1} -- cor do texto do aviso
local LARANJA = cores.LARANJA
local MAO_X = 4 -- cursor (mao, escala 2: 22 x 26 px; balanca uns 3 px)
local ICONE_X = 34 -- icone de 16 px
local TEXTO_X = 58 -- texto da linha

-- Uma linha esta "a venda" se se pode comprar (a forja pode nao ter nada para afiar)
local function compravel(e)
    if e.vendido then
        return false
    end
    if e.tipo == "forja" then
        local item = jogador[e.slot]
        return item ~= nil and jogador.forja[e.slot] < mercador.MAX_FORJA[e.slot]
    end
    return true
end

-- Preco da linha, com a moeda, na coluna do meio. Moeda vermelha se nao chegas.
local function desenharPreco(e, y)
    if not compravel(e) then
        return
    end
    local altura = love.graphics.getFont():getHeight()
    ui.moedas(334, y + (altura - 16) / 2, e.preco, 1, jogador.moedas < e.preco)
end

-- Caminho do icone de uma linha da loja (nil se nao tiver)
local function caminhoIcone(e)
    if e.tipo == "item" then
        return loot.caminhoIcone(e.item)
    elseif e.tipo == "reliquia" then
        return reliquias.caminhoIcone(e.reliquia)
    elseif e.tipo == "forja" then
        local equipado = jogador[e.slot]
        return equipado and loot.caminhoIcone(equipado) or nil
    elseif e.pocao and e.pocao.icone then
        return "imagens/itens/fa" .. e.pocao.icone .. ".png"
    elseif e.tipo == "treino" then
        local t = mercador.TREINO[e.atributo]
        return t.icone and ("imagens/itens/fa" .. t.icone .. ".png") or nil
    end
end

local DET_X = 424
local DET_W = 206
local DET_CX = DET_X + DET_W / 2 -- centro da coluna

-- "rotulo [moeda] n" centrado na coluna do detalhe, a altura y
local function linhaMoedas(rotulo, corRotulo, n, escala, y, semDinheiro)
    local f = love.graphics.getFont()
    local lado = 16 * escala
    local largura = f:getWidth(rotulo) + lado + 6 + f:getWidth(tostring(n))
    local x0 = DET_CX - largura / 2
    local alto = math.max(lado, f:getHeight())
    love.graphics.setColor(corRotulo)
    love.graphics.print(rotulo, x0, y + (alto - f:getHeight()) / 2)
    ui.moedas(x0 + f:getWidth(rotulo), y + (alto - lado) / 2, n, escala, semDinheiro)
end

local function desenharDetalhe(e)
    ui.painel("ouro", DET_X, 44, DET_W, 340, 2, ui.FUNDO)

    -- cor da moldura do icone
    local cor
    if e.tipo == "item" then
        cor = loot.cores[e.item.raridade]
    elseif e.tipo == "reliquia" then
        cor = e.reliquia.cor
    elseif e.tipo == "forja" and jogador[e.slot] then
        cor = loot.cores[jogador[e.slot].raridade]
    elseif e.tipo == "pocao" then
        cor = e.pocao.cor
    end
    if cor then
        love.graphics.setColor(cor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", DET_CX - 34, 60, 68, 68)
        love.graphics.setLineWidth(1)
    end
    ui.imagem(caminhoIcone(e), DET_CX - 32, 62, 4, e.vendido and {0.4, 0.4, 0.4} or nil)

    local x, w = DET_X + 10, DET_W - 20
    love.graphics.setColor(1, 1, 1)
    if e.vendido then
        love.graphics.printf({CINZA, "Esgotado"}, x, 140, w, "center")
        return
    end

    if e.tipo == "item" then
        local atributo = (e.item.tipo == "arma") and "ataque" or "defesa"
        love.graphics.printf(loot.nomeColorido(e.item), x, 140, w, "center")
        love.graphics.printf("+" .. e.item.bonus .. " " .. atributo, x, 190, w, "center")
        love.graphics.printf({loot.cores[e.item.raridade], e.item.raridade}, x, 214, w, "center")
        love.graphics.printf((jogador.linhaDiferenca(e.item)), x, 240, w, "center")
    elseif e.tipo == "reliquia" then
        love.graphics.printf(cores.nome(e.reliquia), x, 140, w, "center")
        love.graphics.printf(e.reliquia.descricao, x, 190, w, "center")
    elseif e.tipo == "forja" then
        local item = jogador[e.slot]
        if not item then
            love.graphics.printf({CINZA, "Nada equipado"}, x, 140, w, "center")
        else
            local nivel = jogador.forja[e.slot]
            love.graphics.printf(loot.nomeColorido(item), x, 140, w, "center")
            love.graphics.printf(jogador.textoBonus(item), x, 190, w, "center")
            if nivel >= mercador.MAX_FORJA[e.slot] then
                love.graphics.printf({CINZA, "No máximo"}, x, 214, w, "center")
            else
                love.graphics.printf("Nível +" .. nivel .. " -> +" .. (nivel + 1), x, 214, w, "center")
            end
        end
    elseif e.tipo == "treino" then
        local t = mercador.TREINO[e.atributo]
        love.graphics.printf({{0.5, 0.9, 0.5}, t.nome}, x, 140, w, "center")
        love.graphics.printf("+" .. t.ganho .. " " .. t.texto, x, 190, w, "center")
        love.graphics.printf("Treinado x" .. jogador.treino[e.atributo], x, 240, w, "center")
    else
        love.graphics.printf(cores.nome(e.pocao), x, 140, w, "center")
        love.graphics.printf("+" .. jogador.curaDe(e.pocao) .. " vida", x, 190, w, "center")
        love.graphics.printf("Vida: " .. jogador.vida .. " -> " .. jogador.vidaApos(e.pocao), x, 214, w, "center")
    end

    -- "Custa" e quanto falta / sobra
    if compravel(e) then
        local semDinheiro = jogador.moedas < e.preco
        linhaMoedas("Custa ", {1, 1, 1}, e.preco, 2, 300, semDinheiro)
        if semDinheiro then
            linhaMoedas("Faltam ", VERMELHO, e.preco - jogador.moedas, 1, 340, true)
        else
            linhaMoedas("Ficas com ", CINZA, jogador.moedas - e.preco, 1, 340, false)
        end
    end
end

function loja.entrar()
    indice = 1
    aviso = ""
    pendente = nil
    brilho = 0
    corAviso = {1, 1, 1}
end

function loja.atualizar(dt)
    if brilho > 0 then
        brilho = brilho - dt
    end
end

function loja.acao(a)
    mercador.atualizar()
    if a == "cancelar" then
        if pendente then
            pendente = nil -- B com confirmacao aberta: so cancela a compra
            aviso = ""
        else
            jogo.fechar()
        end
        return
    elseif a == "inventario" then
        pendente = nil
        jogo.abrir("inventario") -- para vender
        return
    end

    -- qualquer coisa que nao seja A cancela a confirmacao
    if a ~= "confirmar" then
        pendente = nil
    end

    local n = #mercador.stock
    if a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
        aviso = ""
    elseif a == "baixo" then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
        aviso = ""
    elseif a == "confirmar" then
        local e = mercador.stock[indice]
        if e.vendido then
            aviso = "Esse já não está disponível."
            corAviso = VERMELHO
        elseif pendente ~= indice then
            -- primeiro A: pede confirmacao
            pendente = indice
            local nome = mercador.nomeDe(e)
            aviso = "Comprar " .. nome .. " por " .. e.preco .. "m? A para confirmar."
            corAviso = DOURADO
        else
            -- segundo A no mesmo item: compra
            pendente = nil
            local ok, mensagem, motivo = mercador.comprar(indice)
            aviso = mensagem
            if ok then
                corAviso = VERDE
                brilho = 0.5
                savegame.gravar()
            elseif motivo == "mochila" then
                corAviso = LARANJA
            else
                corAviso = VERMELHO
            end
        end
    end
end

function loja.desenhar()
    mercador.atualizar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("LOJA", 20, 20)
    ui.moedas(400, 20, jogador.moedas)

    local altura = love.graphics.getFont():getHeight()
    for i, e in ipairs(mercador.stock) do
        local y = 50 + (i - 1) * 22

        if i == indice then
            ui.cursor(MAO_X, y + (altura - 20) / 2, 2)
        end
        ui.imagem(caminhoIcone(e), ICONE_X, y + (altura - 20) / 2, 1, e.vendido and {0.4, 0.4, 0.4} or nil)

        local texto
        if e.vendido then
            texto = {CINZA, mercador.nomeDe(e) .. " (esgotado)"}
        elseif e.tipo == "item" then
            texto = loot.nomeColorido(e.item)
        elseif e.tipo == "reliquia" then
            texto = cores.nome(e.reliquia)
        elseif e.tipo == "forja" then
            if not jogador[e.slot] then
                texto = {CINZA, mercador.nomeDe(e) .. " (vazio)"}
            elseif not compravel(e) then
                texto = {CINZA, mercador.nomeDe(e) .. " (maximo)"}
            else
                texto = {{1, 0.6, 0.3}, mercador.nomeDe(e)}
            end
        elseif e.tipo == "treino" then
            texto = {{0.5, 0.9, 0.5}, mercador.TREINO[e.atributo].nome}
        else
            texto = cores.nome(e.pocao)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(texto, TEXTO_X, y)
        desenharPreco(e, y)
    end

    local sel = mercador.stock[indice]
    if sel then
        desenharDetalhe(sel)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf({corAviso, aviso}, 20, 390, 600)
    if pendente then
        sprites.ajuda({{"A", "confirmar"}, {"B", "cancela"}}, 20, 440)
    else
        sprites.ajuda({{"A", "comprar"}, {"SELECT", "inventário"}, {"B", "sair"}}, 20, 440)
    end
end

return loja
