local input = {}

-- Tecla do teclado (PC e analógico esquerdo) -> acção
local teclas = {
  up = "cima", down = "baixo", left = "esquerda", right = "direita",
  w = "cima", s = "baixo", a = "esquerda", d = "direita",
  z = "confirmar", x = "cancelar",
  ["return"] = "confirmar", escape = "cancelar",
  c = "menu", v = "extra",
  tab = "inventario",
  space = "pausa",
  q = "ombro_esq", e = "ombro_dir",
}

-- Número de botão da R36S -> acção
local botoes = {
  [16] = "cima", [15] = "baixo", [17] = "esquerda", [18] = "direita",
  [1] = "confirmar",   -- A
  [2] = "cancelar",    -- B
  [3] = "menu",        -- X
  [4] = "extra",       -- Y
  [5] = "ombro_esq", [6] = "ombro_dir",
  [7] = "gatilho_esq", [8] = "gatilho_dir",
  [9] = "inventario",  -- SELECT
  [10] = "pausa",      -- START
}

function input.daTecla(tecla)
  return teclas[tecla]
end

function input.daBotao(numero)
  return botoes[numero]
end

return input