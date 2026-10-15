local jogo = require("jogo")
local jogador = require("jogador")
local salas = require("salas")
local savegame = require("savegame")
local cores = require("cores")
local registo = require("registo")

local portas = {}

local lista -- ids das portas, por ordem
local indice
local fonteGrande

local DOURADO = {1, 0.85, 0.2}
local CINZA = {0.6, 0.6, 0.6}
local MADEIRA = {0.25, 0.2, 0.15}
local MADEIRA_CLARA = {0.45, 0.32, 0.18}

-- arg: uma lista (gravacao retomada) ou o tipo da sala de onde vens
function portas.entrar(arg)
    fonteGrande = fonteGrande or love.graphics.newFont(48)
    if type(arg) == "table" then
        lista = arg
    else
        lista = salas.gerarPortas(jogador.sala + 1, arg)
    end
    jogador.portas = lista
    registo.add(string.format("Sala %d: portas [%s]%s", jogador.sala + 1, table.concat(lista, ", "),
        type(arg) == "table" and " (retomadas)" or ""))
    jogador.inimigo = nil
    jogador.especial = nil
    jogador.eventoId = nil
    indice = 1
    savegame.gravar()
end

function portas.acao(a)
    local n = #lista
    if a == "esquerda" or a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
    elseif a == "direita" or a == "baixo" then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
    elseif a == "confirmar" then
        local tipo = lista[indice]
        registo.add("  Porta " .. indice .. " -> " .. tipo)
        jogador.portas = nil
        jogador.sala = jogador.sala + 1
        -- fogueira e tesouro tem estado proprio; o resto passa pelo explorar
        local destinos = {
            fogueira = "fogueira",
            tesouro = "tesouro",
            evento = "evento"
        }
        jogo.mudar(destinos[tipo] or "explorar", tipo)
    elseif a == "menu" then
        jogo.abrir("pocoes")
    elseif a == "inventario" then
        jogo.abrir("inventario")
    elseif a == "cancelar" then
        jogo.mudar("menu")
    end
end

function portas.desenhar()
    love.graphics.setColor(1, 1, 1)
    local titulo = (jogador.sala == 0) and "A entrada da masmorra" or ("Entrada da Proxima Sala " .. jogador.sala + 1)
    love.graphics.print(titulo, 20, 20)
    love.graphics.print({{1, 1, 1}, "Vida: ", cores.daVida(jogador.vida / jogador.vida_max),
                         jogador.vida .. "/" .. jogador.vida_max}, 20, 50)
    love.graphics.print({DOURADO, "Moedas: " .. jogador.moedas}, 420, 20)

    love.graphics.print(#lista == 1 and "Ha uma porta a frente." or "Que porta abres?", 20, 90)

    local n = #lista
    local L, A, ESPACO = 120, 180, 40
    local x0 = (640 - (n * L + (n - 1) * ESPACO)) / 2
    local fonteNormal = love.graphics.getFont()

    for i = 1, n do
        local x = x0 + (i - 1) * (L + ESPACO)
        local escolhida = (i == indice)

        love.graphics.setColor(escolhida and MADEIRA_CLARA or MADEIRA)
        love.graphics.rectangle("fill", x, 130, L, A)

        love.graphics.setColor(escolhida and DOURADO or CINZA)
        love.graphics.setLineWidth(escolhida and 4 or 2)
        love.graphics.rectangle("line", x, 130, L, A)

        love.graphics.setFont(fonteGrande)
        love.graphics.printf("?", x, 130 + A / 2 - 28, L, "center")
        love.graphics.setFont(fonteNormal)
        love.graphics.printf("Porta " .. i, x, 130 + A + 10, L, "center")
    end

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Esq/Dir escolher A abrir  L2 ajuda", 20, 440)
end

return portas
