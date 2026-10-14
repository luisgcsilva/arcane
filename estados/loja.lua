local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local mercador = require("mercador")
local savegame = require("savegame")

local loja = {}

local indice
local aviso

local DOURADO = {1, 0.85, 0.2}
local CINZA = {0.5, 0.5, 0.5}

function loja.entrar()
    indice = 1
    aviso = ""
end

function loja.acao(a)
    if a == "cancelar" then
        jogo.fechar()
        return
    elseif a == "inventario" then
        jogo.abrir("inventario") -- para vender
        return
    end

    local n = #mercador.stock
    if a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
        aviso = ""
    elseif a == "baixo" then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
        aviso = ""
    elseif a == "confirmar" then
        local ok, mensagem = mercador.comprar(indice)
        aviso = mensagem
        if ok then
            savegame.gravar()
        end
    end
end

function loja.desenhar()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("LOJA", 20, 20)
    love.graphics.print({DOURADO, "Moedas: " .. jogador.moedas}, 400, 20)

    for i, e in ipairs(mercador.stock) do
        local prefixo = (i == indice) and "> " or "  "
        local y = 80 + (i - 1) * 32

        if e.vendido then
            love.graphics.print({CINZA, prefixo .. e.item.nome .. " (esgotado)"}, 20, y)
        elseif e.tipo == "item" then
            local atributo = (e.item.tipo == "arma") and "ataque" or "defesa"
            love.graphics.print(loot.nomeColorido(e.item, prefixo,
                " +" .. e.item.bonus .. " " .. atributo .. " - " .. e.preco .. "m"), 20, y)
        else
            love.graphics.print(cores.nome(e.pocao, prefixo, " (+" .. e.pocao.cura .. " vida) - " .. e.preco .. "m"),
                20, y)
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(aviso, 20, 400)
    love.graphics.print("A comprar  SELECT vender  B sair", 20, 440)
end

return loja
