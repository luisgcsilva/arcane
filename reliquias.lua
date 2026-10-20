local reliquias = {}

local ICONES = {
    bolsa = 158,
    anel = 1845,
    frasco = 123,
    espinhos = 1813,
    pedra = 217,
    carvalho = 2113,
    coracao = 595,
    botas = 1855,
    cruz = 670,
    amuleto = 2065,
    placa = 1932,
    coracao_troll = 659,
    regeneracao = 1847,
    avarento = 1836,
    espinhos_maior = 2050,
    elmo = 1906,
    ancestral = 1735,
    tita = 322
}

function reliquias.caminhoIcone(r)
    local n = ICONES[r.id]
    return n and ("imagens/itens/fa" .. n .. ".png") or nil
end

-- Dados: para acrescentar uma reliquia, basta uma entrada nova.
-- mods: valores que o jogo soma (moedas, ataque, defesa, fuga, espinhos).
-- aoObter / aoVencer: funcoes opcionais que recebem o jogador.
reliquias.lista = {{
    id = "bolsa",
    nome = "Bolsa Encantada",
    cor = {1, 0.85, 0.2},
    preco = 60,
    descricao = "+15% de moedas dos inimigos.",
    mods = {
        moedas = 0.15
    }
}, {
    id = "anel",
    nome = "Anel de Vida",
    cor = {1, 0.5, 0.6},
    preco = 70,
    descricao = "Curas 2 de vida depois de cada combate vencido.",
    aoVencer = function(j)
        local cura = math.min(2, j.vida_max - j.vida)
        if cura <= 0 then
            return nil
        end
        j.vida = j.vida + cura
        return "Anel de Vida: recuperas " .. cura .. " de vida."
    end
}, {
    id = "frasco",
    nome = "Frasco Infinito",
    cor = {0.4, 0.9, 1},
    preco = 90,
    descricao = "A primeira pocao de cada combate nao se gasta."
}, {
    id = "espinhos",
    nome = "Escudo Espinhoso",
    cor = {0.9, 0.6, 0.3},
    preco = 80,
    descricao = "Cada vez que levas dano, o inimigo perde 2 de vida (sem o matar).",
    mods = {
        espinhos = 2
    }
}, {
    id = "pedra",
    nome = "Pedra de Amolar",
    cor = {0.8, 0.8, 0.9},
    preco = 90,
    descricao = "+2 de ataque.",
    mods = {
        ataque = 2
    }
}, {
    id = "carvalho",
    nome = "Escudo de Carvalho",
    cor = {0.6, 0.45, 0.25},
    preco = 70,
    descricao = "+1 de defesa.",
    mods = {
        defesa = 1
    }
}, {
    id = "coracao",
    nome = "Coracao de Pedra",
    cor = {0.75, 0.75, 0.8},
    preco = 100,
    descricao = "+10 de vida maxima.",
    aoObter = function(j)
        j.vida_max = j.vida_max + 10
        j.vida = j.vida + 10
    end
}, {
    id = "botas",
    nome = "Botas Leves",
    cor = {0.5, 0.9, 0.6},
    preco = 60,
    descricao = "+20% de chance de fugir.",
    mods = {
        fuga = 0.2
    }
}, {
    id = "cruz",
    nome = "Cruz Sagrada",
    cor = {1, 1, 0.75},
    preco = 130,
    descricao = "Uma vez por partida, sobrevives a um golpe fatal e ficas com 1 de vida."
}, {
    id = "amuleto",
    nome = "Amuleto do Guerreiro",
    cor = {1, 0.4, 0.3},
    preco = 130,
    descricao = "+3 de ataque.",
    mods = {
        ataque = 3
    }
}, {
    id = "placa",
    nome = "Placa de Dragao",
    cor = {0.9, 0.5, 0.2},
    preco = 130,
    descricao = "+2 de defesa.",
    mods = {
        defesa = 2
    }
}, {
    id = "coracao_troll",
    nome = "Coracao de Troll",
    cor = {0.4, 0.7, 0.4},
    preco = 150,
    descricao = "+20 de vida maxima.",
    aoObter = function(j)
        j.vida_max = j.vida_max + 20
        j.vida = j.vida + 20
    end
}, {
    id = "regeneracao",
    nome = "Anel da Regeneracao",
    cor = {1, 0.6, 0.8},
    preco = 140,
    descricao = "Curas 5 de vida depois de cada combate vencido.",
    aoVencer = function(j)
        local cura = math.min(5, j.vida_max - j.vida)
        if cura <= 0 then
            return nil
        end
        j.vida = j.vida + cura
        return "Anel da Regeneracao: recuperas " .. cura .. " de vida."
    end
}, {
    id = "avarento",
    nome = "Coroa do Avarento",
    cor = {1, 0.9, 0.3},
    preco = 110,
    descricao = "+30% de moedas dos inimigos.",
    mods = {
        moedas = 0.3
    }
}, {
    id = "espinhos_maior",
    nome = "Armadura de Espinhos",
    cor = {0.8, 0.45, 0.2},
    preco = 130,
    descricao = "Cada vez que levas dano, o inimigo perde mais 4 de vida (sem o matar).",
    mods = {
        espinhos = 4
    }
}, {
    id = "elmo",
    nome = "Elmo do Veterano",
    cor = {0.7, 0.75, 0.85},
    preco = 120,
    descricao = "+1 de defesa e +10 de vida maxima.",
    mods = {
        defesa = 1
    },
    aoObter = function(j)
        j.vida_max = j.vida_max + 10
        j.vida = j.vida + 10
    end
}, {
    id = "ancestral",
    nome = "Lamina Ancestral",
    cor = {0.85, 0.85, 1},
    preco = 150,
    descricao = "+2 de ataque e +1 de defesa.",
    mods = {
        ataque = 2,
        defesa = 1
    }
}, {
    id = "tita",
    nome = "Pedra do Tita",
    cor = {1, 0.3, 0.3},
    preco = 220,
    descricao = "+5 de ataque.",
    mods = {
        ataque = 5
    }
}}

function reliquias.porId(id)
    for _, r in ipairs(reliquias.lista) do
        if r.id == id then
            return r
        end
    end
end

function reliquias.existe(id)
    return reliquias.porId(id) ~= nil
end

return reliquias
