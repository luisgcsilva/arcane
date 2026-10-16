local jogo = require("jogo")
local jogador = require("jogador")
local savegame = require("savegame")

local estado = {}

local oferta
local indice
local aviso
local feito
local depois -- true se, a seguir, ha uma escolha de reliquia (chefe)

local VERDE = {0.5, 1, 0.6}

local function sortear()
    local pool = jogador.habilidadesDisponiveis()
    oferta = {}
    while #oferta < 3 and #pool > 0 do
        table.insert(oferta, table.remove(pool, math.random(#pool)))
    end
    indice = 1
end

local function seguir()
    if depois then
        jogo.mudar("reliquia")
    else
        jogo.mudar("portas")
    end
end

function estado.entrar(depoisReliquia)
    depois = depoisReliquia
    aviso = ""
    feito = false
    sortear()
    if #oferta == 0 then
        seguir()
    end
end

function estado.acao(a)
    if feito then
        if a == "confirmar" then
            if jogador.habPendentes > 0 and #jogador.habilidadesDisponiveis() > 0 then
                feito = false
                aviso = ""
                sortear()
            else
                seguir()
            end
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
        local h = oferta[indice]
        jogador.aprenderHabilidade(h.id)
        jogador.habPendentes = math.max(0, jogador.habPendentes - 1)
        aviso = "Aprendeste " .. h.nome .. "!"
        feito = true
        savegame.gravar()
    end
end

function estado.desenhar()
    love.graphics.setColor(VERDE)
    love.graphics.print("NOVA HABILIDADE", 20, 20)
    love.graphics.setColor(1, 1, 1)

    if feito then
        love.graphics.print(aviso, 20, 100)
        love.graphics.print("A seguir", 20, 440)
        return
    end

    love.graphics.print("Subiste de nivel. Escolhe uma habilidade:", 20, 70)
    for i, h in ipairs(oferta) do
        local prefixo = (i == indice) and "> " or "  "
        love.graphics.print({{1, 1, 1}, prefixo, h.cor, h.nome}, 20, 120 + (i - 1) * 36)
    end

    local h = oferta[indice]
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(h.descricao, 20, 270, 600)
    love.graphics.print("Recarga: " .. h.cooldown .. " turnos", 20, 340)
    love.graphics.print("A escolher", 20, 440)
end

return estado
