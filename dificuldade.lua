local inimigos = require("inimigos")
local cores = require("cores")

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

-- Sala 1 = x1.0. A vida cresce 20% por sala, o ataque 12%.
local function fator(sala, passo)
    local s = sala - 1
    if s > 20 then s = 20 + (s - 20) * 0.5 end -- depois da sala 21 cresce a metade
    return 1 + passo * s
end

local function escolherModelo(sala)
    if dificuldade.eBoss(sala) then
        -- o chefe mais "avancado" que ja pode aparecer
        local melhor
        for _, m in pairs(inimigos) do
            if m.boss and m.minSala <= sala and (melhor == nil or m.minSala > melhor.minSala) then
                melhor = m
            end
        end
        return melhor
    end

    -- inimigos normais ja desbloqueados nesta sala
    local lista = {}
    for _, m in pairs(inimigos) do
        if not m.boss and m.minSala <= sala then
            table.insert(lista, m)
        end
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
        e.vida = arredondar(modelo.vida * fator(sala, 0.05))
        e.ataque = arredondar(modelo.ataque * fator(sala, 0.05))
        if elite then
            e.vida = arredondar(e.vida * 1.6)
            e.ataque = arredondar(e.ataque * 1.4)
            e.elite = true
            e.base = modelo.nome -- nome original (o savegame precisa dele)
            e.nome = "Elite " .. modelo.nome
        end
    end
    e.vida_max = e.vida
    return e
end

return dificuldade
