local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")

local mercador = {}

mercador.stock = {}

-- Chamada uma vez, ao entrar na sala da loja
function mercador.gerar(sala)
  mercador.stock = {}

  for _ = 1, 2 do
    local item = loot.sortear(sala)
    table.insert(mercador.stock, { tipo = "item", item = item, preco = loot.valor(item) })
  end

  local exclusivo = loot.exclusivo()
  table.insert(mercador.stock, { tipo = "item", item = exclusivo, preco = loot.valor(exclusivo) })

  for _, p in ipairs(pocoes.lista) do
    table.insert(mercador.stock, { tipo = "pocao", pocao = p, preco = p.preco })
  end
end

-- Devolve true/false e uma mensagem para mostrar
function mercador.comprar(i)
  local e = mercador.stock[i]
  if e.vendido then return false, "Esse ja nao esta disponivel." end
  if jogador.moedas < e.preco then return false, "Moedas insuficientes." end

  local nome
  if e.tipo == "item" then
    if not jogador.guardar(e.item) then return false, "Mochila cheia! Vende algo primeiro." end
    e.vendido = true
    nome = e.item.nome
  else
    jogador.darPocao(e.pocao.id)
    nome = e.pocao.nome
  end

  jogador.moedas = jogador.moedas - e.preco
  return true, "Compraste " .. nome .. "."
end

return mercador