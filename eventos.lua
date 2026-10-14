local jogador = require("jogador")

local eventos = {}

-- Perde vida sem nunca matar (deixa sempre pelo menos 1). Devolve o dano real.
local function perder(n)
  local dano = math.max(0, math.min(n, jogador.vida - 1))
  jogador.vida = jogador.vida - dano
  jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + dano
  return dano
end

local function ignorar()
  return "Segues caminho."
end

-- Cada opcao tem um "efeito": uma funcao que devolve uma mensagem.
-- Se devolver true como segundo valor, a opcao foi recusada (sem custo)
-- e o jogador pode escolher outra.
eventos.lista = {
  {
    id = "fonte", titulo = "A fonte misteriosa", minSala = 2,
    texto = "Uma fonte de agua cristalina brilha no meio da sala. Sera segura?",
    opcoes = {
      { texto = "Beber da fonte", efeito = function()
          if math.random() < 0.5 then
            local cura = math.min(math.ceil(jogador.vida_max * 0.5), jogador.vida_max - jogador.vida)
            jogador.vida = jogador.vida + cura
            return "A agua e revigorante! Recuperas " .. cura .. " de vida."
          end
          local dano = perder(math.max(2, math.floor(jogador.vida_max * 0.2)))
          return "A agua estava envenenada! Perdes " .. dano .. " de vida."
        end },
      { texto = "Ignorar", efeito = ignorar },
    },
  },

  {
    id = "altar", titulo = "O altar sombrio", minSala = 3,
    texto = "Um altar de pedra negra pede uma oferenda em troca de poder.",
    opcoes = {
      { texto = "Oferecer sangue (-25% vida, +1 ataque)", efeito = function()
          local custo = math.floor(jogador.vida_max * 0.25)
          if jogador.vida - custo < 1 then
            return "Estas demasiado fraco para isto.", true
          end
          jogador.vida = jogador.vida - custo
          jogador.ataque_base = jogador.ataque_base + 1
          return "O altar aceita. Perdes " .. custo .. " de vida e o teu ataque base sobe para " ..
                 jogador.ataque_base .. "."
        end },
      { texto = "Oferecer 20 moedas (+3 vida maxima)", efeito = function()
          if jogador.moedas < 20 then
            return "Nao tens moedas suficientes.", true
          end
          jogador.moedas = jogador.moedas - 20
          jogador.vida_max = jogador.vida_max + 3
          jogador.vida = jogador.vida + 3
          return "O altar aceita. Vida maxima +3."
        end },
      { texto = "Ignorar", efeito = ignorar },
    },
  },

  {
    id = "viajante", titulo = "O viajante dos dados", minSala = 2,
    texto = "Um viajante encapuzado propoe um jogo: apostas 15 moedas e, se ganhares, ele paga o mesmo.",
    opcoes = {
      { texto = "Apostar 15 moedas", efeito = function()
          if jogador.moedas < 15 then
            return "Nao tens 15 moedas.", true
          end
          if math.random() < 0.45 then
            jogador.ganharMoedas(15)
            return "Os dados sorriem-te! Ganhas 15 moedas."
          end
          jogador.moedas = jogador.moedas - 15
          return "Perdes. O viajante guarda as tuas 15 moedas."
        end },
      { texto = "Recusar", efeito = function()
          return "O viajante encolhe os ombros e desaparece na sombra."
        end },
    },
  },
}

function eventos.porId(id)
  for _, ev in ipairs(eventos.lista) do
    if ev.id == id then return ev end
  end
end

function eventos.existe(id)
  return eventos.porId(id) ~= nil
end

function eventos.sortear(sala)
  local elegiveis = {}
  for _, ev in ipairs(eventos.lista) do
    if ev.minSala <= sala then
      table.insert(elegiveis, ev)
    end
  end
  return elegiveis[math.random(#elegiveis)]
end

return eventos