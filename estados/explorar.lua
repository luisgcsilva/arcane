local jogo = require("jogo")
local jogador = require("jogador")
local inimigos = require("inimigos")
local loot = require("loot")
local pocoes = require("pocoes")
local dificuldade = require("dificuldade")
local cores = require("cores")
local savegame = require("savegame")
local mercador = require("mercador")
local registo = require("registo")
local reliquias = require("reliquias")
local bencoes = require("bencoes")
local ui = require("ui")
local sprites = require("sprites")

local explorar = {}
local inimigo

local chaves = {}
for chave, _ in pairs(inimigos) do
    table.insert(chaves, chave)
end

function explorar.entrar(tipo, guardado)
    jogador.portas = nil
    jogador.especial = nil
    if tipo == "loja" then
        inimigo = nil
        if guardado ~= "retomar" then
            mercador.gerar(jogador.sala)
        end
    elseif guardado then
        inimigo = guardado
    else
        inimigo = dificuldade.criarInimigo(jogador.sala, tipo == "boss", tipo == "elite")
    end
    jogador.inimigo = inimigo
    if inimigo then
        registo.add(string.format("  [%s] %s: vida %d, ataque %d", tostring(tipo), inimigo.nome, inimigo.vida,
            inimigo.ataque))
    else
        local nomes = {}
        for _, e in ipairs(mercador.stock) do
            table.insert(nomes, mercador.nomeDe(e))
        end
        registo.add("  [loja] " .. table.concat(nomes, ", "))
    end
    savegame.gravar()
end

function explorar.acao(a)
    if a == "confirmar" then
        if inimigo then
            jogo.mudar("combate", inimigo)
        else
            jogo.mudar("portas", "loja") -- sem argumento: avanca para a proxima sala
        end
    elseif a == "cancelar" then
        jogo.mudar("menu")
    elseif a == "extra" and not inimigo then
        jogo.abrir("loja")
    elseif a == "inventario" then
        jogo.abrir("inventario")
    elseif a == "menu" then
        jogo.abrir("pocoes")
    end
end

function explorar.desenhar()
    local fonte = love.graphics.getFont()
    local c = jogador.defClasse()
    local fr = jogador.vida / jogador.vida_max
    local CINZA = {0.5, 0.5, 0.5}

    -- titulo numa faixa e moedas
    ui.faixa(20, 10, 200, 3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Sala " .. jogador.sala, 20, 10 + (39 - fonte:getHeight()) / 2, 200, "center")
    -- love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)
    ui.moedas(420, 20, jogador.moedas)
    
    ---------- painel do jogador (esquerda) ----------
    ui.painel("ouro", 10, 64, 400, 312, 2, ui.FUNDO)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print({c.cor or {1, 1, 1}, c.nome or "Aventureiro", {1, 1, 1}, "   Nivel " .. jogador.nivel}, 28, 78)
    love.graphics.print("Ataque: " .. jogador.ataqueTotal() .. "   Defesa: " .. jogador.defesaTotal(), 28, 108)

    if not sprites.barra(28, 142, fr, 3) then
        cores.barra(28, 148, 144, 16, fr) -- plano B
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print({{1, 1, 1}, "Vida: ", cores.daVida(fr), jogador.vida .. "/" .. jogador.vida_max}, 182,
        142 + (33 - fonte:getHeight()) / 2)

    local arma, armadura = jogador.arma, jogador.armadura
    ui.ranhura("arma", arma, arma and loot.nomeColorido(arma, "Arma: ", " (" .. jogador.textoBonus(arma) .. ")") or
        {CINZA, "Arma: -"}, 28, 192, 320)
    ui.ranhura("armadura", armadura,
        armadura and loot.nomeColorido(armadura, "Armadura: ", " (" .. jogador.textoBonus(armadura) .. ")") or
            {CINZA, "Armadura: -"}, 28, 248, 320)

    if jogador.bencao then
        local b = bencoes.porId(jogador.bencao.id)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf({{1, 1, 1}, "Bencao: ", b.cor, b.nome, {1, 1, 1},
                              " (" .. jogador.bencao.restantes .. " salas)"}, 28, 306, 368)
    end

    ---------- painel do que encontraste (direita) ----------
    ui.painel("ouro", 420, 64, 210, 312, 2, ui.FUNDO)
    local cx = 525
    love.graphics.setColor(1, 1, 1)
    if not inimigo then
        -- mercador: o icone da bolsa
        love.graphics.setColor(0, 0, 0, 0.35)
        love.graphics.ellipse("fill", cx, 208, 40, 8)
        ui.slot("bolsa", cx - 32, 144, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf({{1, 0.85, 0.2}, "Um mercador oferece os seus produtos."}, 434, 228, 182, "center")
    else
        local escala = inimigo.boss and 8 or 6
        love.graphics.setColor(0, 0, 0, 0.35)
        love.graphics.ellipse("fill", cx, 208, 8 * escala, 1.5 * escala)
        sprites.desenhar(sprites.caminhoInimigo(inimigo), cx, 208 - 8 * escala, escala, 6, inimigo.espelhar)

        local texto
        if inimigo.boss then
            texto = cores.nome(inimigo, "CHEFE: ", "!")
        elseif inimigo.elite then
            texto = cores.nome(inimigo, "ELITE: ", "!")
        else
            texto = cores.nome(inimigo, "Apareceu um ", "!")
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(texto, 434, 228, 182, "center")
    end

    love.graphics.setColor(1, 1, 1)
    if inimigo then
        sprites.ajuda({{"A", "lutar"}, {"X", "pocoes"}, {"SELECT", "mochila"}, {"B", "menu"}}, 20, 446)
    else
        sprites.ajuda({{"A", "continuar"}, {"Y", "loja"}, {"L2", "ajuda"}}, 20, 446)
    end
end

return explorar
