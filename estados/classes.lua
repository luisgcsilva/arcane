local jogo = require("jogo")
local jogador = require("jogador")
local classes = require("classes")
local cores = require("cores")
local registo = require("registo")
local sprites = require("sprites")
local ui = require("ui")
local fontes = require("fontes")

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

    -- lista: a mao marca a selecionada (se nao houver imagem, volta ao ">")
    local altura = love.graphics.getFont():getHeight()
    for i, c in ipairs(classes.lista) do
        local y = 80 + (i - 1) * 36
        love.graphics.print(cores.nome(c, ""), 60, y)
        if i == indice and not ui.cursor(20, y + (altura - 16) / 2, 2) then
            love.graphics.print(">", 30, y)
        end
    end

    local c = classes.lista[indice]

    -- sombra e sprite da classe selecionada
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.ellipse("fill", 500, 182, 50, 9)
    sprites.desenhar(sprites.caminhoClasse(c.id), 500, 132, 5)

    -- painel com a descricao e os numeros
    ui.painel("ouro", 10, 196, 620, 212, 2, ui.FUNDO)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(c.descricao, 36, 216, 568)
    love.graphics.print("Vida " .. c.vida .. "   Ataque " .. c.ataque .. "   Defesa " .. c.defesa, 36, 296)
    love.graphics.print("Por nivel: +" .. c.vidaNivel .. " vida, +" .. c.ataqueNivel .. " ataque", 36, 328)
    love.graphics.printf(c.perk, 36, 360, 568)

    sprites.ajuda({{"A", "escolher"}, {"B", "voltar"}}, 20, 440)
end

return estado
