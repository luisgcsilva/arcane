local armazem = require("armazem")

local registo = {}

registo.ativo = true -- false desliga tudo (nada se grava nem se mostra)
registo.visivel = false -- o painel no ecra (alterna com START)
registo.linhas = {}
registo.desl = 0 -- linhas recuadas a partir do fim (0 = mostra as mais recentes)

local FICHEIRO = "log_salas.txt"
local MAX = 300 -- linhas guardadas (as mais antigas saem)
local VISIVEIS = 16
local fonte

-- Recupera o que ficou de sessoes anteriores
function registo.carregar()
    if not registo.ativo then
        return
    end
    for linha in armazem.linhas(FICHEIRO) do
        table.insert(registo.linhas, linha)
    end
    while #registo.linhas > MAX do
        table.remove(registo.linhas, 1)
    end
end

function registo.add(texto)
    if not registo.ativo then
        return
    end
    table.insert(registo.linhas, texto)
    if #registo.linhas > MAX then
        table.remove(registo.linhas, 1)
    end
    -- se estas a ler linhas antigas, a vista nao salta quando entra uma nova
    if registo.desl > 0 then
        registo.desl = registo.desl + 1
    end
    armazem.escrever(FICHEIRO, table.concat(registo.linhas, "\n") .. "\n")
end

function registo.alternar()
    registo.visivel = not registo.visivel
    registo.desl = 0 -- ao abrir, mostra sempre o fim
end

local function limite()
    return math.max(0, #registo.linhas - VISIVEIS)
end

function registo.scroll(passo)
    registo.desl = math.max(0, math.min(registo.desl + passo, limite()))
end

-- Recebe uma accao do jogo enquanto o painel esta aberto
function registo.acao(a)
    if a == "cima" then
        registo.scroll(1)
    elseif a == "baixo" then
        registo.scroll(-1)
    elseif a == "ombro_esq" then
        registo.scroll(VISIVEIS)
    elseif a == "ombro_dir" then
        registo.scroll(-VISIVEIS)
    elseif a == "gatilho_esq" then
        registo.scroll(limite())
    elseif a == "gatilho_dir" then
        registo.desl = 0
    elseif a == "cancelar" then
        registo.visivel = false
    end
end

function registo.desenhar()
    if not (registo.ativo and registo.visivel) then
        return
    end
    fonte = fonte or love.graphics.newFont(12)
    local anterior = love.graphics.getFont()
    love.graphics.setFont(fonte)

    love.graphics.setColor(0, 0, 0, 0.88)
    love.graphics.rectangle("fill", 0, 0, 640, VISIVEIS * 14 + 24)

    local desl = math.min(registo.desl, limite())
    local fim = #registo.linhas - desl
    local inicio = math.max(1, fim - VISIVEIS + 1)

    love.graphics.setColor(1, 1, 0.5)
    love.graphics.print(string.format("REGISTO DE SALAS  %d-%d de %d   (cima/baixo, L1/R1, START fecha)", inicio, fim,
        #registo.linhas), 6, 4)

    love.graphics.setColor(0.6, 1, 0.6)
    for i = inicio, fim do
        love.graphics.print(registo.linhas[i], 6, 22 + (i - inicio) * 14)
    end

    love.graphics.setFont(anterior)
    love.graphics.setColor(1, 1, 1)
end

return registo
