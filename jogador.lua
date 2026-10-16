local jogador = {}
local pocoes = require("pocoes")
local cores = require("cores")
local loot = require("loot")
local classes = require("classes")
local registo = require("registo")
local reliquias = require("reliquias")
local habilidades = require("habilidades")

jogador.MAX_ITENS = 10 -- tamanho da mochila

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
    jogador.portas = nil -- portas da sala atual (o savegame precisa delas)
    jogador.moedas = 0
    jogador.especial = nil -- "fogueira" ou "tesouro" quando estas numa dessas salas
    jogador.eventoId = nil -- evento sorteado da sala atual (o savegame precisa dele)
    jogador.nivel = 1 -- nivel do jogador (para calcular a vida maxima)
    jogador.xp = 0 -- experiencia do jogador (para calcular a vida maxima)
    jogador.classe = nil
    jogador.matadoPor = nil -- guarda o inimigo que matou o player
    jogador.reliquias = {} -- ids das reliquias que tens
    jogador.ofertaReliquias = nil -- oferta de um chefe a espera de escolha
    jogador.habilidades = {} -- ids das habilidades que aprendeste
    jogador.habPendentes = 0 -- escolhas por fazer (so em memoria)
    jogador.bau = nil -- resultado ja sorteado do bau da sala atual
    jogador.posVitoria = nil -- { boss = true/false } enquanto ha decisoes depois de uma vitoria
    jogador.lootPendente = nil -- item que caiu e ainda nao foi decidido
    jogador.cruzUsada = false
    jogador.forja = {
        arma = 0,
        armadura = 0
    } -- melhorias do ferreiro, ligadas a ranhura
end
function jogador.ataqueTotal()
    return jogador.ataque_base + (jogador.arma and jogador.arma.bonus or 0) + jogador.forja.arma +
               jogador.bonus("ataque")
end

function jogador.defesaTotal()
    return jogador.defClasse().defesa + (jogador.armadura and jogador.armadura.bonus or 0) + jogador.forja.armadura +
               jogador.bonus("defesa")
end

-- Texto do bonus: "+7" (base) ou "+7 +3" (base + melhorias da ranhura, so no item equipado)
function jogador.textoBonus(item)
    local extra = (jogador[item.tipo] == item) and jogador.forja[item.tipo] or 0
    if extra > 0 then
        return "+" .. item.bonus .. " +" .. extra
    end
    return "+" .. item.bonus
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
    return math.min(jogador.vida_max, jogador.vida + jogador.curaDe(p))
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

function jogador.xpNecessario()
    return 2 + jogador.nivel -- nivel 1 pede 3, nivel 2 pede 4...
end

-- Escolhas de habilidade por fazer: uma por cada 2 niveis, limitadas ao que falta aprender
function jogador.recalcularHab()
    jogador.habPendentes = math.max(0, math.min(math.floor(jogador.nivel / 2) - #jogador.habilidades,
        #jogador.habilidadesDisponiveis()))
end

-- Devolve quantos niveis subiste
function jogador.ganharXp(n)
    local c = jogador.defClasse()
    jogador.xp = jogador.xp + n
    local subiu = 0
    while jogador.xp >= jogador.xpNecessario() do
        jogador.xp = jogador.xp - jogador.xpNecessario()
        jogador.nivel = jogador.nivel + 1
        jogador.vida_max = jogador.vida_max + c.vidaNivel
        jogador.vida = jogador.vida + c.vidaNivel
        jogador.ataque_base = jogador.ataque_base + c.ataqueNivel
        subiu = subiu + 1
    end
    -- uma habilidade por cada 2 niveis; assim, gravacoes antigas tambem recuperam o atraso
    jogador.recalcularHab()
    return subiu
end

function jogador.defClasse()
    return classes.porId(jogador.classe) or classes.neutra
end

-- Chamada uma vez, depois do reiniciar, quando escolhes a classe
function jogador.escolherClasse(id)
    local c = classes.porId(id)
    jogador.classe = id
    jogador.vida_max = c.vida
    jogador.vida = c.vida
    jogador.ataque_base = c.ataque
end

-- Cura real de uma pocao (com o multiplicador da classe)
function jogador.curaDe(p)
    return math.floor(p.cura * jogador.defClasse().cura + 0.5)
end

function jogador.temReliquia(id)
    for _, r in ipairs(jogador.reliquias) do
        if r == id then
            return true
        end
    end
    return false
end

-- Soma o valor de "chave" em todas as reliquias que tens
function jogador.bonus(chave)
    local total = 0
    for _, id in ipairs(jogador.reliquias) do
        local r = reliquias.porId(id)
        total = total + ((r.mods and r.mods[chave]) or 0)
    end
    return total
end

-- Reliquias que ainda nao tens
function jogador.reliquiasDisponiveis()
    local lista = {}
    for _, r in ipairs(reliquias.lista) do
        if not jogador.temReliquia(r.id) then
            table.insert(lista, r)
        end
    end
    return lista
end

function jogador.darReliquia(id)
    local r = reliquias.porId(id)
    table.insert(jogador.reliquias, id)
    if r.aoObter then
        r.aoObter(jogador)
    end
    return r
end

function jogador.temHabilidade(id)
    for _, h in ipairs(jogador.habilidades) do
        if h == id then
            return true
        end
    end
    return false
end

-- Habilidades da tua classe que ainda nao aprendeste
function jogador.habilidadesDisponiveis()
    local lista = {}
    for _, h in ipairs(habilidades.lista) do
        if h.classe == jogador.classe and not jogador.temHabilidade(h.id) then
            table.insert(lista, h)
        end
    end
    return lista
end

-- As que ja aprendeste, pela ordem em que as aprendeste
function jogador.habilidadesConhecidas()
    local lista = {}
    for _, id in ipairs(jogador.habilidades) do
        table.insert(lista, habilidades.porId(id))
    end
    return lista
end

function jogador.aprenderHabilidade(id)
    table.insert(jogador.habilidades, id)
end

-- Devolve true se a Cruz te salvou (e gasta-a)
function jogador.salvarComCruz()
    if jogador.temReliquia("cruz") and not jogador.cruzUsada then
        jogador.cruzUsada = true
        jogador.vida = 1
        jogador.efeitos = {} -- sem isto, o veneno matava-te no turno seguinte
        return true
    end
    return false
end

jogador.reiniciar()

return jogador
