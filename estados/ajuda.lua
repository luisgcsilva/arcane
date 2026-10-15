local jogo = require("jogo")

local estado = {}

-- Dados: para ajuda de um ecra novo, basta uma entrada (a chave e o nome com que o estado foi registado).
local dados = {
  menu      = { "SETAS - escolher", "A - confirmar" },
  classes   = { "Cima/baixo - ver classes", "A - escolher", "B - voltar" },
  portas    = { "Esq/Dir - escolher a porta", "A - abrir", "X - pocoes", "SELECT - mochila", "B - menu" },
  explorar  = { "A - lutar (ou seguir, na loja)", "Y - abrir a loja", "X - pocoes", "SELECT - mochila", "B - menu" },
  combate   = { "Cima/baixo - escolher", "A - confirmar", "B - voltar (nas pocoes)", "L1/R1 - ler o registo do combate" },
  loja      = { "Cima/baixo - escolher", "A - comprar (2x para confirmar)", "SELECT - vender na mochila", "B - sair" },
  inventario = { "Cima/baixo - escolher", "L1/R1 - alternar equipamento/reliquias", "A - equipar", "X - vender (2x)", "Y - pocoes", "B ou SELECT - fechar" },
  pocoes    = { "Cima/baixo - escolher", "A - beber", "B - fechar" },
  tesouro   = { "A - abrir o bau / escolher", "X - pocoes", "SELECT - mochila" },
  fogueira  = { "Cima/baixo - escolher", "A - confirmar", "X - pocoes", "SELECT - mochila" },
  evento    = { "Cima/baixo - escolher", "A - confirmar", "X - pocoes", "SELECT - mochila" },
  reliquia  = { "Cima/baixo - escolher", "A - ficar com a reliquia" },
  derrota   = { "A - voltar ao menu" },
  historico = { "Cima/baixo - escolher", "B - voltar" },
}

local TITULOS = {
  menu = "MENU", classes = "CLASSES", portas = "PORTAS", explorar = "SALA", combate = "COMBATE",
  loja = "LOJA", inventario = "MOCHILA", pocoes = "POCOES", tesouro = "TESOURO",
  fogueira = "FOGUEIRA", evento = "EVENTO", reliquia = "RELIQUIA", derrota = "DERROTA", historico = "HISTORICO",
}

local GERAL = {
  "START - registo de salas (cima/baixo, L1/R1)",
  "L2 - esta ajuda",
  "A confirma, B cancela, o d-pad move",
}

local nome, fonte

local function nomeDe(est)
  for n, e in pairs(jogo.estados) do
    if e == est then return n end
  end
end

function estado.entrar()
  fonte = fonte or love.graphics.newFont(18)
  -- o ecra de onde vens esta no topo da pilha
  nome = nomeDe(jogo.pilha[#jogo.pilha])
end

function estado.acao(a)
  if a == "cancelar" then jogo.fechar() end
end

function estado.desenhar()
  local normal = love.graphics.getFont()
  love.graphics.setFont(fonte)

  love.graphics.setColor(1, 1, 0.5)
  love.graphics.print("AJUDA - " .. (TITULOS[nome] or "GERAL"), 20, 16)

  love.graphics.setColor(1, 1, 1)
  local linhas = dados[nome] or {}
  for i, texto in ipairs(linhas) do
    love.graphics.print(texto, 30, 56 + (i - 1) * 26)
  end

  local y = 56 + #linhas * 26 + 22
  love.graphics.setColor(0.6, 1, 0.6)
  love.graphics.print("Em qualquer ecra:", 20, y)
  love.graphics.setColor(1, 1, 1)
  for i, texto in ipairs(GERAL) do
    love.graphics.print(texto, 30, y + 28 + (i - 1) * 26)
  end

  love.graphics.setFont(normal)
  love.graphics.print("B ou L2 - fechar", 20, 440)
end

return estado