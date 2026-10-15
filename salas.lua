local dificuldade = require("dificuldade")

local salas = {}

salas.MAX_PORTAS = 3

-- Dados: para acrescentar um tipo de sala, basta uma linha nova.
-- peso: frequencia. minSala: a partir de que sala pode aparecer.
-- naoRepetir: nao aparece logo a seguir a uma sala do mesmo tipo.
salas.lista = {{
    id = "combate",
    nome = "Combate",
    peso = 70,
    minSala = 1
}, {
    id = "loja",
    nome = "Loja",
    peso = 15,
    minSala = 2,
    naoRepetir = true
}, {
    id = "fogueira",
    nome = "Fogueira",
    peso = 12,
    minSala = 2,
    naoRepetir = true
}, {
    id = "tesouro",
    nome = "Tesouro",
    peso = 15,
    minSala = 2,
    naoRepetir = true
}, {
    id = "elite",
    nome = "Elite",
    peso = 12,
    minSala = 30,
    naoRepetir = true
}, {
    id = "evento",
    nome = "Evento",
    peso = 14,
    minSala = 3,
    naoRepetir = true
}}

-- ids aceites (o chefe nao e sorteado: so aparece nas salas de chefe)
local validos = {
    boss = true
}
for _, t in ipairs(salas.lista) do
    validos[t.id] = true
end

function salas.valido(id)
    return validos[id] == true
end

local function sortear(lista)
    local total = 0
    for _, t in ipairs(lista) do
        total = total + t.peso
    end
    local sorte = math.random(total)
    for _, t in ipairs(lista) do
        if sorte <= t.peso then
            return t
        end
        sorte = sorte - t.peso
    end
end

-- Portas para a sala numero "proxima". "anterior" e o tipo da sala onde estas.
function salas.gerarPortas(proxima, anterior)
    if dificuldade.eBoss(proxima) then
        return {"boss"}
    end
    -- sala antes do chefe: loja garantida (a menos que acabaste de sair de uma)
    -- sala antes do chefe: loja OU fogueira garantida (nunca a mesma da sala anterior)
    if dificuldade.eLoja(proxima) then
        local opcoes = {}
        for _, id in ipairs({"loja", "fogueira"}) do
            if id ~= anterior then
                table.insert(opcoes, id)
            end
        end
        return {opcoes[math.random(#opcoes)]}
    end

    local elegiveis = {}
    for _, t in ipairs(salas.lista) do
        if t.minSala <= proxima and not (t.naoRepetir and t.id == anterior) then
            table.insert(elegiveis, t)
        end
    end

    -- com uma so opcao possivel, nao ha escolha: uma porta
    local n = (#elegiveis > 1) and math.random(2, salas.MAX_PORTAS) or 1
    local portas = {}
    for _ = 1, n do
        table.insert(portas, sortear(elegiveis).id)
    end
    return portas
end

return salas
