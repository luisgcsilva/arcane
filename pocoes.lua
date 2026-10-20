local pocoes = {}
local cores = require("cores")

-- Aqui uso uma LISTA (e nao uma tabela com nomes como chaves)
-- porque a ordem importa: e a ordem em que aparecem no menu.
pocoes.lista = {{
    id = "pequena",
    nome = "Pocao Pequena",
    cura = 10,
    peso = 60,
    preco = 12,
    icone = 276,
    cor = {1, 0.45, 0.45}
}, {
    id = "media",
    nome = "Pocao Media",
    cura = 18,
    peso = 28,
    preco = 20,
    icone = 281,
    cor = {1, 0.3, 0.3}
}, {
    id = "grande",
    nome = "Pocao Grande",
    cura = 30,
    peso = 12,
    preco = 34,
    icone = 272,
    cor = {1, 0.15, 0.15}
}}

-- Sorteio por pesos, igual ao das raridades do loot
function pocoes.sortear()
    local total = 0
    for _, p in ipairs(pocoes.lista) do
        total = total + p.peso
    end
    local sorte = math.random(total)
    for _, p in ipairs(pocoes.lista) do
        if sorte <= p.peso then
            return p
        end
        sorte = sorte - p.peso
    end
end

-- Caminho do icone de uma pocao
function pocoes.caminhoIcone(p)
    return p.icone and ("imagens/itens/fa" .. p.icone .. ".png") or nil
end

return pocoes
