local jogo = require("jogo")
local simulacao = require("simulacao")
local armazem = require("armazem")
local sprites = require("sprites")

local estado = {}

local OPCOES = {100, 300, 1000}
local idx, linhas, desl, fonte
local VISIVEIS = 28

function estado.entrar()
    fonte = fonte or love.graphics.newFont(12)
    idx = 1
    linhas = nil
    desl = 0
end

function estado.acao(a)
    if a == "cancelar" then
        jogo.mudar("menu")
    elseif a == "confirmar" then
        local csv
        linhas, csv = simulacao.correr(OPCOES[idx])
        armazem.escrever("simulacao.txt", table.concat(linhas, "\n") .. "\n")
        armazem.escrever("simulacao.csv", csv)
        desl = 0
    elseif a == "cima" then
        if linhas then
            desl = math.max(0, desl - 1)
        else
            idx = (idx - 2) % #OPCOES + 1
        end
    elseif a == "baixo" then
        if linhas then
            desl = math.min(math.max(0, #linhas - VISIVEIS), desl + 1)
        else
            idx = idx % #OPCOES + 1
        end
    end
end

function estado.desenhar()
    local normal = love.graphics.getFont()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SIMULAÇÃO", 20, 16)
    love.graphics.setFont(fonte)

    if not linhas then
        love.graphics.print("Partidas por classe: " .. OPCOES[idx] .. "   (cima/baixo muda)", 20, 70)
        love.graphics.print("Um bot joga sozinho e mede atá onde chega cada classe.", 20, 100)
        love.graphics.print("Pode demorar alguns segundos. Não altera o teu jogo gravado.", 20, 120)
        love.graphics.print("O resultado fica em simulacao.txt e simulacao.csv.", 20, 140)
    else
        for i = 1, VISIVEIS do
            local l = linhas[desl + i]
            if not l then
                break
            end
            love.graphics.print(l, 20, 44 + (i - 1) * 14)
        end
    end

    love.graphics.setFont(normal)
    if linhas then
        sprites.ajuda({{"CIMABAIXO", "Mover"}, {"A", "repetir"}, {"B", "voltar"}}, 20, 440)
    else
        sprites.ajuda({{"A", "correr"}, {"B", "voltar"}}, 20, 440)
    end
end

return estado
