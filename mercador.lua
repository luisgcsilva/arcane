local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")
local reliquias = require("reliquias")

local mercador = {}

local SLOTS = {"arma", "arma", "armadura", "armadura"}
local VALOR_BASE_FORJA = 150

mercador.stock = {}

mercador.TREINO = {
    vida = {
        nome = "Treino de vida",
        base = 120,
        passo = 40,
        ganho = 5,
        texto = "vida maxima",
        icone = 659
    },
    ataque = {
        nome = "Treino de ataque",
        base = 400,
        passo = VALOR_BASE_FORJA,
        ganho = 1,
        texto = "ataque",
        icone = 657
    },
    defesa = {
        nome = "Treino de defesa",
        base = 400,
        passo = VALOR_BASE_FORJA,
        ganho = 1,
        texto = "defesa",
        icone = 664
    }
}
local ORDEM_TREINO = {"vida", "ataque", "defesa"}

-- O preco sobe a cada compra: base + passo * quantas vezes ja compraste
function mercador.precoTreino(atributo)
    local t = mercador.TREINO[atributo]
    return t.base + t.passo * jogador.treino[atributo]
end

-- Chamada uma vez, ao entrar na sala da loja
function mercador.gerar(sala)
    mercador.stock = {}
    local nomes = {} -- nomes ja na loja, para nao repetir

    for _, tipo in ipairs(SLOTS) do
        local item
        for _ = 1, 60 do -- tenta 30 vezes encontrar um que ainda nao exista
            item = loot.sortear(sala)
            if item.tipo == tipo and not nomes[item.nome] then
                break
            end
        end
        nomes[item.nome] = true
        table.insert(mercador.stock, {
            tipo = "item",
            item = item,
            preco = loot.valor(item)
        })
    end

    local exclusivo = loot.exclusivo()
    table.insert(mercador.stock, {
        tipo = "item",
        item = exclusivo,
        preco = loot.valor(exclusivo)
    })

    local pool = jogador.reliquiasDisponiveis()
    if #pool > 0 then
        local r = pool[math.random(#pool)]
        table.insert(mercador.stock, {
            tipo = "reliquia",
            reliquia = r,
            preco = r.preco
        })
    end

    for _, p in ipairs(pocoes.lista) do
        table.insert(mercador.stock, {
            tipo = "pocao",
            pocao = p,
            preco = p.preco
        })
    end

    for _, slot in ipairs({"arma", "armadura"}) do
        table.insert(mercador.stock, {
            tipo = "forja",
            slot = slot,
            preco = 0
        })
    end

    for _, atributo in ipairs(ORDEM_TREINO) do
        table.insert(mercador.stock, {
            tipo = "treino",
            atributo = atributo,
            preco = 0
        })
    end

    mercador.atualizar()
end

function mercador.nomeDe(e)
    if e.tipo == "item" then
        return e.item.nome
    end
    if e.tipo == "reliquia" then
        return e.reliquia.nome
    end
    if e.tipo == "forja" then
        return (e.slot == "arma") and "Afiar a arma" or "Reforcar a armadura"
    end
    if e.tipo == "treino" then
        return mercador.TREINO[e.atributo].nome
    end
    return e.pocao.nome
end

-- Devolve true/false e uma mensagem para mostrar
function mercador.comprar(i)
    local e = mercador.stock[i]
    if e.vendido then
        return false, "Esse ja nao esta disponivel."
    end

    if e.tipo == "forja" then
        return mercador.forjar(e)
    end

    if e.tipo == "treino" then
        return mercador.treinar(e)
    end

    if jogador.moedas < e.preco then
        return false, "Moedas insuficientes."
    end

    if e.tipo == "item" then
        if not jogador.guardar(e.item) then
            return false, "Mochila cheia! Vende algo primeiro.", "mochila"
        end
        e.vendido = true
    elseif e.tipo == "reliquia" then
        jogador.darReliquia(e.reliquia.id)
        e.vendido = true
    else
        jogador.darPocao(e.pocao.id)
    end

    jogador.moedas = jogador.moedas - e.preco
    return true, "Compraste " .. mercador.nomeDe(e) .. "."
end

mercador.MAX_FORJA = {
    arma = 20,
    armadura = 16
}

function mercador.precoForja(slot)
    if not jogador[slot] then
        return nil
    end
    return VALOR_BASE_FORJA + 50 * jogador.forja[slot]
end

-- Os precos do ferreiro dependem do que tens equipado, por isso recalculam-se
function mercador.atualizar()
    for _, e in ipairs(mercador.stock) do
        if e.tipo == "forja" then
            e.preco = mercador.precoForja(e.slot) or 0
        elseif e.tipo == "treino" then
            e.preco = mercador.precoTreino(e.atributo)
        end
    end
end

function mercador.forjar(e)
    mercador.atualizar()
    local item = jogador[e.slot]
    if not item then
        return false, "Nao tens nada equipado nessa ranhura."
    end
    if jogador.forja[e.slot] >= mercador.MAX_FORJA[e.slot] then
        return false, "O ferreiro ja nao consegue melhorar mais."
    end
    if jogador.moedas < e.preco then
        return false, "Moedas insuficientes."
    end
    jogador.moedas = jogador.moedas - e.preco
    jogador.forja[e.slot] = jogador.forja[e.slot] + 1
    mercador.atualizar()
    return true, item.nome .. " agora e " .. jogador.textoBonus(item) .. "."
end

function mercador.treinar(e)
    mercador.atualizar()
    if jogador.moedas < e.preco then
        return false, "Moedas insuficientes."
    end
    local t = mercador.TREINO[e.atributo]
    jogador.moedas = jogador.moedas - e.preco
    jogador.treino[e.atributo] = jogador.treino[e.atributo] + 1
    if e.atributo == "vida" then
        jogador.vida_max = jogador.vida_max + t.ganho
        jogador.vida = jogador.vida + t.ganho
    elseif e.atributo == "ataque" then
        jogador.ataque_base = jogador.ataque_base + t.ganho
    end
    mercador.atualizar()
    return true, t.nome .. ": +" .. t.ganho .. " " .. t.texto .. "."
end

return mercador
