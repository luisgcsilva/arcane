local loot = {}
local cores = require("cores")

loot.cores = {
    comum = {0, 1, 0},
    rara = {0.3, 0.6, 1},
    epica = {0.8, 0.3, 1},
    lendaria = {1, 0.65, 0.1},
    mitica = {1, 0.25, 0.35}
}

-- Valor por ponto de bonus. A loja vende ao valor total, tu vendes a metade.
local VALOR = {
    comum = 3,
    rara = 6,
    epica = 12,
    lendaria = 20,
    mitica = 40
}

-- Devolve um texto colorido: so o nome do item leva a cor da raridade.
-- prefixo e sufixo sao opcionais.
function loot.nomeColorido(item, prefixo, sufixo)
    local branco = {1, 1, 1}
    return {branco, prefixo or "", loot.cores[item.raridade], item.nome, branco, sufixo or ""}
end

-- So aparecem na loja: nao estao na tabela "itens", por isso nunca caem
loot.exclusivos = {{
    nome = "Espada do Alvorecer",
    tipo = "arma",
    bonus = 10,
    raridade = "lendaria"
}, {
    nome = "Martelo Trovejante",
    tipo = "arma",
    bonus = 14,
    raridade = "lendaria"
}, {
    nome = "Egide Eterna",
    tipo = "armadura",
    bonus = 8,
    raridade = "lendaria"
}, {
    nome = "Manto das Estrelas",
    tipo = "armadura",
    bonus = 10,
    raridade = "lendaria"
}, {
    nome = "Arco do Caos",
    tipo = "arma",
    bonus = 15,
    raridade = "lendaria"
}, {
    nome = "Coroa dos Esquecidos",
    tipo = "armadura",
    bonus = 12,
    raridade = "lendaria"
}}

-- Dados: para acrescentar um item, basta uma linha nova.
-- tipo "arma" da ataque, tipo "armadura" reduz o dano recebido.
local itens = {{
    nome = "Adaga Velha",
    tipo = "arma",
    bonus = 1,
    raridade = "comum"
}, {
    nome = "Espada Curta",
    tipo = "arma",
    bonus = 2,
    raridade = "comum"
}, {
    nome = "Machado de Ferro",
    tipo = "arma",
    bonus = 4,
    raridade = "rara"
}, {
    nome = "Lamina Arcana",
    tipo = "arma",
    bonus = 7,
    raridade = "epica"
}, {
    nome = "Tunica de Pano",
    tipo = "armadura",
    bonus = 1,
    raridade = "comum"
}, {
    nome = "Cota de Malha",
    tipo = "armadura",
    bonus = 2,
    raridade = "rara"
}, {
    nome = "Armadura Arcana",
    tipo = "armadura",
    bonus = 4,
    raridade = "epica"
}, {
    nome = "Faca de Cacador",
    tipo = "arma",
    bonus = 1,
    raridade = "comum"
}, {
    nome = "Lanca Enferrujada",
    tipo = "arma",
    bonus = 2,
    raridade = "comum"
}, {
    nome = "Gibao de Couro",
    tipo = "armadura",
    bonus = 1,
    raridade = "comum"
}, {
    nome = "Maca de Guerra",
    tipo = "arma",
    bonus = 3,
    raridade = "rara"
}, {
    nome = "Florete Veloz",
    tipo = "arma",
    bonus = 5,
    raridade = "rara"
}, {
    nome = "Escudo de Aco",
    tipo = "armadura",
    bonus = 2,
    raridade = "rara"
}, {
    nome = "Peitoral Reforcado",
    tipo = "armadura",
    bonus = 3,
    raridade = "rara"
}, {
    nome = "Cajado Trovejante",
    tipo = "arma",
    bonus = 8,
    raridade = "epica"
}, {
    nome = "Espada de Obsidiana",
    tipo = "arma",
    bonus = 9,
    raridade = "epica"
}, {
    nome = "Manto de Sombras",
    tipo = "armadura",
    bonus = 5,
    raridade = "epica"
}, {
    nome = "Espada Flamejante",
    tipo = "arma",
    bonus = 11,
    raridade = "lendaria"
}, {
    nome = "Machado do Tita",
    tipo = "arma",
    bonus = 12,
    raridade = "lendaria"
}, {
    nome = "Lanca do Dragao",
    tipo = "arma",
    bonus = 13,
    raridade = "lendaria"
}, {
    nome = "Cota de Mithril",
    tipo = "armadura",
    bonus = 6,
    raridade = "lendaria"
}, {
    nome = "Armadura do Guardiao",
    tipo = "armadura",
    bonus = 7,
    raridade = "lendaria"
}, {
    nome = "Lamina do Vazio",
    tipo = "arma",
    bonus = 16,
    raridade = "mitica"
}, {
    nome = "Ceifador de Almas",
    tipo = "arma",
    bonus = 18,
    raridade = "mitica"
}, {
    nome = "Arco Estelar",
    tipo = "arma",
    bonus = 20,
    raridade = "mitica"
}, {
    nome = "Armadura do Abismo",
    tipo = "armadura",
    bonus = 13,
    raridade = "mitica"
}, {
    nome = "Vestes Celestiais",
    tipo = "armadura",
    bonus = 15,
    raridade = "mitica"
}, {
    nome = "Egide do Imperador",
    tipo = "armadura",
    bonus = 17,
    raridade = "mitica"
}}

-- Quanto maior o peso, mais frequente. Total = 100, logo sao percentagens.
local raridades = {{
    nome = "comum",
    peso = 70
}, {
    nome = "rara",
    peso = 25
}, {
    nome = "epica",
    peso = 5
}}

-- Agrupa os itens por raridade (construido uma vez, dinamicamente)
local porRaridade = {}
for _, item in ipairs(itens) do
    porRaridade[item.raridade] = porRaridade[item.raridade] or {}
    table.insert(porRaridade[item.raridade], item)
end

-- Raridade de um item pelo nome (nil se o item ja nao existir)
function loot.raridadeDe(nome)
    for _, i in ipairs(itens) do
        if i.nome == nome then
            return i.raridade
        end
    end
    for _, i in ipairs(loot.exclusivos) do
        if i.nome == nome then
            return i.raridade
        end
    end
end

-- peso = (bonus - inicio) * subida, entre 0 e topo. A comum so desce.
local escaloes = {{
    nome = "rara",
    inicio = -25,
    topo = 50
}, {
    nome = "epica",
    inicio = -5,
    topo = 50
}, {
    nome = "lendaria",
    inicio = 30,
    topo = 40
}, {
    nome = "mitica",
    inicio = 60,
    topo = 30
}}

local function sortearRaridade(bonus)
    bonus = bonus or 0
    local pesos = {{
        nome = "comum",
        peso = math.max(5, 70 - 2 * bonus)
    }}
    for _, t in ipairs(escaloes) do
        table.insert(pesos, {
            nome = t.nome,
            peso = math.max(0, math.min(bonus - t.inicio, t.topo))
        })
    end

    local total = 0
    for _, p in ipairs(pesos) do
        total = total + p.peso
    end
    local sorte = math.random(total)
    for _, p in ipairs(pesos) do
        if sorte <= p.peso then
            return p.nome
        end
        sorte = sorte - p.peso
    end
end

function loot.sortear(bonus)
    local lista = porRaridade[sortearRaridade(bonus)]
    local modelo = lista[math.random(#lista)]
    local item = {}
    for chave, valor in pairs(modelo) do
        item[chave] = valor
    end
    return item
end

function loot.valor(item)
    return item.bonus * VALOR[item.raridade]
end

function loot.precoVenda(item)
    return math.max(1, math.floor(loot.valor(item) / 2))
end

function loot.exclusivo()
    local modelo = loot.exclusivos[math.random(#loot.exclusivos)]
    local item = {}
    for chave, valor in pairs(modelo) do
        item[chave] = valor
    end
    return item
end

return loot
