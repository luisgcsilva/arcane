local loot = {}

loot.cores = {
    comum = { 0, 1, 0 },
    rara  = { 0.3, 0.6, 1 },
    epica = { 0.8, 0.3, 1 },
}

-- Devolve um texto colorido: so o nome do item leva a cor da raridade.
-- prefixo e sufixo sao opcionais.
function loot.nomeColorido(item, prefixo, sufixo)
    local branco = { 1, 1, 1 }
    return {
        branco, prefixo or "",
        loot.cores[item.raridade], item.nome,
        branco, sufixo or "",
    }
end

-- Dados: para acrescentar um item, basta uma linha nova.
-- tipo "arma" da ataque, tipo "armadura" reduz o dano recebido.
local itens = {
    { nome = "Adaga Velha",      tipo = "arma",     bonus = 1, raridade = "comum" },
    { nome = "Espada Curta",     tipo = "arma",     bonus = 2, raridade = "comum" },
    { nome = "Machado de Ferro", tipo = "arma",     bonus = 4, raridade = "rara" },
    { nome = "Lamina Arcana",    tipo = "arma",     bonus = 7, raridade = "epica" },
    { nome = "Tunica de Pano",   tipo = "armadura", bonus = 1, raridade = "comum" },
    { nome = "Cota de Malha",    tipo = "armadura", bonus = 2, raridade = "rara" },
    { nome = "Armadura Arcana",  tipo = "armadura", bonus = 4, raridade = "epica" },
}

-- Quanto maior o peso, mais frequente. Total = 100, logo sao percentagens.
local raridades = {
    { nome = "comum", peso = 70 },
    { nome = "rara",  peso = 25 },
    { nome = "epica", peso = 5 },
}

-- Agrupa os itens por raridade (construido uma vez, dinamicamente)
local porRaridade = {}
for _, item in ipairs(itens) do
    porRaridade[item.raridade] = porRaridade[item.raridade] or {}
    table.insert(porRaridade[item.raridade], item)
end

local function sortearRaridade(bonus)
  bonus = bonus or 0
  local pesos = {
    comum = math.max(10, 70 - 2 * bonus),
    rara  = 25 + bonus,
    epica = 5 + bonus,
  }
  local ordem = { "comum", "rara", "epica" }

  local total = 0
  for _, nome in ipairs(ordem) do
    total = total + pesos[nome]
  end
  local sorte = math.random(total)
  for _, nome in ipairs(ordem) do
    if sorte <= pesos[nome] then
      return nome
    end
    sorte = sorte - pesos[nome]
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

return loot
