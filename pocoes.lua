local pocoes = {}

-- Aqui uso uma LISTA (e nao uma tabela com nomes como chaves)
-- porque a ordem importa: e a ordem em que aparecem no menu.
pocoes.lista = {
  { id = "pequena", nome = "Pocao Pequena", cura = 10, peso = 75 },
  { id = "grande",  nome = "Pocao Grande",  cura = 25, peso = 25 },
}

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

return pocoes