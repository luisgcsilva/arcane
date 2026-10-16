local jogo = require("jogo")
local jogador = require("jogador")
local recordes = require("recordes")
local historico = require("historico")
local savegame = require("savegame")

local final = {}

local DOURADO = {1, 0.85, 0.2}
local opcoes = {"Continuar a aventura", "Terminar e guardar a vitoria"}

local destino, arg, indice, pendente

-- destino e arg: para onde irias a seguir (habilidade, reliquia ou portas)
function final.entrar(d, a)
    destino, arg = d, a
    indice = 1
    pendente = false
end

function final.acao(a)
    if a == "cima" or a == "baixo" then
        indice = (indice == 1) and 2 or 1
        pendente = false
    elseif a == "confirmar" then
        if indice == 1 then
            jogo.mudar(destino or "portas", arg)
        elseif not pendente then
            pendente = true -- terminar apaga a gravacao: pede confirmacao
        else
            savegame.apagar()
            local novo = recordes.registarFim(jogador.sala, jogador.stats.inimigos, true)
            historico.registar(novo, recordes.dados.partidas, true)
            jogo.mudar("menu")
        end
    else
        pendente = false
    end
end

function final.desenhar()
    local s = jogador.stats
    love.graphics.setColor(DOURADO)
    love.graphics.print("VITORIA!", 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("O Trono Eterno caiu. Chegaste a sala " .. jogador.sala .. ".", 20, 60)
    love.graphics.print("Classe: " .. (jogador.defClasse().nome or "Aventureiro") .. "   Nivel " .. jogador.nivel, 20,
        100)
    love.graphics.print("Inimigos vencidos: " .. s.inimigos .. "  (chefes: " .. s.chefes .. ")", 20, 130)
    love.graphics.print("Dano causado: " .. s.dano_causado .. "   Dano sofrido: " .. s.dano_sofrido, 20, 160)
    love.graphics.print("Pocoes usadas: " .. s.pocoes, 20, 190)

    for i, texto in ipairs(opcoes) do
        local prefixo = (i == indice) and "> " or "  "
        love.graphics.print(prefixo .. texto, 20, 250 + (i - 1) * 32)
    end
    if pendente then
        love.graphics.print("Terminar apaga esta gravacao. A outra vez confirma.", 20, 340)
    end
    love.graphics.print("Cima/baixo  A escolher", 20, 440)
end

return final
