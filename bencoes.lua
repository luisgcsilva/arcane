local bencoes = {}

local BRANCO = {1, 1, 1}

bencoes.DURACAO = 5 -- salas
bencoes.OFERTA = 3 -- quantas aparecem no santuario

local function colorida(b, resto)
    return {BRANCO, "", b.cor, b.nome, BRANCO.resto}
end

-- mods: somados pelo jogador.bonus (ataque_pct e defesa_pct sao percentagens)
-- custo: "vida" (pct da vida maxima) ou "moedas" (base + porSala * sala)
bencoes.lista = {{
    id = "furia",
    nome = "Furia",
    cor = {1, 0.4, 0.3},
    descricao = "+25% de ataque durante 5 salas.",
    mods = {
        ataque_pct = 0.25
    },
    custo = {
        tipo = "vida",
        pct = 0.2
    }
}, {
    id = "muralha",
    nome = "Muralha",
    cor = {0.5, 0.7, 1},
    descricao = "+30% de defesa durante 5 salas.",
    mods = {
        defesa_pct = 0.3
    },
    custo = {
        tipo = "moedas",
        base = 30,
        porSala = 4
    }
}, {
    id = "fortuna",
    nome = "Fortuna",
    cor = {1, 0.85, 0.2},
    descricao = "+60% de moedas dos inimigos durante 5 salas.",
    mods = {
        moedas = 0.6
    },
    custo = {
        tipo = "vida",
        pct = 0.15
    }
}, {
    id = "passoleve",
    nome = "Passo Leve",
    cor = {0.7, 0.6, 1},
    descricao = "+30% de chance de fugir durante 5 salas.",
    mods = {
        fuga = 0.3
    },
    custo = {
        tipo = "moedas",
        base = 20,
        porSala = 3
    }
}, {
    id = "vigor",
    nome = "Vigor",
    cor = {0.4, 1, 0.5},
    descricao = "Recuperas 40% da vida maxima agora.",
    instantanea = true,
    custo = {
        tipo = "moedas",
        base = 40,
        porSala = 6
    },
    aoEscolher = function(j)
        local cura = math.min(math.ceil(j.vida_max * 0.4), j.vida_max - j.vida)
        j.vida = j.vida + cura
        return cura
    end
}}

function bencoes.porId(id)
    for _, b in ipairs(bencoes.lista) do
        if b.id == id then
            return b
        end
    end
end

function bencoes.existe(id)
    return bencoes.porId(id) ~= nil
end

function bencoes.custoDe(b, j, fator)
    fator = fator or 1
    local c = b.custo
    if c.tipo == "vida" then
        return "vida", math.max(1, math.floor(j.vida_max * c.pct * fator))
    end
    return "moedas", math.max(1, math.floor((c.base + c.porSala * j.sala) * fator))
end

function bencoes.podePagar(b, j, fator)
    local tipo, valor = bencoes.custoDe(b, j, fator)
    if tipo == "vida" then
        return j.vida - valor >= 1
    end
    return j.moedas >= valor
end

function bencoes.aplicar(b, j, fator)
    if not bencoes.podePagar(b, j, fator) then
        local tipo = bencoes.custoDe(b, j, fator)
        return false, (tipo == "vida") and "Estas demasiado fraco para esta bencao." or "Moedas insuficientes."
    end
    local tipo, valor = bencoes.custoDe(b, j, fator)
    if tipo == "vida" then
        j.vida = j.vida - valor
    else
        j.moedas = j.moedas - valor
    end

    if b.instantanea then
        local cura = b.aoEscolher(j)
        local resto = ": recuperas " .. cura .. " de vida."
        return true, b.nome .. resto, colorida(b, resto)
    end

    local substitui = (j.bencao ~= nil)
    -- +1 porque abrir a porta seguinte gasta logo uma sala
    j.bencao = {
        id = b.id,
        restantes = bencoes.DURACAO + 1
    }
    local resto = " abencoa-te durante " .. bencoes.DURACAO .. " salas." ..
                      (substitui and " (a bencao anterior perde-se)" or "")
    return true, b.nome .. resto, colorida(b, resto)
end

-- Sorteia n bencoes diferentes (devolve os ids)
function bencoes.sortearOferta(n)
    local pool = {}
    for _, b in ipairs(bencoes.lista) do
        table.insert(pool, b.id)
    end
    local oferta = {}
    for _ = 1, math.min(n, #pool) do
        table.insert(oferta, table.remove(pool, math.random(#pool)))
    end
    return oferta
end

return bencoes
