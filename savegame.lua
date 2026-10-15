local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")
local inimigos = require("inimigos")
local salas = require("salas")
local eventos = require("eventos")
local armazem = require("armazem")
local classes = require("classes")
local reliquias = require("reliquias")
local habilidades = require("habilidades")

local savegame = {}

local FICHEIRO = "partida.txt"
local VERSAO = 1

-- Chaves de valor numerico simples
local numericas = {
    vida_max = true,
    vida = true,
    ataque_base = true,
    sala = true,
    moedas = true,
    nivel = true,
    xp = true
}

local especiais = {
    fogueira = true,
    tesouro = true,
    evento = true,
    reliquia = true
}

savegame.ultimoErro = nil

-- ---------- item <-> texto ("Nome|tipo|bonus|raridade") ----------

local function itemParaTexto(i)
    return i.nome .. "|" .. i.tipo .. "|" .. i.bonus .. "|" .. i.raridade
end

local function textoParaItem(texto)
    local nome, tipo, bonus, raridade = texto:match("^([^|]+)|([^|]+)|(%d+)|([^|]+)$")
    if not nome then
        return nil
    end
    if tipo ~= "arma" and tipo ~= "armadura" then
        return nil
    end
    if not loot.cores[raridade] then
        return nil
    end
    return {
        nome = nome,
        tipo = tipo,
        bonus = tonumber(bonus),
        raridade = raridade
    }
end

-- ---------- gravar ----------

function savegame.existe()
    return armazem.existe(FICHEIRO)
end

function savegame.apagar()
    armazem.remover(FICHEIRO)
end

function savegame.gravar()
    local l = {}
    local function add(chave, valor)
        table.insert(l, chave .. "=" .. valor)
    end

    add("versao", VERSAO)
    add("vida_max", jogador.vida_max)
    add("vida", jogador.vida)
    add("ataque_base", jogador.ataque_base)
    add("sala", jogador.sala)
    add("moedas", jogador.moedas)
    add("nivel", jogador.nivel)
    add("xp", jogador.xp)

    if jogador.classe then
        add("classe", jogador.classe)
    end
    if jogador.arma then
        add("arma", itemParaTexto(jogador.arma))
    end
    if jogador.armadura then
        add("armadura", itemParaTexto(jogador.armadura))
    end
    for _, item in ipairs(jogador.inventario) do
        add("item", itemParaTexto(item))
    end
    for id, qtd in pairs(jogador.pocoes) do
        add("pocao", id .. "|" .. qtd)
    end
    for nome, valor in pairs(jogador.stats) do
        add("stat", nome .. "|" .. valor)
    end
    for _, id in ipairs(jogador.reliquias) do
        add("reliquia", id)
    end
    if jogador.ofertaReliquias then
        for _, id in ipairs(jogador.ofertaReliquias) do
            add("oferta", id)
        end
    end
    for _, id in ipairs(jogador.habilidades) do
        add("habilidade", id)
    end

    if jogador.portas then
        for _, tipo in ipairs(jogador.portas) do
            add("porta", tipo)
        end
    elseif jogador.especial then
        add("especial", jogador.especial)
        if jogador.eventoId then
            add("evento_id", jogador.eventoId)
        end
    elseif jogador.inimigo then
        local e = jogador.inimigo
        add("inimigo",
            (e.base or e.nome) .. "|" .. e.vida .. "|" .. e.vida_max .. "|" .. e.ataque .. "|" .. (e.elite and 1 or 0))
    else
        add("loja", "1")
    end

    local ok, erro = armazem.escrever(FICHEIRO, table.concat(l, "\n") .. "\n")
    if ok then
        savegame.ultimoErro = nil
    else
        savegame.ultimoErro = tostring(erro)
        print("Nao consegui gravar: " .. savegame.ultimoErro)
    end
end

-- ---------- carregar ----------

local function modeloPorNome(nome)
    for _, m in pairs(inimigos) do
        if m.nome == nome then
            return m
        end
    end
end

-- Devolve o inimigo da sala (para o explorar usar) ou nil se a gravacao
-- for invalida. So altera o jogador se TUDO estiver correcto.
function savegame.carregar()

    if not savegame.existe() then
        return nil
    end

    local pocoesValidas = {}
    for _, p in ipairs(pocoes.lista) do
        pocoesValidas[p.id] = true
    end

    local d = {
        inventario = {},
        pocoes = {},
        stats = {},
        portas = {},
        reliquias = {},
        oferta = {},
        habilidades = {}
    }
    local versaoOk = false

    for linha in armazem.linhas(FICHEIRO) do
        local chave, valor = linha:match("^([%w_]+)=(.+)$")
        if not chave then
            return nil
        end

        if chave == "versao" then
            versaoOk = (tonumber(valor) == VERSAO)

        elseif numericas[chave] then
            d[chave] = tonumber(valor)
            if not d[chave] then
                return nil
            end

        elseif chave == "arma" or chave == "armadura" then
            local item = textoParaItem(valor)
            if not item or item.tipo ~= chave then
                return nil
            end
            d[chave] = item

        elseif chave == "item" then
            local item = textoParaItem(valor)
            if not item then
                return nil
            end
            table.insert(d.inventario, item)

        elseif chave == "pocao" then
            local id, qtd = valor:match("^([%w_]+)|(%d+)$")
            if not id or not pocoesValidas[id] then
                return nil
            end
            d.pocoes[id] = tonumber(qtd)

        elseif chave == "stat" then
            local nome, qtd = valor:match("^([%w_]+)|(%d+)$")
            if not nome then
                return nil
            end
            d.stats[nome] = tonumber(qtd)

        elseif chave == "inimigo" then
            local nome, vida, vmax, atq, elite = valor:match("^([^|]+)|(%d+)|(%d+)|(%d+)|?(%d*)$")
            local modelo = nome and modeloPorNome(nome)
            if not modelo then
                return nil
            end
            local e = {}
            for k, v in pairs(modelo) do
                e[k] = v
            end
            e.vida, e.vida_max, e.ataque = tonumber(vida), tonumber(vmax), tonumber(atq)
            if elite == "1" then
                e.elite = true
                e.base = modelo.nome
                e.nome = "Elite " .. modelo.nome
            end
            d.inimigo = e
        elseif chave == "loja" then
            d.loja = true
        elseif chave == "porta" then
            if not salas.valido(valor) then
                return nil
            end
            table.insert(d.portas, valor)
        elseif chave == "especial" then
            if not especiais[valor] then
                return nil
            end
            d.especial = valor
        elseif chave == "evento_id" then
            if not eventos.existe(valor) then
                return nil
            end
            d.eventoId = valor
        elseif chave == "classe" then
            if not classes.existe(valor) then
                return nil
            end
            d.classe = valor
        elseif chave == "reliquia" then
            if not reliquias.existe(valor) then
                return nil
            end
            table.insert(d.reliquias, valor)

        elseif chave == "oferta" then
            if not reliquias.existe(valor) then
                return nil
            end
            table.insert(d.oferta, valor)
        elseif chave == "habilidade" then
            if not habilidades.existe(valor) then
                return nil
            end
            table.insert(d.habilidades, valor)
        end
        -- chaves desconhecidas sao ignoradas
    end

    -- campos obrigatorios e intervalos sensatos
    local temPortas = #d.portas > 0
    local motivo
    if not versaoOk then
        motivo = "versao"
    elseif not d.vida_max then
        motivo = "falta vida_max"
    elseif not d.vida then
        motivo = "falta vida"
    elseif not d.ataque_base then
        motivo = "falta ataque_base"
    elseif not d.sala then
        motivo = "falta sala"
    elseif not (d.inimigo or d.loja or temPortas) then
        motivo = "falta inimigo/loja/portas"
    elseif d.vida < 1 or d.vida > d.vida_max then
        motivo = "vida fora do intervalo"
    elseif #d.inventario > jogador.MAX_ITENS then
        motivo = "mochila demasiado cheia"
    elseif #d.portas > salas.MAX_PORTAS then
        motivo = "portas a mais"
    elseif d.moedas and d.moedas < 0 then
        motivo = "moedas negativas"
    elseif not (d.inimigo or d.loja or temPortas or d.especial) then
        motivo = "falta inimigo/loja/portas"
    end
    if not motivo and d.especial == "reliquia" and #d.oferta == 0 then
        motivo = "oferta de reliquia vazia"
    end
    if motivo then
        print("Gravacao invalida: " .. motivo)
        return nil, motivo
    end

    -- tudo valido: agora sim, aplica ao jogador
    jogador.reiniciar()
    jogador.vida_max = d.vida_max
    jogador.vida = d.vida
    jogador.ataque_base = d.ataque_base
    jogador.sala = d.sala
    jogador.arma = d.arma
    jogador.armadura = d.armadura
    jogador.inventario = d.inventario
    jogador.pocoes = d.pocoes
    jogador.moedas = d.moedas or 0
    jogador.portas = temPortas and d.portas or nil
    jogador.nivel = d.nivel or 1
    jogador.xp = d.xp or 0
    jogador.classe = d.classe
    jogador.reliquias = d.reliquias
    jogador.ofertaReliquias = (#d.oferta > 0) and d.oferta or nil
    jogador.habilidades = d.habilidades
    for nome, valor in pairs(d.stats) do
        if jogador.stats[nome] ~= nil then
            jogador.stats[nome] = valor
        end
    end

    if temPortas then
        return "portas", d.portas
    elseif d.especial then
        return d.especial -- o nome do estado e igual ao id da sala
    elseif d.inimigo then
        return "explorar", (d.inimigo.boss and "boss" or "combate"), d.inimigo
    end
    return "explorar", "loja"
end

-- Devolve so a sala da gravacao (numero) ou nil. Nao toca no jogador.
function savegame.resumo()
    if not savegame.existe() then
        return nil
    end
    for linha in armazem.linhas(FICHEIRO) do
        local sala = linha:match("^sala=(%d+)$")
        if sala then
            return tonumber(sala)
        end
    end
    return nil
end

return savegame
