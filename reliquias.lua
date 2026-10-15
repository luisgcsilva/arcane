local reliquias = {}

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
