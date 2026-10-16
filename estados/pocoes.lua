local jogo = require("jogo")
local jogador = require("jogador")
local cores = require("cores")
local savegame = require("savegame")
local registo = require("registo")

local pocoes = {}

local lista
local indice
local aviso
local pendente -- indice da pocao a espera de confirmacao

function pocoes.entrar()
    lista = jogador.pocoesDisponiveis()
    indice = 1
    aviso = ""
    pendente = nil
end

function pocoes.acao(a)
    if a == "cancelar" then
        if pendente then
            pendente = nil -- B com confirmacao aberta: so cancela
            aviso = ""
        else
            savegame.gravar()
            jogo.fechar()
        end
        return
    end

    if a ~= "confirmar" then
        pendente = nil
    end

    local n = #lista
    if n == 0 then
        return
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
        local p = lista[indice]
        if jogador.vida >= jogador.vida_max then
            aviso = "Ja tens a vida cheia."
        else
            local curado = jogador.usarPocao(p.id)
            aviso = "Bebes " .. p.nome .. " e recuperas " .. curado .. " de vida."
            -- a quantidade mudou: refazer a lista e manter o cursor valido
            lista = jogador.pocoesDisponiveis()
            indice = math.max(1, math.min(indice, #lista))
        end
    end
end

function pocoes.desenhar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("POCOES", 20, 20)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)

    if #lista == 0 then
        love.graphics.print("(nao tens pocoes)", 20, 140)
    else
        for i, p in ipairs(lista) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(cores.nome(p, prefixo,
                " x" .. jogador.quantas(p.id) .. " (+" .. jogador.curaDe(p) .. " vida -> " .. jogador.vidaApos(p) .. "/" ..
                    jogador.vida_max .. ")"), 20, 140 + (i - 1) * 32)
        end
    end

    love.graphics.print(aviso, 20, 400)
    love.graphics.print("A - beber   B - fechar", 20, 440)
end

return pocoes
