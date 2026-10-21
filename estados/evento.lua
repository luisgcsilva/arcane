local jogo = require("jogo")
local jogador = require("jogador")
local eventos = require("eventos")
local salas = require("salas")
local savegame = require("savegame")
local registo = require("registo")
local ui = require("ui")
local sprites = require("sprites")

local evento = {}

local ev -- o evento desta sala
local indice
local aviso
local feito -- true depois de escolheres: so falta carregar A

local ROXO = {0.75, 0.5, 1}

-- As opcoes podem ser uma lista fixa ou uma funcao que a calcula na hora
local function opcoesDe(ev)
    if type(ev.opcoes) == "function" then
        return ev.opcoes()
    end
    return ev.opcoes
end

function evento.entrar()
    jogador.especial = "evento"
    jogador.portas = nil
    jogador.inimigo = nil
    -- se vens de "Continuar", o evento ja esta sorteado e gravado
    if not jogador.eventoId then
        jogador.eventoId = eventos.sortear(jogador.sala).id
    end
    ev = eventos.porId(jogador.eventoId)
    indice = 1
    aviso = ""
    feito = false
    registo.add("  [evento] " .. ev.id)
    savegame.gravar()
end

-- A gravacao passa a apontar para as portas seguintes
local function concluir(mensagem)
    aviso = mensagem
    jogador.especial = nil
    jogador.eventoId = nil
    jogador.portas = salas.gerarPortas(jogador.sala + 1, "evento")
    savegame.gravar()
    feito = true
end

function evento.acao(a)
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

    local lista = opcoesDe(ev)
    local n = #lista
    if indice > n then
        indice = n
    end
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
        local mensagem, recusado = lista[indice].efeito()
        if recusado then
            aviso = mensagem -- nao gastou a escolha
        else
            concluir(mensagem)
        end
    end
end

function evento.desenhar()
    love.graphics.setColor(ROXO)
    love.graphics.print(ev.titulo, 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)
    ui.moedas(420, 20, jogador.moedas)
    -- love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)

    love.graphics.printf(ev.texto, 20, 100, 600)

    if not feito then
        local altura = love.graphics.getFont():getHeight()
        for i, op in ipairs(opcoesDe(ev)) do
            local y = 200 + (i - 1) * 36
            if i == indice then
                ui.cursorLinha(20, y, altura)
            end
            if op.colorido then
                love.graphics.print(op.colorido(""), 60, y)
            else
                local texto = (type(op.texto) == "function") and op.texto() or op.texto
                love.graphics.print(texto, 60, y)
            end
        end
    end

    love.graphics.printf(aviso, 20, 370, 600)
    if feito then
        sprites.ajuda({{"A", "seguir"}, {"X", "poções"}, {"SELECT", "mochila"}}, 20, 440)
    else
        sprites.ajuda({{"A", "escolher"}, {"X", "poções"}, {"SELECT", "mochila"}}, 20, 440)
    end
end

return evento
