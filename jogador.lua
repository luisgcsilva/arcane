local jogador = {}
local pocoes = require("pocoes")
local cores = require("cores")
local loot = require("loot")

jogador.MAX_ITENS = 8 -- tamanho da mochila

function jogador.reiniciar()
    jogador.vida_max = 30
    jogador.vida = 30
    jogador.ataque_base = 5
    jogador.sala = 0
    jogador.arma = nil
    jogador.armadura = nil
    jogador.inventario = {}
    jogador.pocoes = {}
    jogador.stats = {
        inimigos = 0,
        chefes = 0,
        dano_causado = 0,
        dano_sofrido = 0,
        pocoes = 0
    }
    jogador.inimigo = nil -- inimigo da sala atual (o savegame precisa dele)
    jogador.moedas = 0
end

function jogador.ataqueTotal()
    return jogador.ataque_base + (jogador.arma and jogador.arma.bonus or 0)
end

function jogador.defesaTotal()
    return jogador.armadura and jogador.armadura.bonus or 0
end

-- Guarda na mochila. Devolve false se estiver cheia.
function jogador.guardar(item)
    if #jogador.inventario >= jogador.MAX_ITENS then
        return false
    end
    table.insert(jogador.inventario, item)
    return true
end

-- Equipa o item que esta na posicao "indice" da mochila.
-- O que estava equipado volta para a mochila (troca).
function jogador.equipar(indice)
    local item = table.remove(jogador.inventario, indice)
    local antigo = jogador[item.tipo]
    jogador[item.tipo] = item
    if antigo then
        table.insert(jogador.inventario, antigo)
    end
end

function jogador.largar(indice)
    return table.remove(jogador.inventario, indice)
end

-- O item e melhor que o equipado do mesmo tipo (ou nao ha nada equipado)?
function jogador.eMelhor(item)
    local atual = jogador[item.tipo]
    return atual == nil or item.bonus > atual.bonus
end

-- Equipa um item que NAO esta na mochila (acabou de cair).
-- Devolve o item antigo (ou nil) e se coube na mochila.
function jogador.equiparDireto(item)
    local antigo = jogador[item.tipo]
    jogador[item.tipo] = item
    if antigo and not jogador.guardar(antigo) then
        return antigo, false
    end
    return antigo, true
end

function jogador.quantas(id)
    return jogador.pocoes[id] or 0
end

function jogador.darPocao(id)
    jogador.pocoes[id] = jogador.quantas(id) + 1
end

-- Gasta uma poção e devolve quanta vida recuperaste (ou nil se nao tens).
function jogador.usarPocao(id)
    if jogador.quantas(id) <= 0 then
        return nil
    end
    local def
    for _, p in ipairs(pocoes.lista) do
        if p.id == id then
            def = p
        end
    end
    jogador.pocoes[id] = jogador.pocoes[id] - 1
    jogador.stats.pocoes = jogador.stats.pocoes + 1
    local antes = jogador.vida
    jogador.vida = jogador.vidaApos(def)
    return jogador.vida - antes
end

-- Poções com quantidade > 0, pela ordem de pocoes.lista
function jogador.pocoesDisponiveis()
    local lista = {}
    for _, p in ipairs(pocoes.lista) do
        if jogador.quantas(p.id) > 0 then
            table.insert(lista, p)
        end
    end
    return lista
end

-- Vida que ficarias a ter se bebesses a poção p (sem passar do máximo)
function jogador.vidaApos(p)
    return math.min(jogador.vida_max, jogador.vida + p.cura)
end

function jogador.ganharMoedas(n)
    jogador.moedas = jogador.moedas + n
end

-- Vende o item da mochila. Devolve o item e as moedas ganhas.
function jogador.vender(indice)
    local item = table.remove(jogador.inventario, indice)
    local ganho = loot.precoVenda(item)
    jogador.ganharMoedas(ganho)
    return item, ganho
end

jogador.reiniciar()

return jogador
