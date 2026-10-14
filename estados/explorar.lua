local jogo = require("jogo")
local jogador = require("jogador")
local inimigos = require("inimigos")
local loot = require("loot")
local pocoes = require("pocoes")
local dificuldade = require("dificuldade")
local cores = require("cores")
local savegame = require("savegame")
local mercador = require("mercador")

local explorar = {}
local inimigo

local chaves = {}
for chave, _ in pairs(inimigos) do
    table.insert(chaves, chave)
end

function explorar.entrar(guardado)
    if guardado == nil then
        jogador.sala = jogador.sala + 1
        if dificuldade.eLoja(jogador.sala) then
            inimigo = nil
        else
            inimigo = dificuldade.criarInimigo(jogador.sala)
        end
    elseif guardado == "loja" then
        inimigo = nil
    else
        inimigo = guardado
    end

    jogador.inimigo = inimigo
    if inimigo == nil then
        mercador.gerar(jogador.sala)
    end
    savegame.gravar()
end

function explorar.acao(a)
    if a == "confirmar" then
        if inimigo then
            jogo.mudar("combate", inimigo)
        else
            jogo.mudar("explorar") -- sem argumento: avanca para a proxima sala
        end
    elseif a == "extra" and not inimigo then
        jogo.abrir("loja")
    elseif a == "cancelar" then
        jogo.mudar("menu")
    elseif a == "inventario" then
        jogo.abrir("inventario")
    elseif a == "menu" then
        jogo.abrir("pocoes")
    end
end

function explorar.desenhar()
    love.graphics.print("Sala " .. jogador.sala, 20, 20)
    love.graphics.print({{1, 1, 1}, "Vida: ", cores.daVida(jogador.vida / jogador.vida_max),
                         jogador.vida .. "/" .. jogador.vida_max}, 20, 50)
    cores.barra(220, 54, 200, 16, jogador.vida / jogador.vida_max)
    love.graphics.print("Ataque: " .. jogador.ataqueTotal() .. "   Defesa: " .. jogador.defesaTotal(), 20, 80)
    love.graphics.print({{1, 0.85, 0.2}, "Moedas: " .. jogador.moedas}, 420, 20)
    local arma, armadura = jogador.arma, jogador.armadura
    love.graphics.print(arma and loot.nomeColorido(arma, "Arma: ") or "Arma: -", 20, 110)
    love.graphics.print(armadura and loot.nomeColorido(armadura, "Armadura: ") or "Armadura: -", 20, 140)
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
        love.graphics.print({{1, 0.85, 0.2}, "Um mercador oferece os seus produtos."}, 20, 200)
    elseif inimigo.boss then
        love.graphics.print(cores.nome(inimigo, "CHEFE: ", "!"), 20, 200)
    else
        love.graphics.print(cores.nome(inimigo, "Apareceu um ", "!"), 20, 200)
    end
    if inimigo then
        love.graphics.print("A lutar  X pocoes  SELECT mochila  B menu", 20, 440)
    else
        love.graphics.print("Y loja  A seguir  X pocoes  SELECT mochila", 20, 440)
    end
    love.graphics.print("A - lutar    SELECT - inventário    B - menu", 20, 440)
end

return explorar
