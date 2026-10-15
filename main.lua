local input = require("input")
local jogo = require("jogo")
local recordes = require("recordes")
local cores = require("cores")

jogo.registar("menu", require("estados.menu"))
jogo.registar("explorar", require("estados.explorar"))
jogo.registar("combate", require("estados.combate"))
jogo.registar("inventario", require("estados.inventario"))
jogo.registar("pocoes", require("estados.pocoes"))
jogo.registar("derrota", require("estados.derrota"))
jogo.registar("loja", require("estados.loja"))
jogo.registar("portas", require("estados.portas"))
jogo.registar("fogueira", require("estados.fogueira"))
jogo.registar("tesouro", require("estados.tesouro"))
jogo.registar("evento", require("estados.evento"))

local DEBUG = false
local registo = {}

local function anotar(texto)
    table.insert(registo, 1, string.format("%.2f %s", love.timer.getTime() % 100, texto))
    registo[9] = nil
end

function love.load()
    love.graphics.setFont(love.graphics.newFont(20))
    recordes.carregar()
    jogo.mudar("menu")
end

local function enviar(a)
    if a and jogo.atual.acao then
        jogo.atual.acao(a)
    end
end

function love.update(dt)
    if jogo.atual.atualizar then
        jogo.atual.atualizar(dt)
    end
end

function love.keypressed(tecla)
    if love.joystick.getJoystickCount() > 0 then
        return
    end
    enviar(input.daTecla(tecla))
end

function love.joystickpressed(joystick, numero)
    enviar(input.daBotao(numero))
end

function love.draw()
    jogo.atual.desenhar()
    if DEBUG then
        love.graphics.setColor(1, 1, 0.4)
        for i, linha in ipairs(registo) do
            love.graphics.print(linha, 440, 300 + (i - 1) * 20)
        end
        love.graphics.setColor(1, 1, 1)
    end
end
