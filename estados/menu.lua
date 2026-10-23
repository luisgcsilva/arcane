local jogo = require("jogo")
local jogador = require("jogador")
local recordes = require("recordes")
local savegame = require("savegame")
local registo = require("registo")
local ui = require("ui")
local fontes = require("fontes")

local menu = {}

local opcoes, acoes, indice, aviso
local confirmarNovo -- true quando espera confirmacao para apagar a gravacao
local DEV = false -- poe true para ver a Simulacao no menu
local ESCALA = 3 -- cada pixel do desenho vira 3 no ecra
local LARGURA_BOTAO = 300
local BOTAO_X = (640 - LARGURA_BOTAO) / 2

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
    table.insert(opcoes, "Histórico")
    table.insert(acoes, "historico")
    if DEV then
        table.insert(opcoes, "Simulação")
        table.insert(acoes, "simulacao")
    end
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
                aviso = "Gravação inválida. Escolhe Novo jogo."
            end
        elseif escolha == "novo" then
            if savegame.existe() and not confirmarNovo then
                confirmarNovo = true
                aviso = "Apagar a partida gravada? A outra vez confirma."
            else
                registo.add("=== Novo Jogo ===")
                jogador.reiniciar()
                jogo.mudar("classes")
            end
        elseif escolha == "historico" then
            jogo.mudar("historico")
        elseif escolha == "simulacao" then
            jogo.mudar("simulacao")
        else
            love.event.quit()
        end
    end
end

function menu.desenhar()
    local normal = love.graphics.getFont()
    love.graphics.setColor(1, 1, 1)

    if ui.disponivel() then
        -- titulo numa faixa
        ui.faixa(180, 20, 280, 5)
        love.graphics.setFont(fontes.titulo)
        love.graphics.printf("ARCANE", 180, 20 + (13 * 5 - fontes.titulo:getHeight()) / 2, 280, "center")
        love.graphics.setFont(normal)

        for i, texto in ipairs(opcoes) do
            local y = 105 + (i - 1) * 44
            local sel = (i == indice)
            ui.botao(sel and "sel" or "normal", BOTAO_X, y, LARGURA_BOTAO, ESCALA)

            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(texto, BOTAO_X, y + (13 * ESCALA - normal:getHeight()) / 2, LARGURA_BOTAO, "center")

            if sel then
                ui.cursor(BOTAO_X - 11 * ESCALA - 10, y + (13 * ESCALA - 8 * ESCALA) / 2, ESCALA)
            end
        end
    else
        -- aspeto antigo (plano B)
        love.graphics.print("ARCANE", 270, 80)
        for i, texto in ipairs(opcoes) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(prefixo .. texto, 250, 100 + i * 36)
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Melhor sala: " .. recordes.dados.melhor_sala, 230, 340)
    love.graphics.print("Vitórias: " .. recordes.dados.vitorias, 230, 364)
    love.graphics.print(aviso, 20, 400)
end

return menu
