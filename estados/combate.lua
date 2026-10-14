local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")
local cores = require("cores")
local savegame = require("savegame")

local combate = {}

local opcoes = {"Atacar", "Pocao", "Fugir"}
local indice
local inimigo
local mensagens
local fase -- "escolha", "pausa", "pocao", "turno_inimigo", "loot", "vitoria" ou "derrota"
local proxima
local turno
local MAX_LINHAS = 8
local deslocamento
local pendente -- item que acabou de cair, a espera de decisao
local indiceLoot -- 1 = Equipar, 2 = Guardar, 3 = Deixar
local opcoesAtuais -- textos mostrados no menu do loot
local acoesAtuais -- "equipar", "guardar" ou "deixar", pela mesma ordem
local disponiveis -- poções que tens (quantidade > 0), pela ordem do menu
local indicePocao
local mostradaInimigo -- fraccao de vida que a barra mostra (0 a 1)
local mostradaJogador

local function dano(ataque)
    return math.max(1, ataque + math.random(-1, 1))
end

local function inimigoAtaca()
    local d = dano(inimigo.ataque - jogador.defesaTotal())
    jogador.vida = jogador.vida - d
    table.insert(mensagens, cores.nome(inimigo, "O " .. inimigo.nome .. " causa-te " .. d .. " de dano.", "!"))
    jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + d
    if jogador.vida <= 0 then
        jogador.vida = 0
        table.insert(mensagens, "Foste derrotado...")
        fase = "derrota"
        savegame.apagar()
    end
end

local function limiteScroll()
    return math.max(0, #mensagens - MAX_LINHAS)
end

local function novoTurno()
    turno = turno + 1
    table.insert(mensagens, "--- Turno " .. turno .. " ---")
end

local function guardarNaMochila(item)
    if jogador.guardar(item) then
        table.insert(mensagens, "Guardas " .. item.nome .. " na mochila.")
    else
        local ganho = loot.precoVenda(item)
        jogador.ganharMoedas(ganho)
        table.insert(mensagens, "Mochila cheia! Vendes " .. item.nome .. " por " .. ganho .. " moedas.")
    end
end

local function largarLoot()
    if inimigo.boss or math.random() < 0.7 then
        local item = loot.sortear(jogador.sala + (inimigo.boss and 10 or 0))
        local atributo = (item.tipo == "arma") and "ataque" or "defesa"
        table.insert(mensagens, {{1, 1, 1}, "Encontras: ", loot.cores[item.raridade], item.nome, {1, 1, 1},
                                 " (" .. item.raridade .. ", +" .. item.bonus .. " " .. atributo .. ")"})

        local preco = loot.precoVenda(item)
        local atual = jogador[item.tipo]
        if jogador.eMelhor(item) then
            -- (as linhas de mensagem ficam como estao)
            opcoesAtuais = {"Equipar", "Guardar na mochila", "Vender (" .. preco .. " moedas)"}
            acoesAtuais = {"equipar", "guardar", "vender"}
        else
            -- (a linha "Nao e melhor..." fica como esta)
            opcoesAtuais = {"Guardar na mochila", "Vender (" .. preco .. " moedas)"}
            acoesAtuais = {"guardar", "vender"}
        end

        pendente = item
        indiceLoot = 1
        fase = "loot"
    else
        table.insert(mensagens, "Nao largou nada.")
    end
end

local function largarMoedas()
    local n = math.random(3, 6) + 2 * jogador.sala
    if inimigo.boss then
        n = n * 3
    end
    jogador.ganharMoedas(n)
    table.insert(mensagens, {{1, 0.85, 0.2}, "Encontras " .. n .. " moedas."})
end

local function largarPocao()
    if inimigo.boss or math.random() < 0.4 then
        local p = pocoes.sortear()
        jogador.darPocao(p.id)
        table.insert(mensagens,
            cores.nome(p, "Encontras: ", " (+" .. p.cura .. " vida). Tens " .. jogador.quantas(p.id) .. "."))
    end
end

local function abrirPocoes()
    disponiveis = jogador.pocoesDisponiveis()
    if #disponiveis == 0 then
        table.insert(mensagens, "Nao tens pocoes.")
        return
    end
    indicePocao = 1
    fase = "pocao"
end

function combate.entrar(inimigo_novo)
    inimigo = inimigo_novo
    mostradaInimigo = inimigo.vida / inimigo.vida_max
    mostradaJogador = jogador.vida / jogador.vida_max
    indice = 1
    fase = "escolha"
    turno = 1
    deslocamento = 0
    mensagens = {cores.nome(inimigo, "Um " .. inimigo.nome .. " bloqueia o caminho!", "!"),
                 "--- Turno " .. turno .. " ---"}
end

function combate.acao(a)
    if a == "ombro_esq" then
        deslocamento = math.min(deslocamento + 1, limiteScroll())
        return
    elseif a == "ombro_dir" then
        deslocamento = math.max(deslocamento - 1, 0)
        return
    end

    deslocamento = 0

    if fase == "escolha" then
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
            if indice == 1 then
                -- atacar
                local d = dano(jogador.ataqueTotal())
                inimigo.vida = inimigo.vida - d
                table.insert(mensagens, "Atacas e causas " .. d .. " de dano.")
                jogador.stats.dano_causado = jogador.stats.dano_causado + d
                if inimigo.vida <= 0 then
                    inimigo.vida = 0
                    table.insert(mensagens, cores.nome(inimigo, "O ", " foi derrotado!"))
                    fase = "vitoria"
                    jogador.stats.inimigos = jogador.stats.inimigos + 1
                    if inimigo.boss then
                        jogador.stats.chefes = jogador.stats.chefes + 1
                        jogador.vida_max = jogador.vida_max + 5
                        jogador.vida = jogador.vida_max
                        table.insert(mensagens, "O chefe cai! Vida maxima +5 e recuperas toda a vida.")
                    end
                    largarMoedas()
                    largarPocao()
                    largarLoot()
                else
                    fase = "pausa"
                end
            elseif indice == 2 then
                -- pocao
                abrirPocoes()
            else
                if inimigo.boss then
                    table.insert(mensagens, "Nao consegues fugir do chefe!")
                elseif math.random() < 0.5 then
                    jogo.mudar("explorar")
                else
                    table.insert(mensagens, "Nao consegues fugir do combate.")
                    fase = "pausa"
                end
            end
        end
    elseif fase == "loot" then
        if a == "cima" then
            indiceLoot = indiceLoot - 1
            if indiceLoot < 1 then
                indiceLoot = #opcoesAtuais
            end
        elseif a == "baixo" then
            indiceLoot = indiceLoot + 1
            if indiceLoot > #opcoesAtuais then
                indiceLoot = 1
            end
        elseif a == "confirmar" then
            local escolha = acoesAtuais[indiceLoot]
            if escolha == "equipar" then
                local antigo, coube = jogador.equiparDireto(pendente)
                table.insert(mensagens, "Equipas " .. pendente.nome .. ".")
                if antigo and coube then
                    table.insert(mensagens, antigo.nome .. " vai para a mochila.")
                elseif antigo then
                    local ganho = loot.precoVenda(antigo)
                    jogador.ganharMoedas(ganho)
                    table.insert(mensagens, "Mochila cheia! Vendes " .. antigo.nome .. " por " .. ganho .. " moedas.")
                end
            elseif escolha == "guardar" then
                guardarNaMochila(pendente)
            elseif escolha == "vender" then
                local ganho = loot.precoVenda(pendente)
                jogador.ganharMoedas(ganho)
                table.insert(mensagens, "Vendes " .. pendente.nome .. " por " .. ganho .. " moedas.")
            end
            pendente = nil
            fase = "vitoria"
        end
    elseif fase == "pocao" then
        if a == "cima" then
            indicePocao = indicePocao - 1
            if indicePocao < 1 then
                indicePocao = #disponiveis
            end
        elseif a == "baixo" then
            indicePocao = indicePocao + 1
            if indicePocao > #disponiveis then
                indicePocao = 1
            end
        elseif a == "cancelar" then
            fase = "escolha"
        elseif a == "confirmar" then
            local p = disponiveis[indicePocao]
            if jogador.vida >= jogador.vida_max then
                table.insert(mensagens, "Ja tens a vida cheia.")
                fase = "escolha"
            else
                local curado = jogador.usarPocao(p.id)
                table.insert(mensagens, cores.nome(p, "Bebes ", " e recuperas " .. curado .. " de vida."))
                fase = "pausa"
            end
        end
    elseif a == "confirmar" then
        if fase == "pausa" then
            inimigoAtaca()
            if fase ~= "derrota" then
                fase = "turno_inimigo"
            end
        elseif fase == "turno_inimigo" then
            -- leu a resposta do inimigo; novo turno
            novoTurno()
            fase = "escolha"
        elseif fase == "vitoria" then
            jogo.mudar("explorar")
        else
            jogo.mudar("derrota")
        end
    end
end

function combate.desenhar()
    local fim = #mensagens - deslocamento
    local inicio = math.max(1, fim - MAX_LINHAS + 1)
    local frInimigo = inimigo.vida / inimigo.vida_max
    love.graphics.print({inimigo.cor or {1, 1, 1}, inimigo.nome, {1, 1, 1}, "   Vida: ", cores.daVida(frInimigo),
                         inimigo.vida .. "/" .. inimigo.vida_max}, 20, 20)

    local frJogador = jogador.vida / jogador.vida_max
    love.graphics.print({{1, 1, 1}, "Tu   Vida: ", cores.daVida(frJogador), jogador.vida .. "/" .. jogador.vida_max},
        20, 50)

    cores.barra(380, 24, 220, 16, mostradaInimigo)
    cores.barra(380, 54, 220, 16, mostradaJogador)

    for i = inicio, fim do
        love.graphics.print(mensagens[i], 20, 100 + (i - inicio) * 28)
    end

    if deslocamento > 0 then
        love.graphics.print("^ mais recente: R1", 380, 70)
    end
    if inicio > 1 then
        love.graphics.print("v mais antigo: L1", 20, 70)
    end

    if fase == "escolha" then
        for i, texto in ipairs(opcoes) do
            local prefixo = (i == indice) and "> " or "  "
            love.graphics.print(prefixo .. texto, 20, 340 + (i - 1) * 32)
        end
    elseif fase == "loot" then
        for i, texto in ipairs(opcoesAtuais) do
            local prefixo = (i == indiceLoot) and "> " or "  "
            love.graphics.print(prefixo .. texto, 20, 340 + (i - 1) * 32)
        end
    elseif fase == "pocao" then
        for i, p in ipairs(disponiveis) do
            local prefixo = (i == indicePocao) and "> " or "  "
            love.graphics.print(cores.nome(p, prefixo,
                " x" .. jogador.quantas(p.id) .. " (+" .. p.cura .. " vida -> " .. jogador.vidaApos(p) .. "/" ..
                    jogador.vida_max .. ")"), 20, 340 + (i - 1) * 32)
        end
        love.graphics.print("A - beber   B - voltar", 20, 440)
    else
        love.graphics.print("A - continuar", 20, 440)
    end
end

-- aproxima "atual" de "alvo" a cada frame
local function aproximar(atual, alvo, dt)
    atual = atual + (alvo - atual) * math.min(1, dt * 8)
    if math.abs(alvo - atual) < 0.002 then
        return alvo -- perto o suficiente: encaixa
    end
    return atual
end

function combate.atualizar(dt)
    mostradaInimigo = aproximar(mostradaInimigo, inimigo.vida / inimigo.vida_max, dt)
    mostradaJogador = aproximar(mostradaJogador, jogador.vida / jogador.vida_max, dt)
end

return combate
