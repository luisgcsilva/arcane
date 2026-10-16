local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local savegame = require("savegame")
local reliquias = require("reliquias")

local inventario = {}

local indice
local aviso
local largar -- true quando esta a espera de confirmacao para largar
local aba -- "equip" ou "reliquias"
local indiceR -- cursor da lista de reliquias

local BRANCO = {1, 1, 1}

-- Texto colorido: so o nome tem a cor da raridade
local function textoItem(item, prefixo)
    local atributo = (item.tipo == "arma") and "ataque" or "defesa"
    return {BRANCO, prefixo, loot.cores[item.raridade], item.nome, BRANCO,
            " (" .. jogador.textoBonus(item) .. " " .. atributo .. ")"}
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
    aba = "equip"
    indiceR = 1
end

function inventario.acao(a)
    if a == "cancelar" or a == "inventario" then
        savegame.gravar()
        jogo.fechar()
        return
    end

    if a == "ombro_esq" or a == "ombro_dir" then
        aba = (aba == "equip") and "reliquias" or "equip"
        largar = false
        aviso = ""
        return
    end

    if a == "extra" then
        largar = false
        jogo.abrir("pocoes")
        return
    end

    if aba == "reliquias" then
        local k = #jogador.reliquias
        if k == 0 then
            return
        end
        if a == "cima" then
            indiceR = indiceR - 1
            if indiceR < 1 then
                indiceR = k
            end
        elseif a == "baixo" then
            indiceR = indiceR + 1
            if indiceR > k then
                indiceR = 1
            end
        end
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

    local CINZA = {0.5, 0.5, 0.5}
    local OURO = {1, 0.85, 0.2}
    local titulo = "MOCHILA (" .. #jogador.inventario .. "/" .. jogador.MAX_ITENS .. ")"
    local tituloR = "Reliquias (" .. #jogador.reliquias .. "/" .. #reliquias.lista .. ")"
    if aba == "equip" then
        love.graphics.print({OURO, titulo, CINZA, "   |   " .. tituloR}, 20, 20)
        love.graphics.print(equipado("Arma: ", jogador.arma), 20, 56)
        love.graphics.print(equipado("Armadura: ", jogador.armadura), 20, 84)
        if #jogador.inventario > 0 then
            love.graphics.print("Vale " .. loot.precoVenda(jogador.inventario[indice]) .. " moedas", 20, 370)
        end

    else
        love.graphics.print({CINZA, titulo .. "   |   ", OURO, tituloR}, 20, 20)
    end

    if aba == "reliquias" then
        if #jogador.reliquias == 0 then
            love.graphics.print("(ainda nao tens nenhuma. Os chefes oferecem uma.)", 20, 80)
        end
        for i, id in ipairs(jogador.reliquias) do
            local r = reliquias.porId(id)
            local prefixo = (i == indiceR) and "> " or "  "
            love.graphics.print({{1, 1, 1}, prefixo, r.cor, r.nome}, 20, 70 + (i - 1) * 30)
            local usada = (id == "cruz" and jogador.cruzUsada) and "  (usada)" or ""
            love.graphics.print({{1, 1, 1}, prefixo, r.cor, r.nome, {0.6, 0.6, 0.6}, usada}, 20, 70 + (i - 1) * 30)
        end
        local sel = jogador.reliquias[indiceR] and reliquias.porId(jogador.reliquias[indiceR])
        if sel then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(sel.descricao, 20, 340, 600)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Cima/baixo  L1/R1 equipamento  B fechar", 20, 440)
        return
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
end

return inventario
