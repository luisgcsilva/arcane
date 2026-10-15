local jogo = require("jogo")
local jogador = require("jogador")
local recordes = require("recordes")
local savegame = require("savegame")
local registo = require("registo")

local menu = {}

local opcoes, acoes, indice, aviso
local confirmarNovo -- true quando espera confirmacao para apagar a gravacao

function menu.entrar()
    opcoes, acoes = {}, {}
    if savegame.existe() then
        local sala = savegame.resumo()
        local texto = sala and ("Continuar (sala " .. sala .. ")") or "Continuar"
        table.insert(opcoes, texto)
        table.insert(acoes, "continuar")
    end
    table.insert(opcoes, "Novo jogo")
    table.insert(acoes, "novo")
    table.insert(opcoes, "Sair")
    table.insert(acoes, "sair")
    indice = 1
    aviso = ""
    confirmarNovo = false
end

function menu.acao(a)
    if a ~= "confirmar" then
        confirmarNovo = false
    end

    if a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = #opcoes
        end
        aviso = ""
    elseif a == "baixo" then
        indice = indice + 1
        if indice > #opcoes then
            indice = 1
        end
        aviso = ""
    elseif a == "confirmar" then
        local escolha = acoes[indice]
        if escolha ~= "novo" then
            confirmarNovo = false
        end

        if escolha == "continuar" then
            local estado, a, b = savegame.carregar()
            if estado then
                registo.add("=== Continuar ===")
                jogo.mudar(estado, a, b)
            else
                aviso = "Gravacao invalida. Escolhe Novo jogo."
            end
        elseif escolha == "novo" then
            if savegame.existe() and not confirmarNovo then
                confirmarNovo = true
                aviso = "Apaga a partida gravada? A outra vez confirma."
            else
                registo.add("=== Novo Jogo ===")
                jogador.reiniciar()
                jogo.mudar("classes")
            end
        else
            love.event.quit()
        end
    end
end

function menu.desenhar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ARCANE", 270, 80)
    for i, texto in ipairs(opcoes) do
        local prefixo = (i == indice) and "> " or "  "
        love.graphics.print(prefixo .. texto, 250, 160 + i * 36)
    end
    love.graphics.print("Melhor sala: " .. recordes.dados.melhor_sala, 230, 300)
    love.graphics.print(aviso, 20, 400)
end

return menu
