local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")
local inimigos = require("inimigos")

local savegame = {}

local FICHEIRO = "partida.txt"
local VERSAO = 1

-- Chaves de valor numerico simples
local numericas = {
    vida_max = true,
    vida = true,
    ataque_base = true,
    sala = true,
    moedas = true
}

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
    return love.filesystem.getInfo(FICHEIRO) ~= nil
end

function savegame.apagar()
    love.filesystem.remove(FICHEIRO)
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

    local e = jogador.inimigo
    if e then
        add("inimigo", e.nome .. "|" .. e.vida .. "|" .. e.vida_max .. "|" .. e.ataque)
    else
        add("loja", "1")
    end

    local ok, erro = love.filesystem.write(FICHEIRO, table.concat(l, "\n") .. "\n")
    if not ok then
        print("Nao consegui gravar: " .. tostring(erro))
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
        stats = {}
    }
    local versaoOk = false

    for linha in love.filesystem.lines(FICHEIRO) do
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
            local nome, vida, vmax, atq = valor:match("^([^|]+)|(%d+)|(%d+)|(%d+)$")
            local modelo = nome and modeloPorNome(nome)
            if not modelo then
                return nil
            end
            local e = {}
            for k, v in pairs(modelo) do
                e[k] = v
            end
            e.vida, e.vida_max, e.ataque = tonumber(vida), tonumber(vmax), tonumber(atq)
            d.inimigo = e
        elseif chave == "loja" then
            d.loja = true
        end
        -- chaves desconhecidas sao ignoradas
    end

    -- campos obrigatorios e intervalos sensatos
    if not (versaoOk and d.vida_max and d.vida and d.ataque_base and d.sala and (d.inimigo or d.loja)) then
        return nil
    end
    if d.moedas and d.moedas < 0 then
        return nil
    end
    if d.vida < 1 or d.vida > d.vida_max then
        return nil
    end
    if #d.inventario > jogador.MAX_ITENS then
        return nil
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
    for nome, valor in pairs(d.stats) do
        if jogador.stats[nome] ~= nil then
            jogador.stats[nome] = valor
        end
    end
    return d.inimigo or "loja"
end

-- Devolve so a sala da gravacao (numero) ou nil. Nao toca no jogador.
function savegame.resumo()
    if not savegame.existe() then
        return nil
    end
    for linha in love.filesystem.lines(FICHEIRO) do
        local sala = linha:match("^sala=(%d+)$")
        if sala then
            return tonumber(sala)
        end
    end
    return nil
end

return savegame
