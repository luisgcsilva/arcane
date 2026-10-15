local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local mercador = require("mercador")
local savegame = require("savegame")
local registo = require("registo")

local loja = {}

local indice
local aviso
local pendente -- indice do item a espera de confirmacao (nil = nenhum)

local DOURADO = {1, 0.85, 0.2}
local CINZA = {0.5, 0.5, 0.5}

function loja.entrar()
    indice = 1
    aviso = ""
    pendente = nil
end

function loja.acao(a)
    if a == "cancelar" then
        if pendente then
            pendente = nil -- B com confirmacao aberta: so cancela a compra
            aviso = ""
        else
            jogo.fechar()
        end
        return
    elseif a == "inventario" then
        pendente = nil
        jogo.abrir("inventario") -- para vender
        return
    end

    -- qualquer coisa que nao seja A cancela a confirmacao
    if a ~= "confirmar" then
        pendente = nil
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
        local e = mercador.stock[indice]
        if e.vendido then
            aviso = "Esse ja nao esta disponivel."
        elseif pendente ~= indice then
            -- primeiro A: pede confirmacao
            pendente = indice
            local nome = mercador.nomeDe(e)
            aviso = "Comprar " .. nome .. " por " .. e.preco .. " moedas? A para confirmar."
        else
            -- segundo A no mesmo item: compra
            pendente = nil
            local ok, mensagem = mercador.comprar(indice)
            aviso = mensagem
            if ok then
                savegame.gravar()
            end
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
            love.graphics.print({CINZA, prefixo .. mercador.nomeDe(e) .. " (esgotado)"}, 20, y)
        elseif e.tipo == "item" then
            local atributo = (e.item.tipo == "arma") and "ataque" or "defesa"
            love.graphics.print(loot.nomeColorido(e.item, prefixo,
                " +" .. e.item.bonus .. " " .. atributo .. " - " .. e.preco .. "m"), 20, y)
        elseif e.tipo == "reliquia" then
            love.graphics.print(cores.nome(e.reliquia, prefixo, " (reliquia) - " .. e.preco .. "m"), 20, y)
        else
            love.graphics.print(cores.nome(e.pocao, prefixo,
                " (+" .. jogador.curaDe(e.pocao) .. " vida) - " .. e.preco .. "m"), 20, y)
        end
    end
    local sel = mercador.stock[indice]
    if sel and sel.tipo == "reliquia" and not sel.vendido then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(sel.reliquia.descricao, 20, 370, 600)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(aviso, 20, 400)
    love.graphics.print(pendente and "A confirmar  outra tecla cancela" or "A comprar  SELECT inventario  B sair", 20,
        440)
end

return loja
