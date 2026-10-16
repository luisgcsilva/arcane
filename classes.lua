local classes = {}

-- Dados: para acrescentar uma classe, basta uma entrada nova.
-- defesa: bonus fixo. fuga: chance base de fugir. moedas e cura: multiplicadores.
classes.lista = {
  { id = "guerreiro", nome = "Guerreiro", cor = { 0.9, 0.5, 0.3 },
    descricao = "Aguenta pancada. Comeca com mais vida e uma armadura natural.",
    perk = "Armadura natural: +2 defesa.",
    vida = 60, ataque = 6, defesa = 2, vidaNivel = 8, ataqueNivel = 1,
    fuga = 0.5, moedas = 1, cura = 1 },

  { id = "ninja", nome = "Ninja", cor = { 0.5, 0.9, 0.6 },
    descricao = "Rapido e oportunista. Foge com facilidade e rouba mais moedas.",
    perk = "Fuga de 75% e +50% de moedas dos inimigos.",
    vida = 58, ataque = 8, defesa = 0, vidaNivel = 9, ataqueNivel = 2,
    fuga = 0.75, moedas = 1.5, cura = 1 },

  { id = "mago", nome = "Mago", cor = { 0.6, 0.7, 1 },
    descricao = "Fragil mas devastador. Bate forte e cresce depressa em ataque.",
    perk = "Pocoes curam +50%.",
    vida = 35, ataque = 9, defesa = 0, vidaNivel = 6, ataqueNivel = 3,
    fuga = 0.5, moedas = 1, cura = 1.5 },
}

-- Valores neutros: usados quando nao ha classe (gravacoes antigas)
classes.neutra = { vida = 30, ataque = 5, defesa = 0, vidaNivel = 4, ataqueNivel = 1,
                   fuga = 0.5, moedas = 1, cura = 1 }

function classes.porId(id)
  for _, c in ipairs(classes.lista) do
    if c.id == id then return c end
  end
end

function classes.existe(id)
  return classes.porId(id) ~= nil
end

return classes