local jogo = require("jogo")
local jogador = require("jogador")
local reliquias = require("reliquias")
local salas = require("salas")
local savegame = require("savegame")

local estado = {}

local oferta -- lista de definicoes
local indice
local aviso
local feito

local ROXO = {0.75, 0.5, 1}

function estado.entrar()
    jogador.especial = "reliquia"
    jogador.portas = nil
    jogador.inimigo = nil
    jogador.posVitoria = nil
    jogador.lootPendente = nil

    -- se vens de "Continuar", a oferta ja esta sorteada e gravada
    if not jogador.ofertaReliquias then
        local pool = jogador.reliquiasDisponiveis()
        local ids = {}
        while #ids < 3 and #pool > 0 do
            table.insert(ids, table.remove(pool, math.random(#pool)).id)
        end
        jogador.ofertaReliquias = ids
    end

    oferta = {}
    for _, id in ipairs(jogador.ofertaReliquias) do
        table.insert(oferta, reliquias.porId(id))
    end
    indice = 1
    aviso = ""
    feito = false
    savegame.gravar()
end

function estado.acao(a)
    if a == "inventario" then
        jogo.abrir("inventario")
        return
    end
    if a == "menu" then
        jogo.abrir("pocoes")
        return
    end

    if feito then
        if a == "confirmar" then
            jogo.mudar("portas", jogador.portas)
        end
        return
    end

    local n = #oferta
    if a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
    elseif a == "baixo" then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
    elseif a == "confirmar" then
        local r = jogador.darReliquia(oferta[indice].id)
        aviso = "Obtiveste " .. r.nome .. "!"
        jogador.especial = nil
        jogador.ofertaReliquias = nil
        jogador.portas = salas.gerarPortas(jogador.sala + 1, "boss")
        savegame.gravar()
        feito = true
    end
end

function estado.desenhar()
    love.graphics.setColor(ROXO)
    love.graphics.print("RELIQUIA", 20, 20)
    love.graphics.setColor(1, 1, 1)

    if feito then
        love.graphics.print(aviso, 20, 100)
        love.graphics.print("A seguir  X pocoes  SELECT mochila", 20, 440)
        return
    end

    love.graphics.print("O chefe deixa algo para tras. Escolhe uma:", 20, 70)
    for i, r in ipairs(oferta) do
        local prefixo = (i == indice) and "> " or "  "
        love.graphics.print({{1, 1, 1}, prefixo, r.cor, r.nome}, 20, 120 + (i - 1) * 36)
    end

    love.graphics.printf(oferta[indice].descricao, 20, 270, 600)
    love.graphics.print("A escolher  X pocoes  SELECT mochila", 20, 440)
end

return estado
