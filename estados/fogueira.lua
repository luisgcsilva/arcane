local jogo = require("jogo")
local jogador = require("jogador")
local salas = require("salas")
local savegame = require("savegame")
local registo = require("registo")

local fogueira = {}

local indice
local aviso
local feito -- true depois de escolheres: so falta carregar A para seguir

local LARANJA = {1, 0.6, 0.2}
local DOURADO = {1, 0.85, 0.2}

-- quanto curas de facto (40% da vida maxima, sem passar do maximo)
local function curaReal()
    local cura = math.ceil(jogador.vida_max * 0.5)
    return math.min(cura, jogador.vida_max - jogador.vida)
end

function fogueira.entrar()
    jogador.especial = "fogueira"
    jogador.portas = nil
    jogador.inimigo = nil
    indice = 1
    aviso = ""
    feito = false
    registo.add("  [fogueira] cura possivel: " .. curaReal())
    savegame.gravar()
end

-- Fecha a sala: a partir daqui a gravacao ja aponta para as portas seguintes
local function concluir(mensagem)
    aviso = mensagem
    jogador.especial = nil
    jogador.portas = salas.gerarPortas(jogador.sala + 1, "fogueira")
    savegame.gravar()
    feito = true
end

function fogueira.acao(a)
    -- mochila e pocoes funcionam sempre
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
            jogo.mudar("portas", jogador.portas) -- uma lista: retoma estas portas
        end
        return
    end

    if a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = 3
        end
        aviso = ""
    elseif a == "baixo" then
        indice = indice + 1
        if indice > 3 then
            indice = 1
        end
        aviso = ""
    elseif a == "confirmar" then
        if indice == 1 then
            if jogador.vida >= jogador.vida_max then
                aviso = "Ja tens a vida cheia."
            else
                local cura = curaReal()
                jogador.vida = jogador.vida + cura
                concluir("Descansas junto ao fogo e recuperas " .. cura .. " de vida.")
            end
        elseif indice == 2 then
            if not jogador.arma then
                aviso = "Nao tens nenhuma arma equipada."
            else
                jogador.arma.bonus = jogador.arma.bonus + 1
                concluir("Afias " .. jogador.arma.nome .. ": agora e +" .. jogador.arma.bonus .. " de ataque.")
            end
        else
            concluir("Segues caminho sem parar.")
        end
    end
end

function fogueira.desenhar()
    love.graphics.setColor(LARANJA)
    love.graphics.print("FOGUEIRA", 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)
    love.graphics.print({DOURADO, "Moedas: " .. jogador.moedas}, 420, 20)

    -- uma fogueira simples feita de triangulos
    love.graphics.setColor(1, 0.5, 0.1)
    love.graphics.polygon("fill", 540, 190, 500, 290, 580, 290)
    love.graphics.setColor(1, 0.85, 0.2)
    love.graphics.polygon("fill", 540, 230, 520, 290, 560, 290)
    love.graphics.setColor(0.35, 0.22, 0.1)
    love.graphics.rectangle("fill", 490, 290, 100, 12)
    love.graphics.setColor(1, 1, 1)

    love.graphics.print("Uma fogueira ainda acesa. So podes fazer uma coisa.", 20, 100)

    if not feito then
        local opcoes = {"Descansar (+" .. curaReal() .. " vida)", "Afiar a arma (+1 ataque)", "Seguir caminho"}
        for i, texto in ipairs(opcoes) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(prefixo .. texto, 20, 160 + (i - 1) * 36)
        end
    end

    love.graphics.print(aviso, 20, 380)
    love.graphics.print(feito and "A seguir  X pocoes  SELECT mochila" or "A escolher  X pocoes  SELECT mochila", 20,
        440)
end

return fogueira
