local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local cores = require("cores")
local savegame = require("savegame")
local reliquias = require("reliquias")
local ui = require("ui")
local sprites = require("sprites")

local inventario = {}

local indice
local aviso
local largar -- true quando esta a espera de confirmacao para largar
local aba -- "equip" ou "reliquias"
local indiceR -- cursor da lista de reliquias
local equiparPendente -- true quando espera confirmacao para equipar
local corAviso = {1, 1, 1}

local BRANCO = {1, 1, 1}
local CINZA = {0.5, 0.5, 0.5}
local OURO = {1, 0.85, 0.2}

-- Primeiro item visivel numa lista com janela de `tam` linhas, a manter o cursor a vista
local function primeiroVisivel(sel, n, tam)
    local primeiro = math.min(sel - math.floor(tam / 2), n - tam + 1)
    return math.max(1, primeiro)
end

-- Texto colorido: so o nome tem a cor da raridade
local function textoItem(item, prefixo)
    local atributo = (item.tipo == "arma") and "ataque" or "defesa"
    return {BRANCO, prefixo, loot.cores[item.raridade], item.nome, BRANCO,
            " (" .. jogador.textoBonus(item) .. " " .. atributo .. ")"}
end

-- Uma ranhura de equipamento: icone do slot, moldura na cor da raridade e texto
local function ranhura(tipo, item, rotulo, y)
    local altura = love.graphics.getFont():getHeight()
    if item and loot.caminhoIcone(item) then
        love.graphics.setColor(ui.FUNDO)
        love.graphics.rectangle("fill", 20, y, 32, 32)
        ui.icone(item, 20, y, 2)
    else
        ui.slot((tipo == "arma") and "espada" or "peitoral", 20, y, 2)
    end
    local ty = y + (32 - altura) / 2
    if item then
        love.graphics.setColor(loot.cores[item.raridade])
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 19, y - 1, 34, 34)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(textoItem(item, rotulo), 64, ty)
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.print({CINZA, rotulo .. "-"}, 64, ty)
    end
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
    corAviso = {1, 1, 1}
    equiparPendente = false
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
        equiparPendente = false
        aviso = ""
        return
    end

    if a == "extra" then
        largar = false
        equiparPendente = false
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

    if a ~= "confirmar" then
        equiparPendente = false
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
        local atual = jogador[item.tipo]
        if not equiparPendente then
            -- primeiro A: mostra o que muda e pede confirmacao
            equiparPendente = true
            local atributo = (item.tipo == "arma") and "ataque" or "defesa"
            local delta = item.bonus - (atual and atual.bonus or 0)
            if atual then
                aviso =
                    "Trocar " .. atual.nome .. " (+" .. atual.bonus .. ") por " .. item.nome .. " (+" .. item.bonus ..
                        "): " .. (delta >= 0 and "+" or "") .. delta .. " " .. atributo .. ". A para confirmar."
            else
                aviso = "Equipar " .. item.nome .. " (+" .. item.bonus .. " " .. atributo .. ")? A para confirmar."
            end
            corAviso = (delta > 0 and {0.4, 1, 0.4}) or (delta < 0 and {1, 0.4, 0.4}) or {1, 1, 1}
        else
            -- segundo A no mesmo item: equipa
            equiparPendente = false
            jogador.equipar(indice)
            aviso = "Equipas " .. item.nome .. "." .. (atual and (" " .. atual.nome .. " volta para a mochila.") or "")
            corAviso = {1, 1, 1}
        end
    elseif a == "menu" then
        if largar then
            local item, ganho = jogador.vender(indice)
            aviso = "Vendes " .. item.nome .. " por " .. ganho .. " moedas."
            corAviso = {1, 1, 1}
            largar = false
        else
            largar = true
            aviso = "X outra vez: vender por " .. loot.precoVenda(jogador.inventario[indice]) .. " moedas."
            corAviso = {1, 0.85, 0.2}
        end
    end

    -- a lista pode ter encolhido: nao deixar o cursor fora dela
    indice = math.max(1, math.min(indice, #jogador.inventario))
end

function inventario.desenhar()
    love.graphics.setColor(1, 1, 1)
    local altura = love.graphics.getFont():getHeight()
    local n = #jogador.inventario

    -- love.graphics.print({OURO, "Moedas: " .. jogador.moedas}, 400, 20)
    ui.moedas(400, 20, jogador.moedas)
    local titulo = "MOCHILA (" .. n .. "/" .. jogador.MAX_ITENS .. ")"
    local tituloR = "Relíquias (" .. #jogador.reliquias .. "/" .. #reliquias.lista .. ")"
    if aba == "equip" then
        love.graphics.print({OURO, titulo, CINZA, "   |   " .. tituloR}, 20, 20)
    else
        love.graphics.print({CINZA, titulo .. "   |   ", OURO, tituloR}, 20, 20)
    end
    ui.linha(20, 50, 600, 2)

    ---------- separador das reliquias ----------
    if aba == "reliquias" then
        local JANELA = 7
        local k = #jogador.reliquias
        ui.painel("ouro", 10, 60, 620, 270, 2, ui.FUNDO)
        love.graphics.setColor(1, 1, 1)
        if k == 0 then
            love.graphics.printf("(ainda não tens nenhuma. Os chefes oferecem uma.)", 36, 80, 568)
        end
        local primeiro = primeiroVisivel(indiceR, k, JANELA)
        for i = primeiro, math.min(k, primeiro + JANELA - 1) do
            local id = jogador.reliquias[i]
            local r = reliquias.porId(id)
            local y = 72 + (i - primeiro) * 32
            local usada = (id == "cruz" and jogador.cruzUsada) and "  (usada)" or ""
            if i == indiceR and not ui.cursor(24, y + (32 - 18) / 2, 2) then
                love.graphics.print(">", 30, y + (32 - altura) / 2)
            end
            ui.imagem(reliquias.caminhoIcone(r), 54, y, 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print({r.cor, r.nome, {0.6, 0.6, 0.6}, usada}, 94, y + (32 - altura) / 2)
        end
        if primeiro > 1 then
            ui.seta("cima", 596, 76, 2)
        end
        if primeiro + JANELA - 1 < k then
            ui.seta("baixo", 596, 292, 2)
        end
        local sel = jogador.reliquias[indiceR] and reliquias.porId(jogador.reliquias[indiceR])
        if sel then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(sel.descricao, 20, 340, 600)
        end
        love.graphics.setColor(1, 1, 1)
        sprites.ajuda({{"L1", "equipamento"}, {"B", "fechar"}}, 20, 446)
        return
    end

    ---------- separador do equipamento ----------
    ranhura("arma", jogador.arma, "Arma: ", 58)
    ranhura("armadura", jogador.armadura, "Armadura: ", 96)

    local JANELA = 7
    ui.painel("ouro", 10, 134, 620, 254, 2, ui.FUNDO)
    love.graphics.setColor(1, 1, 1)
    if n == 0 then
        love.graphics.print("(vazia)", 36, 152)
    else
        local primeiro = primeiroVisivel(indice, n, JANELA)
        for i = primeiro, math.min(n, primeiro + JANELA - 1) do
            local item = jogador.inventario[i]
            local y = 146 + (i - primeiro) * 32
            if i == indice and not ui.cursor(28, y + (32 - 18) / 2, 2) then
                love.graphics.print(">", 30, y + (32 - altura) / 2)
            end
            ui.icone(item, 54, y, 2)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(loot.nomeColorido(item, "", ""), 94, y + (32 - altura) / 2)
        end
        if primeiro > 1 then
            ui.seta("cima", 596, 146, 2)
        end
        if primeiro + JANELA - 1 < n then
            ui.seta("baixo", 596, 342, 2)
        end
        local sel = jogador.inventario[indice]
        if sel then
            local atributo = (sel.tipo == "arma") and "ataque" or "defesa"
            local cor = loot.cores[sel.raridade]

            -- icone grande com moldura na cor da raridade
            love.graphics.setColor(cor)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", 511, 148, 68, 68)
            love.graphics.setLineWidth(1)
            ui.icone(sel, 513, 150, 4)

            -- detalhes por baixo, centrados na coluna (x=470 a 620)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(jogador.textoBonus(sel) .. " " .. atributo, 470, 224, 150, "center")
            love.graphics.printf({cor, sel.raridade}, 470, 250, 150, "center")
            love.graphics.printf((jogador.linhaDiferenca(sel)), 470, 280, 150, "center")

            -- "Vale [moeda] N", centrado na coluna
            local valor = loot.precoVenda(sel)
            local f = love.graphics.getFont()
            local rotulo = "Vale "
            local largura = f:getWidth(rotulo) + 32 + 6 + f:getWidth(tostring(valor))
            local x0 = 545 - largura / 2
            local y0 = 336
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(rotulo, x0, y0 + (32 - f:getHeight()) / 2)
            ui.moedas(x0 + f:getWidth(rotulo), y0, valor, 2)
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf({corAviso, aviso}, 20, 394, 600)
    sprites.ajuda({{"A", "equipar"}, {"X", "vender"}, {"Y", "poções"}, {"B", "fechar"}}, 20, 446)
end

return inventario
