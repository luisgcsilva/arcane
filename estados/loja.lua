local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local mercador = require("mercador")
local savegame = require("savegame")
local registo = require("registo")

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

-- Cor do preco: vermelho se nao chegas ao dinheiro, a cor normal se chegas
local function corPreco(e, normal)
    if jogador.moedas < e.preco then
        return VERMELHO
    end
    return normal
end

-- Acrescenta o preco, com a sua cor, ao fim de uma tabela de texto colorido
local function comPreco(t, e, normal)
    table.insert(t, corPreco(e, normal))
    table.insert(t, " - " .. e.preco .. "m")
    return t
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
            aviso = "Esse ja nao esta disponivel."
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
    local corMoedas = (brilho > 0) and {0.4, 1, 0.4} or DOURADO
    love.graphics.print({corMoedas, "Moedas: " .. jogador.moedas}, 400, 20)

    for i, e in ipairs(mercador.stock) do
        local prefixo = (i == indice) and "> " or "  "
        local y = 50 + (i - 1) * 22

        if e.vendido then
            love.graphics.print({CINZA, prefixo .. mercador.nomeDe(e) .. " (esgotado)"}, 20, y)
        elseif e.tipo == "item" then
            local atributo = (e.item.tipo == "arma") and "ataque" or "defesa"
            love.graphics.print(
                comPreco(loot.nomeColorido(e.item, prefixo, " +" .. e.item.bonus .. " " .. atributo), e, {1, 1, 1}), 20,
                y)
        elseif e.tipo == "reliquia" then
            love.graphics.print(comPreco(cores.nome(e.reliquia, prefixo, " (reliquia)"), e, {1, 1, 1}), 20, y)
        elseif e.tipo == "forja" then
            local item = jogador[e.slot]
            if not item then
                love.graphics.print({CINZA, prefixo .. mercador.nomeDe(e) .. " (nada equipado)"}, 20, y)
            elseif jogador.forja[e.slot] >= mercador.MAX_FORJA[e.slot] then
                love.graphics.print({CINZA, prefixo .. mercador.nomeDe(e) .. " (no maximo)"}, 20, y)
            else
                local laranja = {1, 0.6, 0.3}
                local nivel = jogador.forja[e.slot]
                love.graphics.print(comPreco({laranja,
                                              prefixo .. mercador.nomeDe(e) .. " (+" .. nivel .. " -> +" .. (nivel + 1) ..
                    ")"}, e, laranja), 20, y)
            end
        elseif e.tipo == "treino" then
            local t = mercador.TREINO[e.atributo]
            local verde = {0.5, 0.9, 0.5}
            love.graphics.print(comPreco({verde,
                                          prefixo .. t.nome .. " (+" .. t.ganho .. " " .. t.texto .. ", x" ..
                jogador.treino[e.atributo] .. ")"}, e, verde), 20, y)
        else
            love.graphics.print(comPreco(cores.nome(e.pocao, prefixo, " (+" .. jogador.curaDe(e.pocao) .. " vida)"), e,
                {1, 1, 1}), 20, y)
        end
    end
    local sel = mercador.stock[indice]
    if sel and sel.tipo == "reliquia" and not sel.vendido then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(sel.reliquia.descricao, 20, 360, 600)
    end
    if sel and sel.tipo == "forja" then
        local item = jogador[sel.slot]
        if item then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(item.nome .. " " .. jogador.textoBonus(item), 20, 360, 600)
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf({corAviso, aviso}, 20, 390, 600)
    love.graphics.print(pendente and "A confirmar  outra tecla cancela" or "A comprar  SELECT inventario  B sair", 20,
        440)
end

return loja
