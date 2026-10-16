local input = require("input")
local jogo = require("jogo")
local recordes = require("recordes")
local cores = require("cores")
local registo = require("registo")
local historico = require("historico")
local reliquias = require("reliquias")
local dificuldade = require("dificuldade")

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
jogo.registar("classes", require("estados.classes"))
jogo.registar("historico", require("estados.historico"))
jogo.registar("reliquia", require("estados.reliquia"))
jogo.registar("ajuda", require("estados.ajuda"))
jogo.registar("habilidade", require("estados.habilidade"))
jogo.registar("simulacao", require("estados.simulacao"))

local DEBUG = false

local function anotar(texto)
    table.insert(registo, 1, string.format("%.2f %s", love.timer.getTime() % 100, texto))
    registo[9] = nil
end

function love.load()
    love.graphics.setFont(love.graphics.newFont(20))
    recordes.carregar()
    registo.carregar()
    historico.carregar()
    for sala = 1, 100 do
        if dificuldade.eBoss(sala) then
            if #dificuldade.chefesDoBioma(sala) == 0 then
                print("AVISO: sala " .. sala .. " sem chefe")
            end
        elseif #dificuldade.candidatos(sala) == 0 then
            print("AVISO: sala " .. sala .. " sem inimigos possiveis")
        end
    end
    jogo.mudar("menu")
end

local function enviar(a)
    if not a or not jogo.atual.acao then
        return
    end

    if a == "pausa" then
        registo.alternar()
        return
    end
    if registo.visivel then
        registo.acao(a)
        return
    end

    if a == "gatilho_esq" then
        if jogo.atual == jogo.estados.ajuda then
            jogo.fechar()
        else
            jogo.abrir("ajuda")
        end
        return
    end

    jogo.atual.acao(a)
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
    registo.desenhar()
    if DEBUG then
        love.graphics.setColor(1, 1, 0.4)
        for i, linha in ipairs(registo) do
            love.graphics.print(linha, 440, 300 + (i - 1) * 20)
        end
        love.graphics.setColor(1, 1, 1)
    end
end
