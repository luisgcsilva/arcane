local jogo = require("jogo")
local jogador = require("jogador")
local classes = require("classes")
local cores = require("cores")
local registo = require("registo")

local estado = {}

local indice

function estado.entrar()
    indice = 1
end

function estado.acao(a)
    local n = #classes.lista
    if a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
    elseif a == "baixo" then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
    elseif a == "confirmar" then
        jogador.escolherClasse(classes.lista[indice].id)
        jogo.mudar("portas")
    elseif a == "cancelar" then
        jogo.mudar("menu")
    end
end

function estado.desenhar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ESCOLHE A TUA CLASSE", 20, 20)

    for i, c in ipairs(classes.lista) do
        local prefixo = (i == indice) and "> " or "  "
        love.graphics.print(cores.nome(c, prefixo), 20, 80 + (i - 1) * 36)
    end

    local c = classes.lista[indice]
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(c.descricao, 20, 210, 600)
    love.graphics.print("Vida " .. c.vida .. "   Ataque " .. c.ataque .. "   Defesa " .. c.defesa, 20, 290)
    love.graphics.print("Por nivel: +" .. c.vidaNivel .. " vida, +" .. c.ataqueNivel .. " ataque", 20, 322)
    love.graphics.print(c.perk, 20, 354)

    love.graphics.print("A escolher  B voltar", 20, 440)
end

return estado
