local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local salas = require("salas")
local savegame = require("savegame")

local tesouro = {}

local mensagens
local aberto

local DOURADO = { 1, 0.85, 0.2 }
local BRANCO = { 1, 1, 1 }

function tesouro.entrar()
  jogador.especial = "tesouro"
  jogador.portas = nil
  jogador.inimigo = nil
  mensagens = {}
  aberto = false
  savegame.gravar()
end

local function abrirBau()
  local sorte = math.random(100)

  if sorte <= 15 then
    -- armadilha: nunca te mata (deixa sempre pelo menos 1 de vida)
    local dano = math.min(jogador.vida - 1, math.max(2, math.floor(jogador.vida_max * 0.15)))
    if dano > 0 then
      jogador.vida = jogador.vida - dano
      jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + dano
      table.insert(mensagens, { { 1, 0.4, 0.3 }, "Era uma armadilha! Perdes " .. dano .. " de vida." })
    else
      table.insert(mensagens, "Uma armadilha dispara, mas escapas por pouco.")
    end

  elseif sorte <= 55 then
    local item = loot.sortear(jogador.sala + 3)
    local atributo = (item.tipo == "arma") and "ataque" or "defesa"
    table.insert(mensagens, loot.nomeColorido(item, "Encontras: ",
      " (+" .. item.bonus .. " " .. atributo .. ")"))
    if jogador.guardar(item) then
      table.insert(mensagens, "Guardas na mochila.")
      if jogador.eMelhor(item) then
        table.insert(mensagens, "E melhor que o equipado! Abre a mochila (SELECT).")
      end
    else
      local ganho = loot.precoVenda(item)
      jogador.ganharMoedas(ganho)
      table.insert(mensagens, "Mochila cheia! Vendes por " .. ganho .. " moedas.")
    end

  else
    local n = math.random(8, 15) + 3 * jogador.sala
    jogador.ganharMoedas(n)
    table.insert(mensagens, { DOURADO, "O bau esta cheio de moedas: +" .. n .. "." })
  end

  -- a gravacao ja aponta para as portas seguintes
  jogador.especial = nil
  jogador.portas = salas.gerarPortas(jogador.sala + 1, "tesouro")
  savegame.gravar()
  aberto = true
end

function tesouro.acao(a)
  if a == "inventario" then jogo.abrir("inventario") return end
  if a == "menu" then jogo.abrir("pocoes") return end

  if a == "confirmar" then
    if not aberto then
      abrirBau()
    else
      jogo.mudar("portas", jogador.portas)
    end
  end
end

function tesouro.desenhar()
  love.graphics.setColor(DOURADO)
  love.graphics.print("TESOURO", 20, 20)
  love.graphics.setColor(BRANCO)
  love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)
  love.graphics.print({ DOURADO, "Moedas: " .. jogador.moedas }, 420, 20)

  -- o bau: corpo e tampa
  love.graphics.setColor(0.45, 0.3, 0.15)
  love.graphics.rectangle("fill", 470, 220, 120, 70)
  love.graphics.setColor(aberto and { 0.2, 0.15, 0.1 } or { 0.55, 0.38, 0.2 })
  love.graphics.rectangle("fill", 470, aberto and 195 or 200, 120, 25)
  love.graphics.setColor(DOURADO)
  love.graphics.rectangle("fill", 521, 238, 18, 18)
  love.graphics.setColor(BRANCO)

  if not aberto then
    love.graphics.print("Um bau antigo, fechado. Pode ser uma armadilha...", 20, 110)
    love.graphics.print("A - abrir o bau", 20, 440)
  else
    for i, linha in ipairs(mensagens) do
      love.graphics.print(linha, 20, 110 + (i - 1) * 32)
    end
    love.graphics.setColor(BRANCO)
    love.graphics.print("A seguir  X pocoes  SELECT mochila", 20, 440)
  end
end

return tesouro