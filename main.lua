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
    -- na consola ha comando ligado: ignora setas (analogico)
    if love.joystick.getJoystickCount() > 0 then
        if tecla == "up" or tecla == "down" or tecla == "left" or tecla == "right" then
            return
        end
    end
    enviar(input.daTecla(tecla))
end

function love.joystickpressed(joystick, numero)
    enviar(input.daBotao(numero))
end

function love.draw()
    jogo.atual.desenhar()
end
