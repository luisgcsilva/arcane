return {
    slime = {
        nome = "Slime",
        vida = 6,
        ataque = 2,
        minSala = 1,
        biomas = {"cavernas", "pantano"},
        cor = {0.4, 0.9, 0.4}
    },
    creeper = {
        nome = "Creeper",
        vida = 8,
        ataque = 5,
        minSala = 1,
        biomas = {"cavernas"},
        cor = {0.2, 0.8, 0.4}
    },
    goblin = {
        nome = "Goblin",
        vida = 10,
        ataque = 3,
        minSala = 3,
        biomas = {"cavernas, fortaleza"},
        cor = {0.2, 0.6, 0.2},
        padrao = {"normal", "normal", "duplo"}
    },
    zombie = {
        nome = "Zombie",
        vida = 12,
        ataque = 3,
        minSala = 3,
        biomas = {"pantano", "catacumbas"},
        cor = {0.5, 0.5, 0.5},
        efeito = {
            id = "veneno",
            chance = 0.25
        },
        padrao = {"normal", "curar", "normal"}
    },
    esqueleto = {
        nome = "Esqueleto",
        vida = 14,
        ataque = 4,
        minSala = 5,
        biomas = {"catacumbas", "fortaleza"},
        cor = {0.9, 0.9, 0.9},
        padrao = {"normal", "normal", "carregar"}
    },
    espectro = {
        nome = "Espectro",
        vida = 18,
        ataque = 7,
        minSala = 7,
        biomas = {"catacumbas", "torre", "tundra", "abismo"},
        cor = {0.6, 0.6, 0.6},
        padrao = {"normal", "perfurar"}
    },
    troll = {
        nome = "Troll",
        vida = 20,
        ataque = 5,
        minSala = 9,
        biomas = {"cavernas", "pantano", "fortaleza"},
        cor = {0.3, 0.3, 0.3}
    },
    orc = {
        nome = "Orc",
        vida = 22,
        ataque = 5,
        minSala = 12,
        biomas = {"pantano", "fortaleza"},
        cor = {0.7, 0.2, 0.2},
        padrao = {"normal", "carregar"}
    },
    morcego = {
        nome = "Morcego",
        vida = 8,
        ataque = 3,
        minSala = 2,
        biomas = {"cavernas", "pantano", "catacumbas"},
        cor = {0.6, 0.5, 0.7},
        efeito = {
            id = "sangramento",
            chance = 0.30
        },
        padrao = {"duplo", "normal"}
    },
    aranha = {
        nome = "Aranha Gigante",
        vida = 12,
        ataque = 5,
        minSala = 4,
        biomas = {"cavernas", "pantano"},
        cor = {0.7, 0.3, 0.3},
        efeito = {
            id = "veneno",
            chance = 0.40
        },
        padrao = {"normal", "duplo"}
    },
    bruxa = {
        nome = "Bruxa",
        vida = 16,
        ataque = 9,
        minSala = 8,
        biomas = {"pantano", "catacumbas", "torre", "tundra", "afundada"},
        cor = {0.75, 0.4, 0.9},
        efeito = {
            id = "veneno",
            chance = 0.35
        },
        padrao = {"perfurar", "perfurar", "normal"}
    },
    golem = {
        nome = "Golem de Pedra",
        vida = 40,
        ataque = 6,
        minSala = 9,
        biomas = {"fortaleza", "torre", "vulcao", "abismo"},
        cor = {0.65, 0.6, 0.55},
        efeito = {
            id = "atordoamento",
            chance = 0.20
        },
        padrao = {"normal", "carregar"}
    },
    cavaleiro = {
        nome = "Cavaleiro Negro",
        vida = 30,
        ataque = 9,
        minSala = 12,
        biomas = {"fortaleza", "torre", "abismo", "trono"},
        cor = {0.5, 0.5, 0.6},
        efeito = {
            id = "sangramento",
            chance = 0.30
        },
        padrao = {"normal", "duplo", "carregar"}
    },
    demonio = {
        nome = "Demonio Menor",
        vida = 34,
        ataque = 11,
        minSala = 15,
        biomas = {"vulcao", "abismo"},
        cor = {1, 0.3, 0.2},
        padrao = {"perfurar", "normal", "duplo", "normal"}
    },
    rato = { -- cavernas
        nome = "Rato Gigante",
        vida = 7,
        ataque = 3,
        minSala = 1,
        biomas = {"cavernas"},
        cor = {0.6, 0.5, 0.4},
        efeito = {
            id = "sangramento",
            chance = 0.20
        },
        padrao = {"normal", "duplo"}
    },
    sapo = { -- pantano
        nome = "Sapo Venenoso",
        vida = 14,
        ataque = 4,
        minSala = 6,
        biomas = {"pantano"},
        cor = {0.3, 0.85, 0.5},
        efeito = {
            id = "veneno",
            chance = 0.50
        },
        padrao = {"normal", "normal", "carregar"}
    },
    ghoul = { -- catacumbas
        nome = "Ghoul",
        vida = 26,
        ataque = 7,
        minSala = 11,
        biomas = {"catacumbas", "afundada"},
        cor = {0.55, 0.7, 0.5},
        efeito = {
            id = "veneno",
            chance = 0.30
        },
        padrao = {"normal", "duplo", "normal"}
    },
    necromante = { -- catacumbas
        nome = "Necromante",
        vida = 20,
        ataque = 8,
        minSala = 14,
        biomas = {"catacumbas", "afundada", "torre"},
        cor = {0.5, 0.3, 0.7},
        padrao = {"curar", "perfurar", "normal"}
    },
    arqueiro = { -- fortaleza
        nome = "Arqueiro Orc",
        vida = 18,
        ataque = 8,
        minSala = 12,
        biomas = {"fortaleza"},
        cor = {0.8, 0.5, 0.3},
        padrao = {"carregar", "normal", "normal"}
    },
    guarda = { -- fortaleza
        nome = "Guarda de Ferro",
        vida = 38,
        ataque = 7,
        minSala = 14,
        biomas = {"fortaleza", "trono", "torre"},
        cor = {0.6, 0.7, 0.8},
        efeito = {
            id = "atordoamento",
            chance = 0.15
        },
        padrao = {"normal", "carregar"}
    },
    elemental = { -- torre
        nome = "Elemental de Fogo",
        vida = 28,
        ataque = 12,
        minSala = 25,
        biomas = {"vulcao"},
        cor = {1, 0.55, 0.15},
        efeito = {
            id = "sangramento",
            chance = 0.35
        },
        padrao = {"perfurar", "normal", "duplo"}
    },
    devorador = { -- abismo
        nome = "Devorador de Almas",
        vida = 44,
        ataque = 15,
        minSala = 40,
        biomas = {"abismo", "trono"},
        cor = {0.7, 0.2, 0.5},
        padrao = {"perfurar", "duplo", "curar"}
    },
    lobo = {
        nome = "Lobo Gelado",
        vida = 30,
        ataque = 9,
        minSala = 51,
        biomas = {"tundra"},
        cor = {0.7, 0.85, 1},
        efeito = {
            id = "sangramento",
            chance = 0.35
        },
        padrao = {"duplo", "normal", "normal"}
    },
    yeti = {
        nome = "Yeti",
        vida = 52,
        ataque = 8,
        minSala = 51,
        biomas = {"tundra"},
        cor = {0.85, 0.95, 1},
        efeito = {
            id = "atordoamento",
            chance = 0.12
        },
        padrao = {"normal", "carregar"}
    },
    bruxa_neve = {
        nome = "Bruxa da Neve",
        vida = 26,
        ataque = 11,
        minSala = 51,
        biomas = {"tundra"},
        cor = {0.5, 0.75, 1},
        efeito = {
            id = "atordoamento",
            chance = 0.12
        },
        padrao = {"perfurar", "normal", "normal"}
    },
    salamandra = {
        nome = "Salamandra",
        vida = 34,
        ataque = 13,
        minSala = 61,
        biomas = {"vulcao"},
        cor = {1, 0.45, 0.15},
        efeito = {
            id = "sangramento",
            chance = 0.40
        },
        padrao = {"duplo", "normal", "carregar"}
    },
    golem_magma = {
        nome = "Golem de Magma",
        vida = 66,
        ataque = 11,
        minSala = 61,
        biomas = {"vulcao"},
        cor = {0.9, 0.35, 0.1},
        efeito = {
            id = "atordoamento",
            chance = 0.25
        },
        padrao = {"normal", "carregar"}
    },
    afogado = {
        nome = "Afogado",
        vida = 48,
        ataque = 12,
        minSala = 71,
        biomas = {"afundada"},
        cor = {0.35, 0.65, 0.6},
        efeito = {
            id = "veneno",
            chance = 0.35
        },
        padrao = {"normal", "duplo", "normal"}
    },
    sereia = {
        nome = "Sereia",
        vida = 36,
        ataque = 14,
        minSala = 71,
        biomas = {"afundada"},
        cor = {0.4, 0.85, 0.9},
        padrao = {"curar", "perfurar", "normal"}
    },
    gargula = {
        nome = "Gargula",
        vida = 70,
        ataque = 13,
        minSala = 81,
        biomas = {"abismo", "trono"},
        cor = {0.55, 0.5, 0.6},
        efeito = {
            id = "atordoamento",
            chance = 0.20
        },
        padrao = {"normal", "carregar", "normal"}
    },
    demonio_maior = {
        nome = "Demonio Maior",
        vida = 52,
        ataque = 17,
        minSala = 81,
        biomas = {"abismo", "trono"},
        cor = {0.9, 0.15, 0.2},
        padrao = {"perfurar", "normal", "duplo", "carregar"}
    },
    sombra = {
        nome = "Sombra",
        vida = 40,
        ataque = 16,
        minSala = 81,
        biomas = {"abismo", "trono"},
        cor = {0.35, 0.3, 0.45},
        efeito = {
            id = "sangramento",
            chance = 0.30
        },
        padrao = {"duplo", "perfurar"}
    },
    sentinela = {
        nome = "Sentinela Eterna",
        vida = 80,
        ataque = 15,
        minSala = 91,
        biomas = {"trono"},
        cor = {1, 0.9, 0.5},
        efeito = {
            id = "atordoamento",
            chance = 0.25
        },
        padrao = {"normal", "carregar", "duplo"}
    },
    cavaleiro_morte = {
        nome = "Cavaleiro da Morte",
        vida = 60,
        ataque = 19,
        minSala = 91,
        biomas = {"trono"},
        cor = {0.4, 0.4, 0.5},
        efeito = {
            id = "sangramento",
            chance = 0.40
        },
        padrao = {"duplo", "perfurar", "carregar"}
    },

    -- chefes
    rei_goblin = {
        nome = "Rei Goblin",
        vida = 40,
        ataque = 7,
        minSala = 10,
        boss = true,
        biomas = {"cavernas"},
        cor = {0.2, 0.2, 0.8},
        padrao = {"normal", "duplo", "carregar"}
    },
    rei_troll = {
        nome = "Rei Troll",
        vida = 70,
        ataque = 12,
        minSala = 20,
        boss = true,
        biomas = {"pantano"},
        cor = {0.8, 0.2, 0.2},
        padrao = {"normal", "carregar", "normal", "duplo"}
    },
    senhor_osso = {
        nome = "Senhor dos Ossos",
        vida = 120,
        ataque = 14,
        minSala = 30,
        boss = true,
        biomas = {"catacumbas"},
        cor = {0.8, 0.8, 0.8},
        padrao = {"normal", "perfurar", "carregar", "curar"}
    },
    dragao = {
        nome = "Dragao Arcano",
        vida = 200,
        ataque = 19,
        minSala = 40,
        boss = true,
        biomas = {"torre"},
        cor = {0.8, 0.4, 0.1},
        padrao = {"normal", "duplo", "carregar", "perfurar"}
    },
    lich = {
        nome = "Lich Eterno",
        vida = 300,
        ataque = 25,
        minSala = 50,
        boss = true,
        biomas = {"tundra"},
        cor = {0.3, 1, 0.8},
        padrao = {"perfurar", "curar", "carregar", "duplo"}
    },
    aranha_rainha = {
        nome = "Aranha Rainha",
        vida = 45,
        ataque = 8,
        minSala = 10,
        boss = true,
        biomas = {"cavernas"},
        cor = {0.7, 0.2, 0.4},
        efeito = {
            id = "veneno",
            chance = 0.50
        },
        padrao = {"normal", "duplo", "carregar"}
    },
    hidra = {
        nome = "Hidra do Pantano",
        vida = 80,
        ataque = 11,
        minSala = 20,
        boss = true,
        biomas = {"pantano"},
        cor = {0.3, 0.7, 0.4},
        efeito = {
            id = "veneno",
            chance = 0.40
        },
        padrao = {"duplo", "normal", "duplo", "carregar"}
    },
    campeao = {
        nome = "Campeao Caido",
        vida = 130,
        ataque = 15,
        minSala = 30,
        boss = true,
        biomas = {"fortaleza"},
        cor = {0.6, 0.6, 0.7},
        efeito = {
            id = "sangramento",
            chance = 0.40
        },
        padrao = {"normal", "carregar", "duplo", "perfurar"}
    },
    arquimago = {
        nome = "Arquimago Corrompido",
        vida = 190,
        ataque = 20,
        minSala = 40,
        boss = true,
        biomas = {"torre"},
        cor = {0.7, 0.4, 1},
        efeito = {
            id = "atordoamento",
            chance = 0.25
        },
        padrao = {"perfurar", "perfurar", "curar", "carregar"}
    },
    banshee = {
        nome = "Rainha Banshee",
        vida = 110,
        ataque = 16,
        minSala = 30,
        boss = true,
        biomas = {"catacumbas"},
        cor = {0.7, 0.8, 1},
        padrao = {"perfurar", "perfurar", "carregar", "curar"}
    },
    general_orc = {
        nome = "General Orc",
        vida = 150,
        ataque = 15,
        minSala = 40,
        boss = true,
        biomas = {"fortaleza"},
        cor = {0.6, 0.3, 0.2},
        efeito = {
            id = "sangramento",
            chance = 0.30
        },
        padrao = {"normal", "duplo", "carregar", "duplo"}
    },
    gigante_gelo = {
        nome = "Gigante de Gelo",
        vida = 320,
        ataque = 22,
        minSala = 60,
        boss = true,
        biomas = {"tundra"},
        cor = {0.7, 0.9, 1},
        efeito = {
            id = "atordoamento",
            chance = 0.25
        },
        padrao = {"normal", "carregar", "normal", "duplo"}
    },
    colosso = {
        nome = "Colosso de Magma",
        vida = 380,
        ataque = 28,
        minSala = 70,
        boss = true,
        biomas = {"vulcao"},
        cor = {1, 0.4, 0.1},
        efeito = {
            id = "sangramento",
            chance = 0.35
        },
        padrao = {"normal", "carregar", "normal", "perfurar"}
    },
    fenix = {
        nome = "Fenix Sombria",
        vida = 340,
        ataque = 31,
        minSala = 70,
        boss = true,
        biomas = {"vulcao"},
        cor = {0.9, 0.2, 0.5},
        padrao = {"duplo", "perfurar", "curar", "carregar"}
    },
    rei_afogado = {
        nome = "Rei Afogado",
        vida = 440,
        ataque = 32,
        minSala = 80,
        boss = true,
        biomas = {"afundada"},
        cor = {0.3, 0.7, 0.7},
        efeito = {
            id = "veneno",
            chance = 0.40
        },
        padrao = {"normal", "duplo", "carregar", "curar"}
    },
    kraken = {
        nome = "Kraken",
        vida = 480,
        ataque = 30,
        minSala = 80,
        boss = true,
        biomas = {"afundada"},
        cor = {0.5, 0.3, 0.7},
        padrao = {"duplo", "duplo", "carregar", "perfurar"}
    },
    senhor_abismo = {
        nome = "Senhor do Abismo",
        vida = 520,
        ataque = 36,
        minSala = 90,
        boss = true,
        biomas = {"abismo"},
        cor = {1, 0.2, 0.3},
        padrao = {"perfurar", "duplo", "carregar", "curar"}
    },
    arauto = {
        nome = "Arauto do Fim",
        vida = 500,
        ataque = 38,
        minSala = 90,
        boss = true,
        biomas = {"abismo"},
        cor = {0.6, 0.1, 0.4},
        efeito = {
            id = "sangramento",
            chance = 0.40
        },
        padrao = {"perfurar", "perfurar", "carregar", "duplo"}
    },
    imperador = {
        nome = "Imperador Eterno",
        vida = 650,
        ataque = 42,
        minSala = 100,
        boss = true,
        biomas = {"trono"},
        cor = {1, 0.85, 0.3},
        padrao = {"normal", "perfurar", "carregar", "duplo", "curar"}
    },
    anjo = {
        nome = "Anjo Caido",
        vida = 600,
        ataque = 45,
        minSala = 100,
        boss = true,
        biomas = {"trono"},
        cor = {0.95, 0.95, 1},
        efeito = {
            id = "atordoamento",
            chance = 0.30
        },
        padrao = {"duplo", "perfurar", "carregar", "curar"}
    }

}
