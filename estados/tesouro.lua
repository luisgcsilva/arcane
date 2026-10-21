local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local salas = require("salas")
local savegame = require("savegame")
local registo = require("registo")
local cores = require("cores")
local ui = require("ui")
local sprites = require("sprites")

local tesouro = {}

local mensagens
local aberto
local fase -- "fechado", "escolha" ou "aberto"
local pendente -- item a espera de decisao
local opcoes, acoes, indice
local bauCheio -- true quando o bau abriu com moedas dentro

local DOURADO = {1, 0.85, 0.2}
local BRANCO = {1, 1, 1}

local function sortearBau()
    local sorte = math.random(100)
    if sorte <= 15 then
        -- o dano real so e calculado ao abrir (nunca te mata)
        return {
            tipo = "armadilha",
            dano = math.max(2, math.floor(jogador.vida_max * 0.15))
        }
    elseif sorte <= 55 then
        return {
            tipo = "item",
            item = loot.sortear(jogador.sala + 3)
        }
    end
    return {
        tipo = "moedas",
        n = math.random(8, 15) + 3 * jogador.sala
    }
end

function tesouro.entrar()
    jogador.especial = "tesouro"
    jogador.portas = nil
    jogador.inimigo = nil
    mensagens = {}
    fase = "fechado"
    bauCheio = false
    if not jogador.bau then
        jogador.bau = sortearBau()
    end
    registo.add("  [tesouro] " .. jogador.bau.tipo)
    savegame.gravar()
end

-- A gravacao passa a apontar para as portas seguintes
local function concluir()
    jogador.bau = nil
    jogador.especial = nil
    jogador.portas = salas.gerarPortas(jogador.sala + 1, "tesouro")
    savegame.gravar()
    fase = "aberto"
end

local function abrirBau()
    local bau = jogador.bau

    if bau.tipo == "armadilha" then
        -- nunca te mata (deixa sempre pelo menos 1 de vida)
        local dano = math.min(jogador.vida - 1, bau.dano)
        if dano > 0 then
            jogador.vida = jogador.vida - dano
            jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + dano
            table.insert(mensagens, {{1, 0.4, 0.3}, "Era uma armadilha! Perdes " .. dano .. " de vida."})
        else
            table.insert(mensagens, "Uma armadilha dispara, mas escapas por pouco.")
        end

    elseif bau.tipo == "item" then
        local item = bau.item
        local atributo = (item.tipo == "arma") and "ataque" or "defesa"
        table.insert(mensagens, loot.nomeColorido(item, "Encontras: ", " (+" .. item.bonus .. " " .. atributo .. ")"))

        local atual = jogador[item.tipo]
        local preco = loot.precoVenda(item)
        if jogador.eMelhor(item) then
            if atual then
                table.insert(mensagens, loot.nomeColorido(atual, "Equipado agora: ", " (+" .. atual.bonus .. ")"))
            end
            opcoes = {"Equipar", "Guardar na mochila", "Vender (" .. preco .. " moedas)"}
            acoes = {"equipar", "guardar", "vender"}
        else
            table.insert(mensagens, loot.nomeColorido(atual, "Nao e melhor que ", " (+" .. atual.bonus .. ")."))
            opcoes = {"Guardar na mochila", "Vender (" .. preco .. " moedas)"}
            acoes = {"guardar", "vender"}
        end
        table.insert(mensagens, (jogador.linhaDiferenca(item)))
        pendente = item
        indice = 1
        fase = "escolha"
        return -- a sala so fecha depois da escolha

    else
        jogador.ganharMoedas(bau.n)
        bauCheio = true
        table.insert(mensagens, {DOURADO, "O baú está cheio de moedas: +" .. bau.n .. "."})
    end

    concluir()
end

function tesouro.acao(a)
    if a == "inventario" then
        jogo.abrir("inventario")
        return
    end
    if a == "menu" then
        jogo.abrir("pocoes")
        return
    end

    if fase == "fechado" then
        if a == "confirmar" then
            abrirBau()
        end

    elseif fase == "escolha" then
        if a == "cima" then
            indice = indice - 1
            if indice < 1 then
                indice = #opcoes
            end
        elseif a == "baixo" then
            indice = indice + 1
            if indice > #opcoes then
                indice = 1
            end
        elseif a == "confirmar" then
            local escolha = acoes[indice]
            mensagens = {}
            if escolha == "equipar" then
                local antigo, coube = jogador.equiparDireto(pendente)
                table.insert(mensagens, "Equipas " .. pendente.nome .. ".")
                if antigo and coube then
                    table.insert(mensagens, antigo.nome .. " vai para a mochila.")
                elseif antigo then
                    table.insert(mensagens, jogador.venderPorCheia(antigo))
                end
            elseif escolha == "guardar" then
                table.insert(mensagens, jogador.guardarOuVender(pendente))
            else
                local ganho = loot.precoVenda(pendente)
                jogador.ganharMoedas(ganho)
                table.insert(mensagens, "Vendes " .. pendente.nome .. " por " .. ganho .. " moedas.")
            end
            pendente = nil
            concluir()
        end

    else -- "aberto"
        if a == "confirmar" then
            jogo.mudar("portas", jogador.portas)
        end
    end
end

function tesouro.desenhar()
    love.graphics.setColor(DOURADO)
    love.graphics.print("TESOURO", 20, 20)
    love.graphics.setColor(BRANCO)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 56)
    -- love.graphics.print({DOURADO, "Moedas: " .. jogador.moedas}, 420, 20)
    ui.moedas(420, 20, jogador.moedas)

    local caminho
    if fase == "fechado" then
        caminho = "imagens/itens/chest_closed.png"
    elseif fase == "escolha" or bauCheio then
        caminho = "imagens/itens/chest_open_full.png"
    else
        caminho = "imagens/itens/chest_open_empty.png"
    end
    local aberto = (fase ~= "fechado")
    if not ui.imagem(caminho, 482, 190, 6) then
        -- plano B: o bau de rectangulos de antes
        love.graphics.setColor(0.45, 0.3, 0.15)
        love.graphics.rectangle("fill", 470, 220, 120, 70)
        love.graphics.setColor(aberto and {0.2, 0.15, 0.1} or {0.55, 0.38, 0.2})
        love.graphics.rectangle("fill", 470, aberto and 195 or 200, 120, 25)
        love.graphics.setColor(DOURADO)
        love.graphics.rectangle("fill", 521, 238, 18, 18)
    end
    love.graphics.setColor(BRANCO)

    if fase == "fechado" then
        love.graphics.print("Um baú antigo, fechado. Pode ser uma armadilha...", 20, 110)
        love.graphics.print("A - abrir o baú", 20, 440)
    else
        for i, linha in ipairs(mensagens) do
            love.graphics.print(linha, 20, 110 + (i - 1) * 32)
        end
        if fase == "escolha" then
            local altura = love.graphics.getFont():getHeight()
            for i, texto in ipairs(opcoes) do
                local y = 260 + (i - 1) * 32
                if i == indice then
                    ui.cursorLinha(20, y, altura)
                end
                love.graphics.print(texto, 60, y)
            end
            sprites.ajuda({{"A", "escolher", "X", "poções", "SELECT", "mochila"}}, 20, 440)
        else
            sprites.ajuda({{"A", "seguir", "X", "poções", "SELECT", "mochila"}}, 20, 440)

        end
    end
end

return tesouro
