local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local savegame = require("savegame")

local inventario = {}

local indice
local aviso
local largar -- true quando esta a espera de confirmacao para largar

local BRANCO = {1, 1, 1}

-- Texto colorido: so o nome tem a cor da raridade
local function textoItem(item, prefixo)
    local atributo = (item.tipo == "arma") and "ataque" or "defesa"
    return
        {BRANCO, prefixo, loot.cores[item.raridade], item.nome, BRANCO, " (+" .. item.bonus .. " " .. atributo .. ")"}
end

local function equipado(rotulo, item)
    if item then
        return textoItem(item, rotulo)
    end
    return rotulo .. "-"
end

function inventario.entrar()
    indice = 1
    aviso = ""
    largar = false
end

function inventario.acao(a)
    if a == "cancelar" or a == "inventario" then
        savegame.gravar()
        jogo.fechar()
        return
    end
    if a == "extra" then
        largar = false
        jogo.abrir("pocoes")
        return
    end

    local n = #jogador.inventario
    if n == 0 then
        return
    end

    -- qualquer coisa que nao seja X cancela a confirmacao de largar
    if a ~= "menu" then
        largar = false
    end

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
        local item = jogador.inventario[indice]
        jogador.equipar(indice)
        aviso = "Equipas " .. item.nome .. "."
    elseif a == "menu" then
        if largar then
            local item, ganho = jogador.vender(indice)
            aviso = "Vendes " .. item.nome .. " por " .. ganho .. " moedas."
            largar = false
        else
            largar = true
            aviso = "X outra vez: vender por " .. loot.precoVenda(jogador.inventario[indice]) .. " moedas."
        end
    end

    -- a lista pode ter encolhido: nao deixar o cursor fora dela
    indice = math.max(1, math.min(indice, #jogador.inventario))
end

function inventario.desenhar()
    love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 400, 20)
    love.graphics.print("MOCHILA (" .. #jogador.inventario .. "/" .. jogador.MAX_ITENS .. ")", 20, 20)
    love.graphics.print(equipado("Arma: ", jogador.arma), 20, 56)
    love.graphics.print(equipado("Armadura: ", jogador.armadura), 20, 84)
    if #jogador.inventario > 0 then
        love.graphics.print("Vale " .. loot.precoVenda(jogador.inventario[indice]) .. " moedas", 20, 370)
    end
    love.graphics.print(aviso, 20, 400)
    love.graphics.print("A equipar  X vender  Y pocoes  B fechar", 20, 440)
    if #jogador.inventario == 0 then
        love.graphics.print("(vazia)", 20, 140)
    else
        for i, item in ipairs(jogador.inventario) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(textoItem(item, prefixo), 20, 140 + (i - 1) * 28)
        end
    end

    love.graphics.print(aviso, 20, 400)
    love.graphics.print("A - equipar   X - largar   Y - pocoes  B - fechar", 20, 440)
end

return inventario
