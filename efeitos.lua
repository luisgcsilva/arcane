local efeitos = {}

-- Ordem em que os efeitos sao processados e mostrados.
-- Um efeito novo precisa de uma entrada aqui e outra em "lista".
efeitos.ordem = { "veneno", "sangramento", "atordoamento" }

efeitos.lista = {
  veneno       = { nome = "Veneno",       frase = "Foste envenenado!",  cor = { 0.5, 0.9, 0.4 }, turnos = 3, dano = 2, curavel = true },
  sangramento  = { nome = "Sangramento",  frase = "Comecas a sangrar!", cor = { 1, 0.3, 0.3 },   turnos = 2, dano = 3, curavel = true },
  atordoamento = { nome = "Atordoamento", frase = "Ficas atordoado!",   cor = { 1, 0.85, 0.2 },  turnos = 1 },
}

-- O dano por turno sobe um pouco com a sala
function efeitos.dano(id, sala)
  return efeitos.lista[id].dano + math.floor(sala / 8)
end

-- Remove os efeitos curaveis de "alvo" (uma tabela id -> turnos).
-- Devolve quantos curou.
function efeitos.curar(alvo)
  local n = 0
  for id, def in pairs(efeitos.lista) do
    if def.curavel and alvo[id] then
      alvo[id] = nil
      n = n + 1
    end
  end
  return n
end

return efeitos