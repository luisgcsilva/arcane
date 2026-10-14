local jogo = require("jogo")
local jogador = require("jogador")

local menu = {}

local opcoes = { "Novo jogo", "Sair" }
local indice = 1

function menu.entrar()
  indice = 1
end

function menu.acao(a)
  if a == "cima" then
    indice = indice - 1
    if indice < 1 then indice = #opcoes end
  elseif a == "baixo" then
    indice = indice + 1
    if indice > #opcoes then indice = 1 end
  elseif a == "confirmar" then
    if indice == 1 then
        jogador.reiniciar()
        jogo.mudar("explorar")
    else
      love.event.quit()
    end
  end
end

function menu.desenhar()
  love.graphics.print("ARCANE", 270, 80)
  for i, texto in ipairs(opcoes) do
    local prefixo = (i == indice) and "> " or "  "
    love.graphics.print(prefixo .. texto, 250, 160 + i * 36)
  end
end

return menu