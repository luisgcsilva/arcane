local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")
local reliquias = require("reliquias")

local mercador = {}

local SLOTS = {"arma", "arma", "armadura", "armadura"}

mercador.stock = {}

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

    if jogador.moedas < e.preco then
        return false, "Moedas insuficientes."
    end

    if e.tipo == "item" then
        if not jogador.guardar(e.item) then
            return false, "Mochila cheia! Vende algo primeiro."
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
    arma = 30,
    armadura = 24
}

-- Preco de melhorar o item equipado nessa ranhura (nil se nao ha nenhum)
function mercador.precoForja(slot)
    local item = jogador[slot]
    if not item then
        return nil
    end
    return 40 + 15 * item.bonus
end

-- Os precos do ferreiro dependem do que tens equipado, por isso recalculam-se
function mercador.atualizar()
    for _, e in ipairs(mercador.stock) do
        if e.tipo == "forja" then
            e.preco = mercador.precoForja(e.slot) or 0
        end
    end
end

function mercador.forjar(e)
    mercador.atualizar()
    local item = jogador[e.slot]
    if not item then
        return false, "Nao tens nada equipado nessa ranhura."
    end
    if item.bonus >= mercador.MAX_FORJA[e.slot] then
        return false, "O ferreiro ja nao consegue melhorar " .. item.nome .. "."
    end
    if jogador.moedas < e.preco then
        return false, "Moedas insuficientes."
    end
    jogador.moedas = jogador.moedas - e.preco
    item.bonus = item.bonus + 1
    mercador.atualizar()
    return true, item.nome .. " agora e +" .. item.bonus .. "."
end

return mercador
