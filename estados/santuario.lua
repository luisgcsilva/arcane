local jogo = require("jogo")
local jogador = require("jogador")
local bencoes = require("bencoes")
local salas = require("salas")
local savegame = require("savegame")
local registo = require("registo")

local santuario = {}

local oferta -- as bencoes desta sala (tabelas)
local indice
local aviso
local corAviso
local feito -- true depois de escolheres: so falta carregar A

local CIANO = {0.6, 0.9, 1}
local CINZA = {0.6, 0.6, 0.6}
local VERMELHO = {1, 0.3, 0.3}
local VERDE = {0.4, 1, 0.4}

function santuario.entrar()
    jogador.especial = "santuario"
    jogador.portas = nil
    jogador.inimigo = nil
    -- se vens de "Continuar", a oferta ja esta sorteada e gravada
    if not jogador.ofertabencoes then
        jogador.ofertabencoes = bencoes.sortearOferta(bencoes.OFERTA)
    end
    oferta = {}
    for _, id in ipairs(jogador.ofertabencoes) do
        table.insert(oferta, bencoes.porId(id))
    end
    indice = 1
    aviso = ""
    corAviso = {1, 1, 1}
    feito = false
    registo.add("  [santuario] " .. table.concat(jogador.ofertabencoes, ", "))
    savegame.gravar()
end

-- A gravacao passa a apontar para as portas seguintes
local function concluir(mensagem)
    aviso = mensagem
    corAviso = VERDE
    jogador.especial = nil
    jogador.ofertabencoes = nil
    jogador.portas = salas.gerarPortas(jogador.sala + 1, "santuario")
    savegame.gravar()
    feito = true
end

function santuario.acao(a)
    if a == "inventario" then
        jogo.abrir("inventario")
        return
    end
    if a == "menu" then
        jogo.abrir("pocoes")
        return
    end

    if feito then
        if a == "confirmar" then
            jogo.mudar("portas", jogador.portas)
        end
        return
    end

    local n = #oferta + 1 -- a ultima opcao e "Sair sem rezar"
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
        if indice > #oferta then
            concluir("Segues caminho sem rezar.")
        else
            local ok, mensagem, colorida = bencoes.aplicar(oferta[indice], jogador)
            if ok then
                concluir(colorida or mensagem)
            else
                aviso = mensagem -- nao gastou a escolha
                corAviso = VERMELHO
            end
        end
    end
end

function santuario.desenhar()
    love.graphics.setColor(CIANO)
    love.graphics.print("O santuario", 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)
    love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)

    love.graphics.printf("Uma luz suave enche a sala. Podes pedir uma bencao, mas tudo tem um preco.", 20, 100, 600)

    if not feito then
        for i, b in ipairs(oferta) do
            local prefixo = (i == indice) and "> " or "  "
            local tipo, valor = bencoes.custoDe(b, jogador)
            local preco = (tipo == "vida") and (valor .. " de vida") or (valor .. " moedas")
            local corPreco = bencoes.podePagar(b, jogador) and CINZA or VERMELHO
            love.graphics.print({{1, 1, 1}, prefixo, b.cor, b.nome, corPreco, "  (" .. preco .. ")"}, 20,
                180 + (i - 1) * 36)
        end
        local prefixo = (indice > #oferta) and "> " or "  "
        love.graphics.print(prefixo .. "Sair sem rezar", 20, 180 + #oferta * 36)

        if oferta[indice] then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(oferta[indice].descricao, 20, 330, 600)
        end
    end

    if type(aviso) == "table" then
        love.graphics.printf(aviso, 20, 380, 600)
    else
        love.graphics.printf({corAviso, aviso}, 20, 380, 600)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(feito and "A seguir  X pocoes  SELECT mochila" or "A escolher  X pocoes  SELECT mochila", 20,
        440)
end

return santuario
