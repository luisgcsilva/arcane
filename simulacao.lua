local classes = require("classes")
local jogador = require("jogador")
local dificuldade = require("dificuldade")
local salas = require("salas")
local intencoes = require("intencoes")
local efeitos = require("efeitos")
local loot = require("loot")
local pocoes = require("pocoes")
local reliquias = require("reliquias")
local mercador = require("mercador")

local simulacao = {}

local SEMENTE = 12345
local MAX_SALA = 100 -- a partida acaba aqui se sobreviveres
local MAX_TURNOS = 300 -- protecao contra combates sem fim
-- igual ao combate.lua (se mudares la, muda aqui)
local BONUS_CHEFE = {
    vida = 5,
    ataque = 2
}

local function dano(ataque)
    return math.max(1, ataque + math.random(-1, 1))
end

-- ========== combate sem ecra ==========

local function criarCtx(est)
    local inimigo = est.inimigo
    local c = {
        sala = jogador.sala
    }

    function c.msg()
    end
    function c.vivo()
        return inimigo.vida > 0
    end

    function c.atacar(mult)
        local d = dano(math.floor(jogador.ataqueTotal() * mult + 0.5))
        inimigo.vida = math.max(0, inimigo.vida - d)
        jogador.stats.dano_causado = jogador.stats.dano_causado + d
        return d
    end

    function c.curar(n)
        local real = math.max(0, math.min(n, jogador.vida_max - jogador.vida))
        jogador.vida = jogador.vida + real
        return real
    end

    function c.curarPct(f)
        return c.curar(math.ceil(jogador.vida_max * f))
    end
    function c.limparEfeitos()
        return efeitos.curar(jogador.efeitos)
    end
    function c.moedas(n)
        jogador.ganharMoedas(n)
    end
    function c.proteger(f)
        est.protecao = math.max(est.protecao, f)
    end

    function c.atordoar()
        if inimigo.boss and math.random() < 0.5 then
            return
        end
        est.atordoado = true
    end

    return c
end

local function escolherIntencao(est)
    local inimigo = est.inimigo
    if inimigo.carregado then
        est.intencao = "pesado"
        return
    end
    local p = inimigo.padrao
    if not p or #p == 0 then
        est.intencao = "normal"
        return
    end
    local id = tostring(p[est.padraoIdx]):match("^%s*(.-)%s*$")
    est.padraoIdx = est.padraoIdx % #p + 1
    if not intencoes.existe(id) then
        id = "normal"
    end
    if id == "curar" and inimigo.vida >= inimigo.vida_max then
        id = "normal"
    end
    est.intencao = id
end

-- true se os efeitos te deixaram sem vida
local function processarEfeitos()
    for _, id in ipairs(efeitos.ordem) do
        local def = efeitos.lista[id]
        local turnos = jogador.efeitos[id]
        if turnos and def.dano then
            local d = efeitos.dano(id, jogador.sala)
            jogador.vida = jogador.vida - d
            jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + d
            jogador.efeitos[id] = (turnos > 1) and (turnos - 1) or nil
            if jogador.vida <= 0 then
                return true
            end
        end
    end
    return false
end

-- Devolve true se MORRESTE (a Cruz Sagrada conta como nao morrer)
local function inimigoAtaca(est)
    local inimigo = est.inimigo
    local def = intencoes.lista[est.intencao]
    local defendeu, prot = est.defendendo, est.protecao
    est.defendendo, est.protecao = false, 0

    if def.carrega then
        inimigo.carregado = true
    end
    if def.descarrega then
        inimigo.carregado = false
    end
    if def.cura then
        local n = math.min(math.ceil(inimigo.vida_max * def.cura), inimigo.vida_max - inimigo.vida)
        inimigo.vida = inimigo.vida + n
    end

    local total = 0
    local defesa = def.ignoraDefesa and 0 or jogador.defesaTotal()
    local defesaPorGolpe = defesa / math.max(1, #def.golpes)
    for _, mult in ipairs(def.golpes) do
        local d = dano(math.floor(inimigo.ataque * mult - defesaPorGolpe + 0.5))
        if defendeu then
            d = math.max(1, math.ceil(d / 2))
        end
        if prot > 0 then
            d = math.max(0, math.floor(d * (1 - prot) + 0.5))
        end
        total = total + d
        jogador.vida = jogador.vida - d
        jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + d
        if jogador.vida <= 0 then
            return not jogador.salvarComCruz()
        end
    end

    local esp = jogador.bonus("espinhos")
    if total > 0 and esp > 0 then
        local causado = math.min(esp, inimigo.vida - 1)
        if causado > 0 then
            inimigo.vida = inimigo.vida - causado
            jogador.stats.dano_causado = jogador.stats.dano_causado + causado
        end
    end

    if processarEfeitos() then
        return not jogador.salvarComCruz()
    end

    local ef = inimigo.efeito
    if total > 0 and ef and math.random() < ef.chance * (defendeu and 0.5 or 1) then
        jogador.efeitos[ef.id] = math.max(jogador.efeitos[ef.id] or 0, efeitos.lista[ef.id].turnos)
    end
    return false
end

-- ========== o "cerebro" do bot ==========

-- Papel de cada habilidade (as que nao estiverem aqui contam como "ataque")
local PAPEL = {
    muralha = "defesa",
    esquiva = "defesa",
    escudo = "defesa",
    folego = "cura",
    cura = "cura",
    investida = "atordoar",
    sujo = "atordoar"
}

local function acharHab(est, papel)
    for _, h in ipairs(jogador.habilidadesConhecidas()) do
        if (est.cooldowns[h.id] or 0) <= 0 and (PAPEL[h.id] or "ataque") == papel then
            return h
        end
    end
end

local function usarHab(est, h)
    h.usar(criarCtx(est))
    est.cooldowns[h.id] = h.cooldown
end

local function beber(est, p)
    jogador.usarPocao(p.id)
    efeitos.curar(jogador.efeitos)
    if est.pocaoGratis then -- Frasco Infinito
        est.pocaoGratis = false
        jogador.darPocao(p.id)
        jogador.stats.pocoes = jogador.stats.pocoes - 1
    end
end

local function defender(est)
    est.defendendo = true
    jogador.vida = jogador.vida + math.min(2, jogador.vida_max - jogador.vida)
end

local function turnoJogador(est)
    local inimigo = est.inimigo
    local fracao = jogador.vida / jogador.vida_max
    local h

    if fracao < 0.5 then
        h = acharHab(est, "cura")
        if h then
            usarHab(est, h)
            return
        end
    end
    if fracao < 0.35 then
        local lista = jogador.pocoesDisponiveis()
        if #lista > 0 then
            beber(est, lista[#lista])
            return
        end
    end
    if est.intencao == "pesado" then -- golpe carregado a caminho
        h = acharHab(est, "atordoar") or acharHab(est, "defesa")
        if h then
            usarHab(est, h)
            return
        end
        defender(est)
        return
    end
    if est.intencao == "carregar" then
        h = acharHab(est, "atordoar")
        if h then
            usarHab(est, h)
            return
        end
    end
    h = acharHab(est, "ataque") or acharHab(est, "atordoar")
    if h then
        usarHab(est, h)
        return
    end

    local d = dano(jogador.ataqueTotal())
    inimigo.vida = math.max(0, inimigo.vida - d)
    jogador.stats.dano_causado = jogador.stats.dano_causado + d
end

-- Devolve true se ganhaste; false se perdeste (e true no 2o valor se foi "demasiado longo")
local function combater(inimigo)
    local est = {
        inimigo = inimigo,
        cooldowns = {},
        defendendo = false,
        protecao = 0,
        atordoado = false,
        pocaoGratis = jogador.temReliquia("frasco")
    }
    jogador.efeitos = {}
    inimigo.carregado = false
    est.padraoIdx = (inimigo.padrao and #inimigo.padrao > 0) and math.random(#inimigo.padrao) or 1
    escolherIntencao(est)

    for turno = 1, MAX_TURNOS do
        if turno > 1 then
            for id, v in pairs(est.cooldowns) do
                if v > 0 then
                    est.cooldowns[id] = v - 1
                end
            end
        end

        local perde = false
        if jogador.efeitos.atordoamento then
            jogador.efeitos.atordoamento = nil
            perde = true
        end

        if not perde then
            turnoJogador(est)
            if inimigo.vida <= 0 then
                return true
            end
        end

        if est.atordoado then
            est.atordoado = false
            inimigo.carregado = false -- a carga e interrompida
            if processarEfeitos() and not jogador.salvarComCruz() then
                return false
            end
        else
            if inimigoAtaca(est) then
                return false
            end
        end
        escolherIntencao(est)
    end
    return false, true
end

-- ========== recompensas e outras salas ==========

local function equipar(item)
    local antigo = jogador[item.tipo]
    jogador[item.tipo] = item
    if antigo then
        jogador.ganharMoedas(loot.precoVenda(antigo))
    end
end

local function equiparOuVender(item)
    if jogador.eMelhor(item) then
        equipar(item)
    else
        jogador.ganharMoedas(loot.precoVenda(item))
    end
end

local function recompensas(inimigo)
    local s = jogador.stats
    s.inimigos = s.inimigos + 1
    if inimigo.boss then
        s.chefes = s.chefes + 1
    end

    jogador.ganharXp(inimigo.boss and 4 or (inimigo.elite and 2 or 1))
    jogador.recalcularHab()
    while jogador.habPendentes > 0 do
        local pool = jogador.habilidadesDisponiveis()
        if #pool == 0 then
            break
        end
        jogador.aprenderHabilidade(pool[math.random(#pool)].id)
        jogador.habPendentes = jogador.habPendentes - 1
    end

    if inimigo.boss then
        local b = jogador.defClasse().bonusChefe or BONUS_CHEFE
        jogador.vida_max = jogador.vida_max + b.vida
        jogador.vida = jogador.vida_max
        jogador.ataque_base = jogador.ataque_base + b.ataque
        local pool = jogador.reliquiasDisponiveis()
        if #pool > 0 then
            jogador.darReliquia(pool[math.random(#pool)].id)
        end
    end

    for _, id in ipairs(jogador.reliquias) do
        local r = reliquias.porId(id)
        if r.aoVencer then
            r.aoVencer(jogador)
        end
    end

    local n = math.random(3, 6) + 2 * jogador.sala
    if inimigo.boss then
        n = n * 3
    elseif inimigo.elite then
        n = n * 2
    end
    n = math.floor(n * (jogador.defClasse().moedas + jogador.bonus("moedas")) + 0.5)
    jogador.ganharMoedas(n)

    if inimigo.boss or inimigo.elite or math.random() < 0.4 then
        jogador.darPocao(pocoes.sortear().id)
    end
    if inimigo.boss or inimigo.elite or math.random() < 0.7 then
        equiparOuVender(loot.sortear(jogador.sala + (inimigo.boss and 10 or (inimigo.elite and 6 or 0))))
    end
end

local function totalPocoes()
    local n = 0
    for _, q in pairs(jogador.pocoes) do
        n = n + q
    end
    return n
end

-- Compra: primeiro reliquias, depois equipamento melhor, depois pocoes (ate 5)
local function visitarLoja()
    mercador.gerar(jogador.sala)
    for _, e in ipairs(mercador.stock) do
        if e.tipo == "reliquia" and jogador.moedas >= e.preco then
            jogador.moedas = jogador.moedas - e.preco
            jogador.darReliquia(e.reliquia.id)
            e.vendido = true
        end
    end
    for _, e in ipairs(mercador.stock) do
        if e.tipo == "item" and not e.vendido and jogador.moedas >= e.preco and jogador.eMelhor(e.item) then
            jogador.moedas = jogador.moedas - e.preco
            equipar(e.item)
            e.vendido = true
        end
    end
    for _, e in ipairs(mercador.stock) do
        if e.tipo == "pocao" then
            while jogador.moedas >= e.preco and totalPocoes() < 5 do
                jogador.moedas = jogador.moedas - e.preco
                jogador.darPocao(e.pocao.id)
            end
        end
    end
    for i, e in ipairs(mercador.stock) do
        if e.tipo == "forja" then
            while mercador.comprar(i) do
            end -- compra ate faltarem moedas ou chegar ao teto
        end
    end
    -- sobras: treino, a rodar entre os tres ate faltarem moedas
    local comprou = true
    while comprou do
        comprou = false
        for i, e in ipairs(mercador.stock) do
            if e.tipo == "treino" and mercador.comprar(i) then
                comprou = true
            end
        end
    end
end

local function visitarFogueira()
    if jogador.vida < jogador.vida_max * 0.7 or not jogador.arma then
        jogador.vida = jogador.vida + math.min(math.ceil(jogador.vida_max * 0.4), jogador.vida_max - jogador.vida)
    else
        jogador.arma.bonus = jogador.arma.bonus + 1
    end
end

local function visitarTesouro()
    local sorte = math.random(100)
    if sorte <= 15 then
        local d = math.min(jogador.vida - 1, math.max(2, math.floor(jogador.vida_max * 0.15)))
        jogador.vida = jogador.vida - math.max(0, d)
    elseif sorte <= 55 then
        equiparOuVender(loot.sortear(jogador.sala + 3))
    else
        jogador.ganharMoedas(math.random(8, 15) + 3 * jogador.sala)
    end
end

-- ========== uma partida e as estatisticas ==========

local function jogarPartida(classeId)
    jogador.reiniciar()
    jogador.escolherClasse(classeId)
    jogador.efeitos = {}
    local anterior = nil
    local r = {
        sobreviveu = true,
        causa = "",
        tipo = ""
    }

    while jogador.sala < MAX_SALA do
        local portas = salas.gerarPortas(jogador.sala + 1, anterior)
        local tipo = portas[math.random(#portas)] -- portas misteriosas: escolha cega
        jogador.sala = jogador.sala + 1

        if tipo == "combate" or tipo == "elite" or tipo == "boss" then
            local inimigo = dificuldade.criarInimigo(jogador.sala, tipo == "boss", tipo == "elite")
            local ganhou, longo = combater(inimigo)
            if not ganhou then
                r.sobreviveu = false
                r.causa = longo and "(combate sem fim)" or inimigo.nome
                r.tipo = longo and "longo" or (tipo == "combate" and "normal" or tipo)
                break
            end
            recompensas(inimigo)
            anterior = (tipo == "boss") and "boss" or nil
        elseif tipo == "loja" then
            visitarLoja()
            anterior = "loja"
        elseif tipo == "fogueira" then
            visitarFogueira()
            anterior = "fogueira"
        elseif tipo == "tesouro" then
            visitarTesouro()
            anterior = "tesouro"
        elseif tipo == "santuario" then
            anterior = "santuario" -- nao simulado
        else -- evento: nao simulado
            anterior = "evento"
        end
    end

    r.sala = jogador.sala
    r.nivel = jogador.nivel
    r.vida_max = jogador.vida_max
    r.moedas = jogador.moedas
    r.ataque = jogador.ataqueTotal()
    r.defesa = jogador.defesaTotal()
    r.reliquias = #jogador.reliquias
    r.habilidades = #jogador.habilidades
    r.inimigos = jogador.stats.inimigos
    r.chefes = jogador.stats.chefes
    r.dano_causado = jogador.stats.dano_causado
    r.dano_sofrido = jogador.stats.dano_sofrido
    r.pocoes = jogador.stats.pocoes
    return r
end

local function resumir(c, rs)
    local n = #rs
    local salasAt, nivel, vmax, moedas, vivos = {}, 0, 0, 0, 0
    local causas, tipos, faixas = {}, {
        normal = 0,
        elite = 0,
        boss = 0,
        longo = 0
    }, {}

    for _, r in ipairs(rs) do
        table.insert(salasAt, r.sala)
        nivel, vmax, moedas = nivel + r.nivel, vmax + r.vida_max, moedas + r.moedas
        if r.sobreviveu then
            vivos = vivos + 1
        else
            causas[r.causa] = (causas[r.causa] or 0) + 1
            tipos[r.tipo] = (tipos[r.tipo] or 0) + 1
            local f = math.floor(r.sala / 10)
            faixas[f] = (faixas[f] or 0) + 1
        end
    end
    table.sort(salasAt)

    local soma = 0
    for _, s in ipairs(salasAt) do
        soma = soma + s
    end
    local mortes = n - vivos
    local function pm(k)
        return mortes > 0 and 100 * k / mortes or 0
    end
    local function alcancou(x)
        local k = 0
        for _, s in ipairs(salasAt) do
            if s >= x then
                k = k + 1
            end
        end
        return 100 * k / n
    end

    local linhas = {}
    table.insert(linhas,
        string.format("%s: sala media %.1f, mediana %d, melhor %d, chegaram ao fim: %d", c.nome, soma / n,
            salasAt[math.ceil(n / 2)], salasAt[n], vivos))
    table.insert(linhas,
        string.format("  Chegou a sala 10: %.0f%%   20: %.0f%%   30: %.0f%%   40: %.0f%%", alcancou(10), alcancou(20),
            alcancou(30), alcancou(40)))
    table.insert(linhas,
        string.format("  No fim: nivel %.1f, vida max %.0f, moedas %.0f", nivel / n, vmax / n, moedas / n))
    table.insert(linhas,
        string.format("  Morreu em: combate %.0f%%, elite %.0f%%, chefe %.0f%%", pm(tipos.normal), pm(tipos.elite),
            pm(tipos.boss)))

    local fs = {}
    for f in pairs(faixas) do
        table.insert(fs, f)
    end
    table.sort(fs)
    local partes = {}
    for _, f in ipairs(fs) do
        table.insert(partes,
            string.format("%s: %.0f%%", f == 0 and "1-9" or (f * 10 .. "-" .. (f * 10 + 9)), pm(faixas[f])))
    end
    table.insert(linhas, "  Mortes por faixa de salas: " .. table.concat(partes, "  "))

    local lista = {}
    for nome, k in pairs(causas) do
        table.insert(lista, {
            nome = nome,
            k = k
        })
    end
    table.sort(lista, function(a, b)
        return a.k > b.k
    end)
    local top = {}
    for i = 1, math.min(4, #lista) do
        table.insert(top, string.format("%s %.0f%%", lista[i].nome, pm(lista[i].k)))
    end
    table.insert(linhas, "  Causas: " .. table.concat(top, ", "))
    return linhas
end

local CABECALHO = "classe;partida;sala;resultado;causa;tipo_morte;nivel;vida_max;ataque;defesa;" ..
                      "moedas;reliquias;habilidades;inimigos;chefes;dano_causado;dano_sofrido;pocoes"

local function linhaCsv(classe, i, r)
    return table.concat({classe, i, r.sala, r.sobreviveu and "fim" or "morreu", r.sobreviveu and "" or r.causa,
                         r.sobreviveu and "" or r.tipo, r.nivel, r.vida_max, r.ataque, r.defesa, r.moedas, r.reliquias,
                         r.habilidades, r.inimigos, r.chefes, r.dano_causado, r.dano_sofrido, r.pocoes}, ";")
end

-- Corre n partidas por classe e devolve as linhas de texto
-- Corre n partidas por classe. Devolve as linhas de resumo e o texto do CSV.
function simulacao.correr(n)
    math.randomseed(SEMENTE)
    local linhas = {string.format("Simulacao: %d partidas por classe, semente %d, ate a sala %d", n, SEMENTE, MAX_SALA),
                    ""}
    local csv = {CABECALHO}

    for _, c in ipairs(classes.lista) do
        local rs = {}
        for i = 1, n do
            local r = jogarPartida(c.id)
            table.insert(rs, r)
            table.insert(csv, linhaCsv(c.nome, i, r))
        end
        for _, l in ipairs(resumir(c, rs)) do
            table.insert(linhas, l)
        end
        table.insert(linhas, "")
    end

    math.randomseed(os.time())
    return linhas, table.concat(csv, "\n") .. "\n"
end

return simulacao
