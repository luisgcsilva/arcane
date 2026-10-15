local armazem = require("armazem")
local jogador = require("jogador")

local historico = {}

local FICHEIRO = "historico.txt"
local MAX = 10 -- quantas partidas se guardam

-- Campos guardados, por ordem. Para guardar mais um dado, acrescenta aqui
-- e preenche-o na funcao registar().
local CAMPOS = {"numero", "data", "classe", "nivel", "sala", "vida_max", "ataque", "defesa", "moedas", "arma",
                "armadura", "mochila", "inimigos", "chefes", "dano_causado", "dano_sofrido", "pocoes", "causa",
                "recorde"}

historico.partidas = {} -- a mais recente primeiro

-- "chave=valor;chave=valor" -> tabela (valores ficam como texto)
local function analisar(linha)
    local p = {}
    for chave, valor in linha:gmatch("([%w_]+)=([^;]*)") do
        p[chave] = valor
    end
    return p
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
function historico.registar(novoRecorde, numero)
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
        arma = jogador.arma and (jogador.arma.nome .. " +" .. jogador.arma.bonus) or "-",
        armadura = jogador.armadura and (jogador.armadura.nome .. " +" .. jogador.armadura.bonus) or "-",
        mochila = (#nomes > 0) and table.concat(nomes, ", ") or "-",
        inimigos = s.inimigos,
        chefes = s.chefes,
        dano_causado = s.dano_causado,
        dano_sofrido = s.dano_sofrido,
        pocoes = s.pocoes,
        causa = jogador.matadoPor or "?",
        recorde = novoRecorde and 1 or 0
    }

    table.insert(historico.partidas, 1, p)
    while #historico.partidas > MAX do
        table.remove(historico.partidas)
    end
    gravar()
end

return historico
