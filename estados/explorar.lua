local jogo = require("jogo")
local jogador = require("jogador")
local inimigos = require("inimigos")
local loot = require("loot")
local pocoes = require("pocoes")
local dificuldade = require("dificuldade")

local explorar = {}
local inimigo

local chaves = {}
for chave, _ in pairs(inimigos) do
    table.insert(chaves, chave)
end

function explorar.entrar()
    jogador.sala = jogador.sala + 1
    inimigo = dificuldade.criarInimigo(jogador.sala)
end

function explorar.acao(a)
    if a == "confirmar" then
        jogo.mudar("combate", inimigo)
    elseif a == "cancelar" then
        jogo.mudar("menu")
    elseif a == "inventario" then
        jogo.abrir("inventario")
    end
end

function explorar.desenhar()
    love.graphics.print("Sala " .. jogador.sala, 20, 20)
    love.graphics.print("Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 50)
    love.graphics.print("Ataque: " .. jogador.ataqueTotal() ..
        "   Defesa: " .. jogador.defesaTotal(), 20, 80)
    love.graphics.setColor(1, 1, 1)
    local arma, armadura = jogador.arma, jogador.armadura
    love.graphics.print(arma and loot.nomeColorido(arma, "Arma: ") or "Arma: -", 20, 110)
    love.graphics.print(armadura and loot.nomeColorido(armadura, "Armadura: ") or "Armadura: -", 20, 140)
    local partes = {}
    for _, p in ipairs(pocoes.lista) do
        table.insert(partes, p.nome .. " x" .. jogador.quantas(p.id))
    end
    love.graphics.print("Pocoes: " .. table.concat(partes, ", "), 20, 170)
    if inimigo.boss then
        love.graphics.setColor(1, 0.4, 0.3)
        love.graphics.print("CHEFE " .. inimigo.nome .. "!", 20, 230)
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.print("Apareceu um " .. inimigo.nome .. "!", 20, 200)
    end
    love.graphics.print("A - lutar    SELECT - inventário    B - menu", 20, 440)
end

return explorar