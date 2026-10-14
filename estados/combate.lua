local jogo = require("jogo")
local jogador = require("jogador")
local loot = require("loot")
local pocoes = require("pocoes")

local combate = {}

local opcoes = { "Atacar", "Pocao", "Fugir" }
local indice
local inimigo
local mensagens
local fase -- "escolha", "pausa", "pocao", "turno_inimigo", "loot", "vitoria" ou "derrota"
local proxima
local turno
local MAX_LINHAS = 8
local deslocamento
local pendente     -- item que acabou de cair, a espera de decisao
local indiceLoot   -- 1 = Equipar, 2 = Guardar, 3 = Deixar
local opcoesAtuais -- textos mostrados no menu do loot
local acoesAtuais  -- "equipar", "guardar" ou "deixar", pela mesma ordem
local disponiveis  -- poções que tens (quantidade > 0), pela ordem do menu
local indicePocao

local function dano(ataque)
    return math.max(1, ataque + math.random(-1, 1))
end

local function inimigoAtaca()
    local d = dano(inimigo.ataque - jogador.defesaTotal())
    jogador.vida = jogador.vida - d
    table.insert(mensagens, "O " .. inimigo.nome .. " causa-te " .. d .. " de dano.")
    if jogador.vida <= 0 then
        jogador.vida = 0
        table.insert(mensagens, "Foste derrotado...")
        fase = "derrota"
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
        table.insert(mensagens,
            { { 1, 1, 1 }, "Guardas ", loot.cores[item.raridade], item.nome, { 1, 1, 1 }, " na mochila." })
    else
        table.insert(mensagens,
            { { 1, 1, 1 }, "Mochila cheia! Deixas ", loot.cores[item.raridade], item.nome, { 1, 1, 1 }, " para tras." })
    end
end

local function largarLoot()
    if inimigo.boss or math.random() < 0.7 then
        local item = loot.sortear(jogador.sala + (inimigo.boss and 10 or 0))
        local atributo = (item.tipo == "arma") and "ataque" or "defesa"
        table.insert(mensagens, {
            { 1, 1, 1 }, "Encontras: ",
            loot.cores[item.raridade], item.nome,
            { 1, 1, 1 }, " (" .. item.raridade .. ", +" .. item.bonus .. " " .. atributo .. ")",
        })

        local atual = jogador[item.tipo]
        if jogador.eMelhor(item) then
            if atual then
                table.insert(mensagens, loot.nomeColorido(atual, "Equipado agora: ", " (+" .. atual.bonus .. ")"))
            else
                table.insert(mensagens, "Ainda nao tens nada equipado nesse espaco.")
            end
            opcoesAtuais = { "Equipar", "Guardar na mochila", "Deixar no chao" }
            acoesAtuais  = { "equipar", "guardar", "deixar" }
        else
            table.insert(mensagens, loot.nomeColorido(atual, "Nao e melhor que ", " (+" .. atual.bonus .. ")."))
            opcoesAtuais = { "Guardar na mochila", "Deixar no chao" }
            acoesAtuais  = { "guardar", "deixar" }
        end

        pendente = item
        indiceLoot = 1
        fase = "loot"
    else
        table.insert(mensagens, "Nao largou nada.")
    end
end

local function largarPocao()
    if inimigo.boss or math.random() < 0.4 then
        local p = pocoes.sortear()
        jogador.darPocao(p.id)
        table.insert(mensagens, "Encontras: " .. p.nome .. " (+" .. p.cura ..
            " vida). Tens " .. jogador.quantas(p.id) .. ".")
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
    indice = 1
    fase = "escolha"
    turno = 1
    deslocamento = 0
    mensagens = { "Um " .. inimigo.nome .. " bloqueia o caminho!", "--- Turno " .. turno .. " ---" }
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
            if indice < 1 then indice = #opcoes end
        elseif a == "baixo" then
            indice = indice + 1
            if indice > #opcoes then indice = 1 end
        elseif a == "confirmar" then
            if indice == 1 then
                -- atacar
                local d = dano(jogador.ataqueTotal())
                inimigo.vida = inimigo.vida - d
                table.insert(mensagens, "Atacas e causas " .. d .. " de dano.")
                if inimigo.vida <= 0 then
                    inimigo.vida = 0
                    table.insert(mensagens, "O " .. inimigo.nome .. " foi derrotado!")
                    fase = "vitoria"
                    if inimigo.boss then
                        jogador.vida_max = jogador.vida_max + 5
                        jogador.vida = jogador.vida_max
                        table.insert(mensagens, "O chefe cai! Vida maxima +5 e recuperas toda a vida.")
                    end
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
            if indiceLoot < 1 then indiceLoot = #opcoesAtuais end
        elseif a == "baixo" then
            indiceLoot = indiceLoot + 1
            if indiceLoot > #opcoesAtuais then indiceLoot = 1 end
        elseif a == "confirmar" then
            local escolha = acoesAtuais[indiceLoot]
            if escolha == "equipar" then
                local antigo, coube = jogador.equiparDireto(pendente)
                table.insert(mensagens,
                    { { 1, 1, 1 }, "Equipas ", loot.cores[pendente.raridade], pendente.nome, { 1, 1, 1 }, "." })
                if antigo and coube then
                    table.insert(mensagens, { { 1, 1, 1 }, antigo.nome .. " vai para a mochila." })
                elseif antigo then
                    table.insert(mensagens, { { 1, 1, 1 }, "Mochila cheia! Largas " .. antigo.nome .. "." })
                end
            elseif escolha == "guardar" then
                guardarNaMochila(pendente)
            else
                table.insert(mensagens,
                    { { 1, 1, 1 }, "Deixas ", loot.cores[pendente.raridade], pendente.nome, { 1, 1, 1 }, " no chao." })
            end
            pendente = nil
            fase = "vitoria"
        end
    elseif fase == "pocao" then
        if a == "cima" then
            indicePocao = indicePocao - 1
            if indicePocao < 1 then indicePocao = #disponiveis end
        elseif a == "baixo" then
            indicePocao = indicePocao + 1
            if indicePocao > #disponiveis then indicePocao = 1 end
        elseif a == "cancelar" then
            fase = "escolha"
        elseif a == "confirmar" then
            local p = disponiveis[indicePocao]
            if jogador.vida >= jogador.vida_max then
                table.insert(mensagens, "Ja tens a vida cheia.")
                fase = "escolha"
            else
                local curado = jogador.usarPocao(p.id)
                table.insert(mensagens, "Bebes " .. p.nome .. " e recuperas " .. curado .. " de vida.")
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
            jogo.mudar("menu")
        end
    end
end

function combate.desenhar()
    local fim = #mensagens - deslocamento
    local inicio = math.max(1, fim - MAX_LINHAS + 1)


    love.graphics.setColor(1, 1, 1)

    love.graphics.print(inimigo.nome .. "   Vida: " .. inimigo.vida .. "/" .. inimigo.vida_max, 20, 20)
    love.graphics.print("Tu   Vida: " .. jogador.vida .. "/" .. jogador.vida_max, 20, 50)

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
            love.graphics.print(prefixo .. p.nome .. " x" .. jogador.quantas(p.id) ..
                " (+" .. p.cura .. " vida -> " .. jogador.vidaApos(p) .. "/" .. jogador.vida_max .. ")",
                20, 340 + (i - 1) * 32)
        end
        love.graphics.print("A - beber   B - voltar", 20, 440)
    else
        love.graphics.print("A - continuar", 20, 440)
    end
end

return combate
