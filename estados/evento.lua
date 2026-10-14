local jogo = require("jogo")
local jogador = require("jogador")
local eventos = require("eventos")
local salas = require("salas")
local savegame = require("savegame")

local evento = {}

local ev -- o evento desta sala
local indice
local aviso
local feito -- true depois de escolheres: so falta carregar A

local ROXO = {0.75, 0.5, 1}

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

    local n = #ev.opcoes
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
        local mensagem, recusado = ev.opcoes[indice].efeito()
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
    love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)

    love.graphics.printf(ev.texto, 20, 100, 600)

    if not feito then
        for i, op in ipairs(ev.opcoes) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(prefixo .. op.texto, 20, 200 + (i - 1) * 36)
        end
    end

    love.graphics.printf(aviso, 20, 370, 600)
    love.graphics.print(feito and "A seguir  X pocoes  SELECT mochila" or "A escolher  X pocoes  SELECT mochila", 20,
        440)
end

return evento
