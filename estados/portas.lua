local jogo = require("jogo")
local jogador = require("jogador")
local salas = require("salas")
local savegame = require("savegame")
local cores = require("cores")
local registo = require("registo")
local biomas = require("biomas")
local ui = require("ui")
local fontes = require("fontes")
local sprites = require("sprites")

local portas = {}

local lista -- ids das portas, por ordem
local indice
local PORTA = 4 -- escala: a porta tem 32 px, no ecra fica com 128
local FECHADA = "imagens/ui/porta_fechada.png"
local ABERTA = "imagens/ui/porta_aberta.png"

local DOURADO = {1, 0.85, 0.2}
local CINZA = {0.6, 0.6, 0.6}
local MADEIRA = {0.25, 0.2, 0.15}
local MADEIRA_CLARA = {0.45, 0.32, 0.18}

-- arg: uma lista (gravacao retomada) ou o tipo da sala de onde vens
function portas.entrar(arg)
    if type(arg) == "table" then
        lista = arg
    else
        lista = salas.gerarPortas(jogador.sala + 1, arg)
    end
    jogador.portas = lista
    registo.add(string.format("Sala %d: portas [%s]%s", jogador.sala + 1, table.concat(lista, ", "),
        type(arg) == "table" and " (retomadas)" or ""))
    jogador.inimigo = nil
    jogador.especial = nil
    jogador.eventoId = nil
    jogador.bau = nil
    jogador.posVitoria = nil
    jogador.lootPendente = nil
    jogador.ofertaBencoes = nil
    indice = 1
    savegame.gravar()
end

function portas.acao(a)
    local n = #lista
    if a == "esquerda" or a == "cima" then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
    elseif a == "direita" or a == "baixo" then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
    elseif a == "confirmar" then
        local tipo = lista[indice]
        registo.add("  Porta " .. indice .. " -> " .. tipo)
        jogador.portas = nil
        jogador.sala = jogador.sala + 1
        -- a bencao ativa gasta uma sala; quando acaba, desaparece
        if jogador.bencao then
            jogador.bencao.restantes = jogador.bencao.restantes - 1
            if jogador.bencao.restantes <= 0 then
                jogador.bencao = nil
            end
        end
        -- fogueira e tesouro tem estado proprio; o resto passa pelo explorar
        local destinos = {
            fogueira = "fogueira",
            tesouro = "tesouro",
            evento = "evento",
            santuario = "santuario"
        }
        jogo.mudar(destinos[tipo] or "explorar", tipo)
    elseif a == "menu" then
        jogo.abrir("pocoes")
    elseif a == "inventario" then
        jogo.abrir("inventario")
    elseif a == "cancelar" then
        jogo.mudar("menu")
    end
end

function portas.desenhar()
    local normal = love.graphics.getFont()
    local temUI = ui.disponivel()
    local fr = jogador.vida / jogador.vida_max
    love.graphics.setColor(1, 1, 1)

    -- titulo numa faixa e moedas
    local titulo = (jogador.sala == 0) and "A entrada da masmorra" or ("Entrada da Proxima Sala " .. jogador.sala + 1)
    ui.faixa(20, 10, 360, 3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(titulo, 20, 10 + (36 - normal:getHeight()) / 2, 360, "center")
    --love.graphics.print({DOURADO, "Moedas: " .. jogador.moedas}, 420, 20)
    ui.moedas(420, 20, jogador.moedas)

    -- painel com vida e bioma
    ui.painel("ouro", 10, 58, 620, 100, 2, ui.FUNDO)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print({{1, 1, 1}, "Vida: ", cores.daVida(fr), jogador.vida .. "/" .. jogador.vida_max}, 28, 74)
    if not sprites.barra(220, 72, fr, 2) then
        cores.barra(220, 78, 140, 14, fr)
    end
    local prox = biomas.daSala(jogador.sala + 1)
    local atual = biomas.daSala(jogador.sala)
    local texto = {{1, 1, 1}, "Bioma: ", prox.cor, prox.nome}
    if jogador.sala > 0 and prox.id ~= atual.id then
        table.insert(texto, DOURADO)
        table.insert(texto, "  (novo bioma!)")
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(texto, 28, 104)

    love.graphics.print(#lista == 1 and "Ha uma porta a frente." or "Que porta abres?", 20, 168)

    -- as portas: fechada normalmente, aberta a selecionada
    local n = #lista
    local L, A, ESPACO, Y = 32 * PORTA, 32 * PORTA, 30, 204
    local x0 = (640 - (n * L + (n - 1) * ESPACO)) / 2

    for i = 1, n do
        local x = x0 + (i - 1) * (L + ESPACO)
        local escolhida = (i == indice)

        -- o sprite desenha-se centrado, por isso damos o centro da porta
        if not sprites.desenhar(escolhida and ABERTA or FECHADA, x + L / 2, Y + A / 2, PORTA) then
            -- plano B (sem imagem): os retangulos antigos
            love.graphics.setColor(escolhida and MADEIRA_CLARA or MADEIRA)
            love.graphics.rectangle("fill", x, Y, L, A)
            love.graphics.setColor(escolhida and DOURADO or CINZA)
            love.graphics.setLineWidth(escolhida and 4 or 2)
            love.graphics.rectangle("line", x, Y, L, A)
            love.graphics.setLineWidth(1)
        end

        if not escolhida then
            love.graphics.setFont(fontes.enorme)
            love.graphics.printf("?", x, Y + A / 2 - fontes.enorme:getHeight() / 2, L, "center")
            love.graphics.setFont(normal)
            love.graphics.setColor(0.25, 0.12, 0.12) -- o painel e claro: "?" escuro
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.setColor(escolhida and DOURADO or CINZA)
        love.graphics.printf("Porta " .. i, x, Y + A + 8, L, "center")
        if escolhida then
            ui.cursorCima(x + L / 2 - 12, Y + A + 40, 3)
        end
    end
    love.graphics.setColor(1, 1, 1)
    sprites.ajuda({{"ESQDIR", "escolher"}, {"A", "abrir"}, {"L2", "ajuda"}}, 20, 446)
end

return portas
