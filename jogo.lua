local jogo = {}
local cores = require("cores")

jogo.estados = {}
jogo.atual = nil
jogo.pilha = {}

function jogo.registar(nome, estado)
  jogo.estados[nome] = estado
end

function jogo.mudar(nome, ...)
  jogo.atual = jogo.estados[nome]
  if jogo.atual.entrar then
    jogo.atual.entrar(...)
  end
end

-- abre um estado "por cima": guarda o actual para poder voltar
function jogo.abrir(nome, ...)
  table.insert(jogo.pilha, jogo.atual)
  jogo.mudar(nome, ...)
end

-- volta ao estado anterior sem chamar entrar
function jogo.fechar()
  jogo.atual = table.remove(jogo.pilha)
end

return jogo