local jogo = require("jogo")
local jogador = require("jogador")
local cores = require("cores")
local savegame = require("savegame")
local registo = require("registo")
local sprites = require("sprites")
local ui = require("ui")

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
            aviso = "Já tens a vida cheia."
        elseif pendente ~= indice then
            pendente = indice -- primeiro A: so pede confirmacao
            aviso = ""
        else
            pendente = nil
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
    love.graphics.print("POÇÕES", 20, 20)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)

    if #lista == 0 then
        love.graphics.print("(não tens poções)", 20, 140)
    else
        local altura = love.graphics.getFont():getHeight()
        for i, p in ipairs(lista) do
            local y = 140 + (i - 1) * 40
            if i == indice then
                ui.cursor(20, y + (altura - 18) / 2, 2)
            end
            if p.icone then
                ui.imagem("imagens/itens/fa" .. p.icone .. ".png", 56, y + (altura - 32) / 2, 2)
            end
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(cores.nome(p, "",
                " x" .. jogador.quantas(p.id) .. " (+" .. jogador.curaDe(p) .. " vida -> " .. jogador.vidaApos(p) .. "/" ..
                    jogador.vida_max .. ")"), 96, y)
        end
    end

    love.graphics.setColor(1, 1, 1)
    if pendente and lista[pendente] then
        local p = lista[pendente]
        local fonte = love.graphics.getFont()
        -- texto colorido, centrado na altura dos icones (32 px)
        love.graphics.print(cores.nome(p, "Beber ", "?"), 20, 440 + (32 - fonte:getHeight()) / 2)
        -- os icones comecam depois do texto
        local x = 20 + fonte:getWidth("Beber " .. p.nome .. "?") + 20
        sprites.ajuda({{"A", "confirmar"}, {"B", "cancelar"}}, x, 440)
    else
        sprites.ajuda({{"A", "continuar"}, {"B", "fechar"}}, 20, 440)
    end
    love.graphics.printf(aviso, 20, 390, 600)
end

return pocoes
