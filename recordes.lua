local recordes = {}
local armazem = require("armazem")

local FICHEIRO = "recordes.txt"

-- Os valores iniciais definem tambem que chaves sao validas
recordes.dados = {
    melhor_sala = 0,
    total_inimigos = 0,
    partidas = 0,
    vitorias = 0
}

function recordes.carregar()
    if not armazem.existe(FICHEIRO) then
        return
    end
    for linha in armazem.linhas(FICHEIRO) do
        local chave, valor = linha:match("^([%w_]+)=(%d+)$")
        if chave and recordes.dados[chave] ~= nil then
            recordes.dados[chave] = tonumber(valor)
        end
    end
end

function recordes.gravar()
    local linhas = {}
    for chave, valor in pairs(recordes.dados) do
        table.insert(linhas, chave .. "=" .. valor)
    end
    local ok, erro = armazem.escrever(FICHEIRO, table.concat(linhas, "\n") .. "\n")
    if not ok then
        print("Nao consegui gravar: " .. tostring(erro))
    end
end

-- Chamada no fim de cada partida. Devolve true se bateste o recorde.
function recordes.registarFim(sala, inimigos, venceu)
    local d = recordes.dados
    local novo = sala > d.melhor_sala
    if novo then
        d.melhor_sala = sala
    end
    d.total_inimigos = d.total_inimigos + inimigos
    d.partidas = d.partidas + 1
    if venceu then
        d.vitorias = d.vitorias + 1
    end
    recordes.gravar()
    return novo
end

return recordes
