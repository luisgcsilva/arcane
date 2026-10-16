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
    love.graphics.print("Sala " .. jogador.sala, 20, 20)
    love.graphics.print({{1, 1, 1}, "Vida: ", cores.daVida(jogador.vida / jogador.vida_max),
                         jogador.vida .. "/" .. jogador.vida_max}, 20, 80)
    cores.barra(180, 83, 200, 16, jogador.vida / jogador.vida_max)
    love.graphics.print("Nivel: " .. jogador.nivel .. "   Ataque: " .. jogador.ataqueTotal() .. "   Defesa: " ..
                            jogador.defesaTotal(), 130, 50)
    love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)
    local arma, armadura = jogador.arma, jogador.armadura
    love.graphics.print(arma and loot.nomeColorido(arma, "Arma: ", " (+" .. arma.bonus .. ")") or "Arma: -", 20, 110)
    love.graphics.print(armadura and loot.nomeColorido(armadura, "Armadura: ", " (+" .. armadura.bonus .. ")") or
                            "Armadura: -", 20, 140)

    local c = jogador.defClasse()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print({c.cor or {1, 1, 1}, c.nome or "Aventureiro", {1, 1, 1}}, 20, 50)

    local partes = {}
    for _, p in ipairs(pocoes.lista) do
        table.insert(partes, p.nome .. " x" .. jogador.quantas(p.id))
    end
    local texto = {}
    for i, p in ipairs(pocoes.lista) do
        if i > 1 then
            table.insert(texto, {1, 1, 1})
            table.insert(texto, "   ")
        end
        table.insert(texto, p.cor)
        table.insert(texto, p.nome .. " x" .. jogador.quantas(p.id))
    end

    if not inimigo then
        love.graphics.print({{1, 0.85, 0.2}, "Um mercador oferece os seus produtos."}, 20, 240)
    elseif inimigo.boss then
        love.graphics.print(cores.nome(inimigo, "CHEFE: ", "!"), 20, 240)
    elseif inimigo.elite then
        love.graphics.print(cores.nome(inimigo, "ELITE: ", "!"), 20, 240)
    else
        love.graphics.print(cores.nome(inimigo, "Apareceu um ", "!"), 20, 240)
    end
    if inimigo then
        love.graphics.print("A lutar  X pocoes  SELECT mochila  B menu", 20, 440)
    else
        love.graphics.print("A continuar   L2 ajuda", 20, 440)
    end
end

return explorar
