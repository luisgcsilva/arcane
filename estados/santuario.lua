local jogo = require("jogo")
local jogador = require("jogador")
local bencoes = require("bencoes")
local salas = require("salas")
local savegame = require("savegame")
local registo = require("registo")
local ui = require("ui")
local sprites = require("sprites")

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
    if not jogador.ofertaBencoes then
        jogador.ofertaBencoes = bencoes.sortearOferta(bencoes.OFERTA)
    end
    oferta = {}
    for _, id in ipairs(jogador.ofertaBencoes) do
        table.insert(oferta, bencoes.porId(id))
    end
    indice = 1
    aviso = ""
    corAviso = {1, 1, 1}
    feito = false
    registo.add("  [santuario] " .. table.concat(jogador.ofertaBencoes, ", "))
    savegame.gravar()
end

-- A gravacao passa a apontar para as portas seguintes
local function concluir(mensagem)
    aviso = mensagem
    corAviso = VERDE
    jogador.especial = nil
    jogador.ofertaBencoes = nil
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
    love.graphics.print("O Santuário", 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)
    -- love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)
    ui.moedas(420, 20, jogador.moedas)

    love.graphics.printf("Uma luz suave enche a sala. Podes pedir uma benção, mas tudo tem um preço.", 20, 100, 340)

    if not feito then
        local altura = love.graphics.getFont():getHeight()
        for i, b in ipairs(oferta) do
            local y = 176 + (i - 1) * 40
            if i == indice then
                ui.cursorLinha(20, y + (32 - altura) / 2, altura)
            end
            ui.imagem(bencoes.caminhoIcone(b), 56, y, 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print({b.cor, b.nome}, 96, y + (32 - altura) / 2)
        end
        local ySair = 176 + #oferta * 40
        if indice > #oferta then
            ui.cursorLinha(20, ySair + (32 - altura) / 2, altura)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Sair sem rezar", 56, ySair + (32 - altura) / 2)

        local b = oferta[indice]
        if b then
            ui.detalhe(370, 100, 260, 272, bencoes.caminhoIcone(b), b.cor, {b.cor, b.nome}, b.descricao)
            local tipo, valor = bencoes.custoDe(b, jogador)
            local pode = bencoes.podePagar(b, jogador)
            if tipo == "vida" then
                love.graphics.printf({pode and {1, 1, 1} or VERMELHO, "Custa " .. valor .. " de vida"}, 380, 336, 240,
                    "center")
            else
                ui.linhaMoedas(505, "Custa ", {1, 1, 1}, valor, 2, 330, not pode)
            end
        end
    end

    if type(aviso) == "table" then
        love.graphics.printf(aviso, 20, 380, 600)
    else
        love.graphics.printf({corAviso, aviso}, 20, 380, 600)
    end
    love.graphics.setColor(1, 1, 1)
    if feito then
        sprites.ajuda({{"A", "seguir"}, {"X", "poções"}, {"SELECT", "mochila"}}, 20, 440)
    else
        sprites.ajuda({{"A", "escolher"}, {"X", "poções"}, {"SELECT", "mochila"}}, 20, 440)
    end
end

return santuario
