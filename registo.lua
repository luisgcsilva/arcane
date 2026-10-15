local armazem = require("armazem")

local registo = {}

registo.ativo = true     -- false desliga tudo (nada se grava nem se mostra)
registo.visivel = false  -- o painel no ecra (alterna com START)
registo.linhas = {}

local FICHEIRO = "log_salas.txt"
local MAX = 300          -- linhas guardadas (as mais antigas saem)
local VISIVEIS = 16
local fonte

-- Recupera o que ficou de sessoes anteriores
function registo.carregar()
  if not registo.ativo then return end
  for linha in armazem.linhas(FICHEIRO) do
    table.insert(registo.linhas, linha)
  end
  while #registo.linhas > MAX do table.remove(registo.linhas, 1) end
end

function registo.add(texto)
  if not registo.ativo then return end
  table.insert(registo.linhas, texto)
  if #registo.linhas > MAX then table.remove(registo.linhas, 1) end
  armazem.escrever(FICHEIRO, table.concat(registo.linhas, "\n") .. "\n")
end

function registo.alternar()
  registo.visivel = not registo.visivel
end

function registo.desenhar()
  if not (registo.ativo and registo.visivel) then return end
  fonte = fonte or love.graphics.newFont(12)
  local anterior = love.graphics.getFont()
  love.graphics.setFont(fonte)

  love.graphics.setColor(0, 0, 0, 0.88)
  love.graphics.rectangle("fill", 0, 0, 640, VISIVEIS * 14 + 24)

  love.graphics.setColor(1, 1, 0.5)
  love.graphics.print("REGISTO DE SALAS (START fecha)", 6, 4)

  love.graphics.setColor(0.6, 1, 0.6)
  local inicio = math.max(1, #registo.linhas - VISIVEIS + 1)
  for i = inicio, #registo.linhas do
    love.graphics.print(registo.linhas[i], 6, 22 + (i - inicio) * 14)
  end

  love.graphics.setFont(anterior)
  love.graphics.setColor(1, 1, 1)
end

return registo