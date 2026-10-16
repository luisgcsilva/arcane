local armazem = require("armazem")
local jogador = require("jogador")
local loot = require("loot")
local inimigos = require("inimigos")

local historico = {}

local FICHEIRO = "historico.txt"
local MAX = 10 -- quantas partidas se guardam

-- Campos guardados, por ordem. Para guardar mais um dado, acrescenta aqui
-- e preenche-o na funcao registar().
local CAMPOS = {"numero", "data", "classe", "nivel", "sala", "vida_max", "ataque", "defesa", "moedas", "arma",
                "armadura", "inimigos", "chefes", "dano_causado", "dano_sofrido", "pocoes", "causa", "cruz", "recorde"}

historico.partidas = {} -- a mais recente primeiro

-- "chave=valor;chave=valor" -> tabela (valores ficam como texto)
local function analisar(linha)
    local p = {}
    for chave, valor in linha:gmatch("([%w_]+)=([^;]*)") do
        p[chave] = valor
    end
    return p
end

local BRANCO = {1, 1, 1}

-- Guardamos so "Nome +bonus"; a cor vem da raridade, procurada pelo nome
local function itemParaTexto(i)
    return i.nome .. " +" .. i.bonus
end

-- "Nome +3" -> o texto a mostrar e a cor da raridade
local function parteItem(texto)
    texto = texto:gsub("@%a+$", "") -- aceita entradas com o formato anterior (@raridade)
    local nome, bonus = texto:match("^(.-) %+(%d+)$")
    if nome then
        local raridade = loot.raridadeDe(nome)
        return nome .. " +" .. bonus, raridade and loot.cores[raridade] or BRANCO
    end
    return texto, BRANCO
end
-- Texto colorido para o ecra: prefixo + um ou mais itens separados por ", "
function historico.itens(texto, prefixo)
    local t = {BRANCO, prefixo}
    if texto == "-" or texto == "" then
        table.insert(t, BRANCO)
        table.insert(t, "-")
        return t
    end
    local primeiro = true
    for parte in (texto .. ", "):gmatch("(.-), ") do
        if not primeiro then
            table.insert(t, BRANCO)
            table.insert(t, ", ")
        end
        local nome, cor = parteItem(parte)
        table.insert(t, cor)
        table.insert(t, nome)
        primeiro = false
    end
    return t
end

-- Cor do inimigo pelo nome ("Elite Goblin" usa a cor do Goblin)
function historico.corInimigo(nome)
    local base = nome:gsub("^Elite ", "")
    for _, m in pairs(inimigos) do
        if m.nome == base then
            return m.cor or BRANCO
        end
    end
    return BRANCO
end

local function gravar()
    local linhas = {}
    for _, p in ipairs(historico.partidas) do
        local partes = {}
        for _, k in ipairs(CAMPOS) do
            table.insert(partes, k .. "=" .. tostring(p[k] or ""))
        end
        table.insert(linhas, table.concat(partes, ";"))
    end
    armazem.escrever(FICHEIRO, table.concat(linhas, "\n") .. "\n")
end

function historico.carregar()
    historico.partidas = {}
    for linha in armazem.linhas(FICHEIRO) do
        local p = analisar(linha)
        if p.sala then
            table.insert(historico.partidas, p)
        end -- ignora linhas estragadas
    end
    while #historico.partidas > MAX do
        table.remove(historico.partidas)
    end
end

-- Chamada uma vez por derrota (no derrota.entrar)
function historico.registar(novoRecorde, numero, venceu)
    local s = jogador.stats
    local nomes = {}
    for _, item in ipairs(jogador.inventario) do
        table.insert(nomes, item.nome .. " +" .. item.bonus)
    end

    local p = {
        numero = numero,
        data = os.date("%Y-%m-%d %H:%M"),
        classe = jogador.defClasse().nome or "Aventureiro",
        nivel = jogador.nivel,
        sala = jogador.sala,
        vida_max = jogador.vida_max,
        ataque = jogador.ataqueTotal(),
        defesa = jogador.defesaTotal(),
        moedas = jogador.moedas,
        arma = jogador.arma and (jogador.arma.nome .. " +" .. (jogador.arma.bonus + jogador.forja.arma)) or "-",
        armadura = jogador.armadura and
            (jogador.armadura.nome .. " +" .. (jogador.armadura.bonus + jogador.forja.armadura)) or "-",
        inimigos = s.inimigos,
        chefes = s.chefes,
        dano_causado = s.dano_causado,
        dano_sofrido = s.dano_sofrido,
        pocoes = s.pocoes,
        causa = jogador.matadoPor or "?",
        recorde = novoRecorde and 1 or 0,
        cruz = jogador.cruzUsada and 1 or 0,
        vitoria = venceu and 1 or 0
    }

    table.insert(historico.partidas, 1, p)
    while #historico.partidas > MAX do
        table.remove(historico.partidas)
    end
    gravar()
end

return historico
