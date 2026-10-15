local jogo = require("jogo")
local jogador = require("jogador")
local recordes = require("recordes")
local cores = require("cores")
local savegame = require("savegame")
local historico = require("historico")

local derrota = {}

local novoRecorde

function derrota.entrar()
    -- corre uma vez por derrota, por isso a partida so e registada uma vez
    savegame.apagar() -- apaga a gravacao, para nao se poder continuar
    novoRecorde = recordes.registarFim(jogador.sala, jogador.stats.inimigos)
    historico.registar(novoRecorde, recordes.dados.partidas)
end

function derrota.acao(a)
    if a == "confirmar" then
        jogo.mudar("menu")
    end
end

function derrota.desenhar()
    local s = jogador.stats
    local d = recordes.dados

    love.graphics.setColor(1, 0.4, 0.3)
    love.graphics.print("DERROTA", 20, 20)
    love.graphics.setColor(1, 1, 1)

    love.graphics.print("Chegaste a sala " .. jogador.sala, 20, 70)
    love.graphics.print("Inimigos vencidos: " .. s.inimigos .. "  (chefes: " .. s.chefes .. ")", 20, 106)
    love.graphics.print("Dano causado: " .. s.dano_causado, 20, 142)
    love.graphics.print("Dano sofrido: " .. s.dano_sofrido, 20, 178)
    love.graphics.print("Pocoes usadas: " .. s.pocoes, 20, 214)

    if novoRecorde then
        love.graphics.setColor(1, 0.85, 0.2)
        love.graphics.print("NOVO RECORDE!", 20, 280)
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.print("Recorde: sala " .. d.melhor_sala, 20, 280)
    end
    love.graphics.print("Partidas jogadas: " .. d.partidas, 20, 316)

    love.graphics.print("A - menu", 20, 440)
end

return derrota
