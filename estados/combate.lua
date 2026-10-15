local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")
local cores = require("cores")
local savegame = require("savegame")
local efeitos = require("efeitos")
local registo = require("registo")
local reliquias = require("reliquias")
local habilidades = require("habilidades")

local combate = {}

local opcoes = {"Atacar", "Pocao", "Fugir"}
local indice
local inimigo
local mensagens
local fase -- "escolha", "pausa", "pocao", "turno_inimigo", "loot", "vitoria" ou "derrota"
local proxima
local turno
local MAX_LINHAS = 8
local deslocamento
local pendente -- item que acabou de cair, a espera de decisao
local indiceLoot -- 1 = Equipar, 2 = Guardar, 3 = Deixar
local opcoesAtuais -- textos mostrados no menu do loot
local acoesAtuais -- "equipar", "guardar" ou "deixar", pela mesma ordem
local disponiveis -- poções que tens (quantidade > 0), pela ordem do menu
local indicePocao
local mostradaInimigo -- fraccao de vida que a barra mostra (0 a 1)
local mostradaJogador
local opcoes = {"Atacar", "Habilidade", "Defender", "Pocao", "Fugir"}
local acoesMenu = {"atacar", "habilidade", "defender", "pocao", "fugir"}
local defendendo
local pocaoGratis -- o Frasco Infinito ainda nao foi usado neste combate
local cooldowns -- id da habilidade -> turnos que faltam
local disponiveisHab -- habilidades que conheces
local indiceHab
local inimigoAtordoado
local protecao -- fracao do proximo golpe que e absorvida (0 a 1)

local function dano(ataque)
    return math.max(1, ataque + math.random(-1, 1))
end

local function morrer()
    jogador.vida = 0
    jogador.matadoPor = inimigo.nome
    table.insert(mensagens, "Foste derrotado...")
    fase = "derrota"
    savegame.apagar()
end

local function aplicarEfeito(id)
    local def = efeitos.lista[id]
    jogador.efeitos[id] = math.max(jogador.efeitos[id] or 0, def.turnos)
    table.insert(mensagens, {def.cor, def.frase})
end

-- Dano dos efeitos ativos. Devolve true se morreste.
local function processarEfeitos()
    for _, id in ipairs(efeitos.ordem) do
        local def = efeitos.lista[id]
        local turnos = jogador.efeitos[id]
        if turnos and def.dano then
            local d = efeitos.dano(id, jogador.sala)
            jogador.vida = jogador.vida - d
            jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + d
            table.insert(mensagens, {def.cor, def.nome .. ": perdes " .. d .. " de vida."})
            turnos = turnos - 1
            jogador.efeitos[id] = (turnos > 0) and turnos or nil
            if jogador.vida <= 0 then
                return true
            end
        end
    end
    return false
end

local function inimigoAtaca()
    local d = dano(inimigo.ataque - jogador.defesaTotal())
    local defendeu = defendendo
    defendendo = false
    if defendeu then
        d = math.max(1, math.ceil(d / 2))
    end

    local prot = protecao
    protecao = 0
    if prot > 0 then
        d = math.max(0, math.floor(d * (1 - prot) + 0.5))
    end

    jogador.vida = jogador.vida - d
    jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + d
    table.insert(mensagens, cores.nome(inimigo, "O ", " causa-te " .. d .. " de dano" ..
        (defendeu and " (defendeste parte do golpe)." or ".")))
    if jogador.vida <= 0 then
        morrer()
        return
    end

    local esp = jogador.bonus("espinhos")
    if esp > 0 then
        local causado = math.min(esp, inimigo.vida - 1) -- os espinhos nunca matam
        if causado > 0 then
            inimigo.vida = inimigo.vida - causado
            jogador.stats.dano_causado = jogador.stats.dano_causado + causado
            table.insert(mensagens, cores.nome(inimigo, "Os espinhos ferem o ", " (-" .. causado .. ")."))
        end
    end

    -- primeiro os efeitos que ja tinhas; so depois o novo (que comeca no turno seguinte)
    if processarEfeitos() then
        morrer()
        return
    end

    local ef = inimigo.efeito
    if ef and math.random() < ef.chance * (defendeu and 0.5 or 1) then
        aplicarEfeito(ef.id)
    end
end

local function limiteScroll()
    return math.max(0, #mensagens - MAX_LINHAS)
end

local function novoTurno()
    turno = turno + 1
    for id, v in pairs(cooldowns) do
        if v > 0 then
            cooldowns[id] = v - 1
        end
    end
    table.insert(mensagens, "--- Turno " .. turno .. " ---")
end

local function guardarNaMochila(item)
    if jogador.guardar(item) then
        table.insert(mensagens, "Guardas " .. item.nome .. " na mochila.")
    else
        local ganho = loot.precoVenda(item)
        jogador.ganharMoedas(ganho)
        table.insert(mensagens, "Mochila cheia! Vendes " .. item.nome .. " por " .. ganho .. " moedas.")
    end
end

local function largarLoot()
    if inimigo.boss or inimigo.elite or math.random() < 0.7 then
        local item = loot.sortear(jogador.sala + (inimigo.boss and 10 or (inimigo.elite and 6 or 0)))
        local atributo = (item.tipo == "arma") and "ataque" or "defesa"
        table.insert(mensagens, {{1, 1, 1}, "Encontras: ", loot.cores[item.raridade], item.nome, {1, 1, 1},
                                 " (" .. item.raridade .. ", +" .. item.bonus .. " " .. atributo .. ")"})

        local preco = loot.precoVenda(item)
        local atual = jogador[item.tipo]
        if jogador.eMelhor(item) then
            -- (as linhas de mensagem ficam como estao)
            opcoesAtuais = {"Equipar", "Guardar na mochila", "Vender (" .. preco .. " moedas)"}
            acoesAtuais = {"equipar", "guardar", "vender"}
        else
            -- (a linha "Nao e melhor..." fica como esta)
            opcoesAtuais = {"Guardar na mochila", "Vender (" .. preco .. " moedas)"}
            acoesAtuais = {"guardar", "vender"}
        end

        pendente = item
        indiceLoot = 1
        fase = "loot"
    else
        table.insert(mensagens, "Nao largou nada.")
    end
end

local function largarMoedas()
    local n = math.random(3, 6) + 2 * jogador.sala
    if inimigo.boss then
        n = n * 3
    elseif inimigo.elite then
        n = n * 2
    end
    n = math.floor(n * (jogador.defClasse().moedas + jogador.bonus("moedas")) + 0.5)
    jogador.ganharMoedas(n)
    table.insert(mensagens, {{1, 0.85, 0.2}, "Encontras " .. n .. " moedas."})
end

local function largarPocao()
    if inimigo.boss or inimigo.elite or math.random() < 0.4 then
        local p = pocoes.sortear()
        jogador.darPocao(p.id)
        table.insert(mensagens, cores.nome(p, "Encontras: ", " (+" .. jogador.curaDe(p) .. " vida). Tens " ..
            jogador.quantas(p.id) .. "."))
    end
end

local function abrirPocoes()
    disponiveis = jogador.pocoesDisponiveis()
    if #disponiveis == 0 then
        table.insert(mensagens, "Nao tens pocoes.")
        return
    end
    indicePocao = 1
    fase = "pocao"
end

function combate.entrar(inimigo_novo)
    inimigo = inimigo_novo
    mostradaInimigo = inimigo.vida / inimigo.vida_max
    mostradaJogador = jogador.vida / jogador.vida_max
    indice = 1
    fase = "escolha"
    turno = 1
    deslocamento = 0
    mensagens = {cores.nome(inimigo, "Um ", " bloqueia o caminho!", "!"), "--- Turno " .. turno .. " ---"}
    defendendo = false
    jogador.efeitos = {}
    pocaoGratis = jogador.temReliquia("frasco")
    cooldowns = {}
    inimigoAtordoado = false
    protecao = 0
end

local function vencer()
    inimigo.vida = 0
    table.insert(mensagens, cores.nome(inimigo, "O ", " foi derrotado!"))
    fase = "vitoria"
    jogador.stats.inimigos = jogador.stats.inimigos + 1
    if inimigo.boss then
        jogador.stats.chefes = jogador.stats.chefes + 1
        jogador.vida_max = jogador.vida_max + 10
        jogador.vida = jogador.vida_max
        jogador.ataque_base = jogador.ataque_base + 2
        table.insert(mensagens, "O chefe cai! Ataque +2 e Vida maxima +10 e recuperas toda a vida.")
    end
    local subiu = jogador.ganharXp(inimigo.boss and 4 or (inimigo.elite and 2 or 1))
    if subiu > 0 then
        local c = jogador.defClasse()
        table.insert(mensagens, {{1, 0.85, 0.2},
                                 "Subiste para o nivel " .. jogador.nivel .. "! Vida maxima +" .. (c.vidaNivel * subiu) ..
            ", ataque +" .. (c.ataqueNivel * subiu) .. "."})
    end
    for _, id in ipairs(jogador.reliquias) do
        local r = reliquias.porId(id)
        if r.aoVencer then
            local msg = r.aoVencer(jogador)
            if msg then
                table.insert(mensagens, {r.cor, msg})
            end
        end
    end
    largarPocao()
    largarLoot()
    largarMoedas()

    if jogador.habPendentes > 0 then
        table.insert(mensagens, {{0.5, 1, 0.6}, "Podes aprender uma habilidade nova!"})
    end
end

local function criarCtx()
    local c = {
        sala = jogador.sala
    }

    function c.msg(t)
        table.insert(mensagens, t)
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
        protecao = math.max(protecao, f)
    end

    function c.atordoar()
        if inimigo.boss and math.random() < 0.5 then
            c.msg("O chefe resiste ao atordoamento.")
            return
        end
        inimigoAtordoado = true
        c.msg(cores.nome(inimigo, "O ", " fica atordoado!"))
    end

    return c
end

local function abrirHabilidades()
    disponiveisHab = jogador.habilidadesConhecidas()
    if #disponiveisHab == 0 then
        table.insert(mensagens, "Ainda nao aprendeste nenhuma habilidade (nivel 2).")
        return
    end
    indiceHab = 1
    fase = "habilidade"
end

function combate.acao(a)
    if a == "ombro_esq" then
        deslocamento = math.min(deslocamento + 1, limiteScroll())
        return
    elseif a == "ombro_dir" then
        deslocamento = math.max(deslocamento - 1, 0)
        return
    end

    deslocamento = 0

    if fase == "escolha" then
        if a == "cima" then
            indice = indice - 1
            if indice < 1 then
                indice = #opcoes
            end
        elseif a == "baixo" then
            indice = indice + 1
            if indice > #opcoes then
                indice = 1
            end
        elseif a == "confirmar" then
            local escolha = acoesMenu[indice]
            if escolha == "atacar" then
                -- atacar
                local d = dano(jogador.ataqueTotal())
                inimigo.vida = inimigo.vida - d
                table.insert(mensagens, "Atacas e causas " .. d .. " de dano.")
                jogador.stats.dano_causado = jogador.stats.dano_causado + d
                if inimigo.vida <= 0 then
                    vencer()
                else
                    fase = "pausa"
                end
            elseif escolha == "defender" then
                defendendo = true
                local cura = math.min(2, jogador.vida_max - jogador.vida)
                jogador.vida = jogador.vida + cura
                table.insert(mensagens,
                    "Levantas a guarda" .. (cura > 0 and (" e recuperas " .. cura .. " de vida.") or "."))
                fase = "pausa"
            elseif escolha == "pocao" then
                -- pocao
                abrirPocoes()
            elseif escolha == "habilidade" then
                abrirHabilidades()
            else
                if inimigo.boss then
                    table.insert(mensagens, "Nao consegues fugir do chefe!")
                elseif math.random() < math.min(0.95, jogador.defClasse().fuga + jogador.bonus("fuga")) *
                    (inimigo.elite and 0.5 or 1) then
                    jogo.mudar("portas")
                else
                    table.insert(mensagens, "Nao consegues fugir do combate.")
                    fase = "pausa"
                end
            end
        end
    elseif fase == "loot" then
        if a == "cima" then
            indiceLoot = indiceLoot - 1
            if indiceLoot < 1 then
                indiceLoot = #opcoesAtuais
            end
        elseif a == "baixo" then
            indiceLoot = indiceLoot + 1
            if indiceLoot > #opcoesAtuais then
                indiceLoot = 1
            end
        elseif a == "confirmar" then
            local escolha = acoesAtuais[indiceLoot]
            if escolha == "equipar" then
                local antigo, coube = jogador.equiparDireto(pendente)
                table.insert(mensagens, "Equipas " .. pendente.nome .. ".")
                if antigo and coube then
                    table.insert(mensagens, antigo.nome .. " vai para a mochila.")
                elseif antigo then
                    local ganho = loot.precoVenda(antigo)
                    jogador.ganharMoedas(ganho)
                    table.insert(mensagens, "Mochila cheia! Vendes " .. antigo.nome .. " por " .. ganho .. " moedas.")
                end
            elseif escolha == "guardar" then
                guardarNaMochila(pendente)
            elseif escolha == "vender" then
                local ganho = loot.precoVenda(pendente)
                jogador.ganharMoedas(ganho)
                table.insert(mensagens, "Vendes " .. pendente.nome .. " por " .. ganho .. " moedas.")
            end
            pendente = nil
            fase = "vitoria"
        end
    elseif fase == "pocao" then
        if a == "cima" then
            indicePocao = indicePocao - 1
            if indicePocao < 1 then
                indicePocao = #disponiveis
            end
        elseif a == "baixo" then
            indicePocao = indicePocao + 1
            if indicePocao > #disponiveis then
                indicePocao = 1
            end
        elseif a == "cancelar" then
            fase = "escolha"
        elseif a == "confirmar" then
            local p = disponiveis[indicePocao]
            if jogador.vida >= jogador.vida_max then
                table.insert(mensagens, "Ja tens a vida cheia.")
                fase = "escolha"
            else
                local curado = jogador.usarPocao(p.id)
                table.insert(mensagens, cores.nome(p, "Bebes ", " e recuperas " .. curado .. " de vida."))
                if pocaoGratis then
                    pocaoGratis = false
                    jogador.darPocao(p.id)
                    jogador.stats.pocoes = jogador.stats.pocoes - 1
                    table.insert(mensagens,
                        {{0.4, 0.9, 1}, "O Frasco Infinito volta a encher-se: a pocao nao se gastou."})
                end
                if efeitos.curar(jogador.efeitos) > 0 then
                    table.insert(mensagens, "A pocao cura o veneno e as hemorragias.")
                end
                fase = "pausa"
            end
        end
    elseif fase == "habilidade" then
        if a == "cima" then
            indiceHab = indiceHab - 1
            if indiceHab < 1 then
                indiceHab = #disponiveisHab
            end
        elseif a == "baixo" then
            indiceHab = indiceHab + 1
            if indiceHab > #disponiveisHab then
                indiceHab = 1
            end
        elseif a == "cancelar" then
            fase = "escolha"
        elseif a == "confirmar" then
            local h = disponiveisHab[indiceHab]
            if (cooldowns[h.id] or 0) > 0 then
                table.insert(mensagens, h.nome .. " ainda nao esta pronta.")
            else
                h.usar(criarCtx())
                cooldowns[h.id] = h.cooldown
                if inimigo.vida <= 0 then
                    vencer()
                else
                    fase = "pausa"
                end
            end
        end
    elseif a == "confirmar" then
        if fase == "pausa" then
            if inimigoAtordoado then
                inimigoAtordoado = false
                table.insert(mensagens, cores.nome(inimigo, "O ", " esta atordoado e perde o turno."))
                if processarEfeitos() then
                    morrer()
                else
                    fase = "turno_inimigo"
                end
            else
                inimigoAtaca()
                if fase ~= "derrota" then
                    fase = "turno_inimigo"
                end
            end
        elseif fase == "turno_inimigo" then
            -- leu a resposta do inimigo; novo turno
            novoTurno()
            fase = "escolha"
            if jogador.efeitos.atordoamento then
                jogador.efeitos.atordoamento = nil
                table.insert(mensagens, {efeitos.lista.atordoamento.cor, "Estas atordoado! Perdes este turno."})
                fase = "pausa" -- o inimigo ataca logo a seguir
            end
        elseif fase == "vitoria" then
            local temReliquia = inimigo.boss and #jogador.reliquiasDisponiveis() > 0
            if jogador.habPendentes > 0 then
                jogo.mudar("habilidade", temReliquia)
            elseif temReliquia then
                jogo.mudar("reliquia")
            else
                jogo.mudar("portas")
            end
        else
            jogo.mudar("derrota")
        end
    end
end

function combate.desenhar()
    local fim = #mensagens - deslocamento
    local inicio = math.max(1, fim - MAX_LINHAS + 1)
    local ativos = {}
    for _, id in ipairs(efeitos.ordem) do
        local t = jogador.efeitos[id]
        if t then
            table.insert(ativos, efeitos.lista[id].cor)
            table.insert(ativos, efeitos.lista[id].nome .. "(" .. t .. ") ")
        end
    end
    if defendendo then
        table.insert(ativos, {0.6, 0.8, 1})
        table.insert(ativos, "Guarda")
    end
    if #ativos > 0 then
        love.graphics.print(ativos, 200, 50)
    end
    local frInimigo = inimigo.vida / inimigo.vida_max
    love.graphics.print({inimigo.cor or {1, 1, 1}, inimigo.nome, {1, 1, 1}, "   Vida: ", cores.daVida(frInimigo),
                         inimigo.vida .. "/" .. inimigo.vida_max}, 20, 20)

    local frJogador = jogador.vida / jogador.vida_max
    love.graphics.print({{1, 1, 1}, "Tu   Vida: ", cores.daVida(frJogador), jogador.vida .. "/" .. jogador.vida_max},
        20, 50)

    cores.barra(380, 24, 220, 16, mostradaInimigo)
    cores.barra(380, 54, 220, 16, mostradaJogador)

    for i = inicio, fim do
        love.graphics.print(mensagens[i], 20, 100 + (i - inicio) * 28)
    end

    if deslocamento > 0 then
        love.graphics.print("^ mais recente: R1", 380, 70)
    end
    if inicio > 1 then
        love.graphics.print("v mais antigo: L1", 20, 70)
    end

    if fase == "escolha" then
        for i, texto in ipairs(opcoes) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(prefixo .. texto, 20, 326 + (i - 1) * 28)
        end
    elseif fase == "loot" then
        for i, texto in ipairs(opcoesAtuais) do
            local prefixo = (i == indiceLoot) and "> " or "  "
            love.graphics.print(prefixo .. texto, 20, 340 + (i - 1) * 32)
        end
    elseif fase == "pocao" then
        for i, p in ipairs(disponiveis) do
            local prefixo = (i == indicePocao) and "> " or "  "
            love.graphics.print(cores.nome(p, prefixo,
                " x" .. jogador.quantas(p.id) .. " (+" .. jogador.curaDe(p) .. " vida -> " .. jogador.vidaApos(p) .. "/" ..
                    jogador.vida_max .. ")"), 20, 340 + (i - 1) * 32)
        end
        love.graphics.print("A - beber   B - voltar", 20, 440)
    elseif fase == "habilidade" then
        for i, h in ipairs(disponiveisHab) do
            local prefixo = (i == indiceHab) and "> " or "  "
            local cd = cooldowns[h.id] or 0
            love.graphics.print({{1, 1, 1}, prefixo, h.cor, h.nome, {0.6, 0.6, 0.6},
                                 (cd > 0) and ("  (pronta em " .. cd .. ")") or "  (pronta)"}, 20, 326 + (i - 1) * 28)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(disponiveisHab[indiceHab].descricao, 20, 440)
    else
        love.graphics.print("A - continuar", 20, 440)
    end
end

-- aproxima "atual" de "alvo" a cada frame
local function aproximar(atual, alvo, dt)
    atual = atual + (alvo - atual) * math.min(1, dt * 8)
    if math.abs(alvo - atual) < 0.002 then
        return alvo -- perto o suficiente: encaixa
    end
    return atual
end

function combate.atualizar(dt)
    mostradaInimigo = aproximar(mostradaInimigo, inimigo.vida / inimigo.vida_max, dt)
    mostradaJogador = aproximar(mostradaJogador, jogador.vida / jogador.vida_max, dt)
end

return combate
