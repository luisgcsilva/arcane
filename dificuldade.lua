local inimigos = require("inimigos")
local cores = require("cores")
local biomas = require("biomas")

local dificuldade = {}

dificuldade.SALAS_POR_BOSS = 10

-- % e o resto da divisao: sala 5, 10, 15... dao resto 0
function dificuldade.eBoss(sala)
    return sala > 0 and sala % dificuldade.SALAS_POR_BOSS == 0
end

-- Uma sala antes de cada chefe: 4, 9, 14...
function dificuldade.eLoja(sala)
    return sala % dificuldade.SALAS_POR_BOSS == dificuldade.SALAS_POR_BOSS - 1
end

local function arredondar(x)
    return math.floor(x + 0.5)
end

-- Salas 1-21: cresce a ritmo inteiro. 21-51: a 80%. Depois da 51: a 40%.
local function fator(sala, passo)
    local s = sala - 1
    local t = math.min(s, 20)
    if s > 20 then
        t = t + (math.min(s, 50) - 20) * 0.8
    end
    if s > 50 then
        t = t + (s - 50) * 0.7
    end
    return 1 + passo * t
end

function dificuldade.candidatos(sala)
    local id = biomas.daSala(sala).id
    local lista = {}
    for _, m in pairs(inimigos) do
        if not m.boss and m.minSala <= sala and biomas.permite(m, id) then
            table.insert(lista, m)
        end
    end
    return lista
end

function dificuldade.chefesDoBioma(sala)
    local id = biomas.daSala(sala).id
    local lista = {}
    for _, m in pairs(inimigos) do
        if m.boss and m.biomas and biomas.permite(m, id) then
            table.insert(lista, m)
        end
    end
    return lista
end

local function escolherModelo(sala)
    local lista
    if dificuldade.eBoss(sala) then
        lista = dificuldade.chefesDoBioma(sala)
    else
        lista = dificuldade.candidatos(sala)
    end
    return lista[math.random(#lista)]
end

function dificuldade.criarInimigo(sala, forcarBoss, elite)
    local modelo = escolherModelo(sala, forcarBoss)
    local e = {}
    for chave, valor in pairs(modelo) do
        e[chave] = valor
    end
    if not modelo.boss then
        e.vida = arredondar(modelo.vida * fator(sala, 0.08))
        e.ataque = arredondar(modelo.ataque * fator(sala, 0.06))
        if elite then
            e.vida = arredondar(e.vida * 1.6)
            e.ataque = arredondar(e.ataque * 1.25)
            e.elite = true
            e.base = modelo.nome -- nome original (o savegame precisa dele)
            e.nome = "Elite " .. modelo.nome
        end
    end
    e.vida_max = e.vida
    return e
end

return dificuldade
