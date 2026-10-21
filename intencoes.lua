local intencoes = {}

-- Dados: para acrescentar uma intencao, basta uma entrada nova.
-- golpes: multiplicadores do ataque do inimigo (vazio = nao ataca)
-- carrega / descarrega: ligam o "carregar" ao "golpe carregado"
-- texto: o que aparece no painel; acerto: o que aparece na mensagem de dano
intencoes.lista = {
  normal   = { golpes = { 1 }, cor = { 0.8, 0.8, 0.8 },
               texto = "vai atacar", acerto = " causa-te " },

  pesado   = { golpes = { 2 }, descarrega = true, cor = { 1, 0.3, 0.3 },
               texto = "vai desferir o golpe carregado (dano duplo)!",
               acerto = " desfere o golpe carregado e causa-te " },

  carregar = { golpes = {}, carrega = true, cor = { 1, 0.6, 0.2 },
               texto = "está a carregar um golpe forte",
               frase = "levanta a arma bem alto... o próximo golpe vai doer!" },

  duplo    = { golpes = { 0.6, 0.6 }, cor = { 1, 0.85, 0.3 },
               texto = "vai atacar duas vezes", acerto = " golpeia e causa-te " },

  perfurar = { golpes = { 1 }, ignoraDefesa = true, cor = { 0.8, 0.5, 1 },
               texto = "vai atacar ignorando a tua armadura",
               acerto = " perfura a tua armadura e causa-te " },

  curar    = { golpes = {}, cura = 0.15, cor = { 0.5, 1, 0.6 },
               texto = "vai recuperar forças", frase = "recupera forças" },
}

function intencoes.existe(id)
  return intencoes.lista[id] ~= nil
end

return intencoes