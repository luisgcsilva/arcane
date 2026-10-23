local habilidades = {}

-- Dados: para acrescentar uma habilidade, basta uma entrada nova.
-- usar(c) recebe o "contexto" do combate com estas funcoes:
--   c.atacar(mult)  c.curar(n)  c.curarPct(fracao)  c.limparEfeitos()
--   c.atordoar()    c.proteger(fracao)  c.moedas(n)  c.vivo()  c.msg(texto)  c.sala
habilidades.lista = { -- Guerreiro
{
    id = "golpe",
    classe = "guerreiro",
    nome = "Golpe Poderoso",
    cor = {1, 0.6, 0.3},
    cooldown = 3,
    descricao = "Ataque com o dobro do dano.",
    usar = function(c)
        local d = c.atacar(2)
        c.msg("Golpe Poderoso! Causas " .. d .. " de dano.")
    end
}, {
    id = "investida",
    classe = "guerreiro",
    nome = "Investida",
    cor = {1, 0.5, 0.3},
    cooldown = 5,
    descricao = "1,5x de dano e atordoa o inimigo (os chefes resistem 50%).",
    usar = function(c)
        local d = c.atacar(1.5)
        c.msg("Investida! Causas " .. d .. " de dano.")
        c.atordoar()
    end
}, {
    id = "folego",
    classe = "guerreiro",
    nome = "Segundo Fôlego",
    cor = {1, 0.7, 0.4},
    cooldown = 5,
    descricao = "Recuperas 30% da vida máxima.",
    usar = function(c)
        local n = c.curarPct(0.3)
        c.msg("Respiras fundo e recuperas " .. n .. " de vida.")
    end
}, {
    id = "muralha",
    classe = "guerreiro",
    nome = "Muralha",
    cor = {0.8, 0.8, 0.9},
    cooldown = 4,
    descricao = "O próximo golpe do inimigo causa 75% menos dano.",
    usar = function(c)
        c.proteger(0.75)
        c.msg("Ergues a guarda como uma muralha.")
    end
}, -- arqueiro
{
    id = "duplo",
    classe = "arqueiro",
    nome = "Tiro Duplo",
    cor = {0.5, 0.9, 0.6},
    cooldown = 3,
    descricao = "Dois disparos rápidos, cada um com 1.2x de dano.",
    usar = function(c)
        local total = c.atacar(1.2)
        if c.vivo() then
            total = total + c.atacar(1)
        end
        c.msg("Dois disparos rápidos! Causas " .. total .. " de dano.")
    end
}, {
    id = "sujo",
    classe = "arqueiro",
    nome = "Tiro na Perna",
    cor = {0.6, 0.8, 0.5},
    cooldown = 4,
    descricao = "1,5x de dano e atordoa o inimigo (os chefes resistem 50%).",
    usar = function(c)
        local d = c.atacar(1.5)
        c.msg("Tiro na perna! Causas " .. d .. " de dano.")
        c.atordoar()
    end
}, {
    id = "roubo",
    classe = "arqueiro",
    nome = "Saque",
    cor = {1, 0.85, 0.2},
    cooldown = 4,
    descricao = "Dano 1.25x e roubas moedas ao inimigo.",
    usar = function(c)
        local d = c.atacar(1.25)
        local n = math.random(5, 10) + c.sala
        c.moedas(n)
        c.msg("Causas " .. d .. " de dano e roubas " .. n .. " moedas.")
    end
}, {
    id = "esquiva",
    classe = "arqueiro",
    nome = "Esquiva",
    cor = {0.5, 0.8, 0.9},
    cooldown = 5,
    descricao = "Evitas por completo o próximo golpe do inimigo.",
    usar = function(c)
        c.proteger(1)
        c.msg("Preparas-te para esquivar o próximo golpe.")
    end
}, -- cavaleiro
{
    id = "carga",
    classe = "cavaleiro",
    nome = "Carga",
    cor = {0.8, 0.8, 0.95},
    cooldown = 5,
    descricao = "1,8x de dano e atordoa o inimigo (os chefes resistem 50%).",
    usar = function(c)
        local d = c.atacar(1.8)
        c.msg("Carga! Causas " .. d .. " de dano.")
        c.atordoar()
    end
}, {
    id = "lanca",
    classe = "cavaleiro",
    nome = "Estocada",
    cor = {0.9, 0.9, 1},
    cooldown = 3,
    descricao = "Ataque com 2,2x de dano.",
    usar = function(c)
        local d = c.atacar(2.2)
        c.msg("Estocada! Causas " .. d .. " de dano.")
    end
}, {
    id = "bastiao",
    classe = "cavaleiro",
    nome = "Bastião",
    cor = {0.7, 0.8, 0.9},
    cooldown = 5,
    descricao = "O próximo golpe do inimigo causa 80% menos dano.",
    usar = function(c)
        c.proteger(0.8)
        c.msg("Firmas-te atrás do escudo.")
    end
}, {
    id = "juramento",
    classe = "cavaleiro",
    nome = "Juramento",
    cor = {1, 0.9, 0.5},
    cooldown = 5,
    descricao = "Recuperas 35% da vida máxima. Limpa veneno e sangramento.",
    usar = function(c)
        local n = c.curarPct(0.35)
        local e = c.limparEfeitos()
        c.msg("Recuperas " .. n .. " de vida." .. (e > 0 and " Os males desaparecem." or ""))
    end
}, -- Mago
{
    id = "bola",
    classe = "mago",
    nome = "Bola de Fogo",
    cor = {1, 0.45, 0.2},
    cooldown = 4,
    descricao = "Ataque com 2,5x de dano.",
    usar = function(c)
        local d = c.atacar(2.5)
        c.msg("Bola de fogo! Causas " .. d .. " de dano.")
    end
}, {
    id = "escudo",
    classe = "mago",
    nome = "Escudo Arcano",
    cor = {0.6, 0.7, 1},
    cooldown = 5,
    descricao = "O próximo golpe causa 60% menos dano. Limpa veneno e sangramento.",
    usar = function(c)
        c.proteger(0.6)
        local n = c.limparEfeitos()
        c.msg("Um escudo arcano envolve-te." .. (n > 0 and " Os males desaparecem." or ""))
    end
}, {
    id = "cura",
    classe = "mago",
    nome = "Cura Arcana",
    cor = {0.5, 1, 0.8},
    cooldown = 5,
    descricao = "Recuperas 40% da vida máxima. Limpa veneno e sangramento.",
    usar = function(c)
        local n = c.curarPct(0.4)
        local e = c.limparEfeitos()
        c.msg("Recuperas " .. n .. " de vida." .. (e > 0 and " Os males desaparecem." or ""))
    end
}, {
    id = "drenar",
    classe = "mago",
    nome = "Drenar Vida",
    cor = {0.8, 0.4, 0.9},
    cooldown = 3,
    descricao = "1,2x de dano, e recuperas metade do dano causado.",
    usar = function(c)
        local d = c.atacar(1.2)
        local n = c.curar(math.floor(d / 2))
        c.msg("Drenas " .. d .. " de vida ao inimigo e recuperas " .. n .. ".")
    end
}}

function habilidades.porId(id)
    for _, h in ipairs(habilidades.lista) do
        if h.id == id then
            return h
        end
    end
end

function habilidades.existe(id)
    return habilidades.porId(id) ~= nil
end

local ICONES = {
    golpe = 728,
    investida = 885,
    folego = 659,
    muralha = 853,
    duplo = 721,
    sujo = 673,
    roubo = 158,
    esquiva = 891,
    bola = 993,
    escudo = 856,
    cura = 709,
    drenar = 676,
    carga = 885,
    lanca = 728,
    bastiao = 853,
    juramento = 709
}

function habilidades.caminhoIcone(h)
    local n = ICONES[h.id]
    return n and ("imagens/itens/fa" .. n .. ".png") or nil
end

return habilidades
