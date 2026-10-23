local jogo = require("jogo")
local fontes = require("fontes")
local sprites = require("sprites")

local estado = {}

local CB = "CIMABAIXO"

-- Dados: {{teclas}, "o que faz"}. Para ajuda de um ecra novo, basta uma entrada
-- (a chave e o nome com que o estado foi registado).
local dados = {
    menu = {{{"DPAD"}, "Escolher"}, {{"A"}, "Confirmar"}},
    classes = {{{CB}, "Ver Classes"}, {{"A"}, "Escolher"}, {{"B"}, "Voltar"}},
    portas = {{{"ESQDIR"}, "Escolher a Porta"}, {{"A"}, "Abrir"}, {{"X"}, "Poções"}, {{"SELECT"}, "Mochila"},
              {{"B"}, "Menu"}},
    explorar = {{{"A"}, "Lutar (ou seguir, na loja)"}, {{"Y"}, "Abrir a Loja"}, {{"X"}, "Poções"},
                {{"SELECT"}, "Mochila"}, {{"B"}, "Menu"}},
    combate = {{{"A"}, "Atacar"}, {{"X"}, "Habilidade (recarga em turnos)"},
               {{"B"}, "Defender (e recuperas 2 de vida)"}, {{"Y"}, "Poção"},
               {{"R2"}, "Fugir (não dá contra chefes)"}, {{"L1", "R1"}, "Ler o Registo do Combate"},
               {{}, "Frase em baixo: o que o inimigo vai fazer"}},
    habilidade = {{{CB}, "escolher"}, {{"A"}, "aprender"}},
    loja = {{{CB}, "escolher"}, {{"A"}, "comprar (2x para confirmar)"}, {{"SELECT"}, "vender na mochila"},
            {{"B"}, "sair"}},
    inventario = {{{CB}, "escolher"}, {{"L1", "R1"}, "alternar equipamento/relíquias"}, {{"A"}, "equipar"},
                  {{"X"}, "vender (2x)"}, {{"Y"}, "poções"}, {{"B", "SELECT"}, "fechar"}},
    final = {{{CB}, "escolher"}, {{"A"}, "confirmar (2x para terminar)"}},
    pocoes = {{{CB}, "escolher"}, {{"A"}, "beber"}, {{"B"}, "fechar"}},
    tesouro = {{{"A"}, "abrir o baú / escolher"}, {{"X"}, "poções"}, {{"SELECT"}, "mochila"}},
    fogueira = {{{CB}, "escolher"}, {{"A"}, "confirmar"}, {{"X"}, "poções"}, {{"SELECT"}, "mochila"}},
    evento = {{{CB}, "escolher"}, {{"A"}, "confirmar"}, {{"X"}, "poções"}, {{"SELECT"}, "mochila"}},
    santuario = {{{CB}, "escolher"}, {{"A"}, "confirmar"}, {{"X"}, "poções"}, {{"SELECT"}, "mochila"}},
    reliquia = {{{CB}, "escolher"}, {{"A"}, "ficar com a relíquia"}},
    derrota = {{{"A"}, "voltar ao menu"}},
    historico = {{{CB}, "escolher"}, {{"B"}, "voltar"}}
}

local TITULOS = {
    menu = "MENU",
    classes = "CLASSES",
    portas = "PORTAS",
    explorar = "SALA",
    combate = "COMBATE",
    habilidade = "HABILIDADE",
    loja = "LOJA",
    inventario = "MOCHILA",
    pocoes = "POÇÕES",
    tesouro = "TESOURO",
    fogueira = "FOGUEIRA",
    evento = "EVENTO",
    reliquia = "RELÍQUIA",
    derrota = "DERROTA",
    historico = "HISTÓRICO",
    final = "VITÓRIA",
    santuario = "SANTUÁRIO"
}

local GERAL = {{{"START"}, "registo de salas (cima/baixo, L1/R1)"}, {{"L2"}, "esta ajuda"}, {{"A"}, "confirma"},
               {{"B"}, "cancela"}, {{"DPAD"}, "mover"}}

local COLUNA_TEXTO = 80 -- onde comeca o texto das linhas com teclas (cabem ate 2 icones)

local nome, fonte

local function nomeDe(est)
    for n, e in pairs(jogo.estados) do
        if e == est then
            return n
        end
    end
end

-- Uma linha: icones das teclas e, a seguir, o texto. Se uma tecla nao tiver
-- icone, sai o nome dela a cinzento.
local function desenharLinha(linha, y)
    local teclas, texto = linha[1], linha[2]
    local f = love.graphics.getFont()
    local x = 30
    for _, tecla in ipairs(teclas) do
        if sprites.botao(tecla, x, y + (f:getHeight() - 16) / 2, 1) then
            x = x + 20
        else
            love.graphics.print({{0.7, 0.7, 0.7}, tecla}, x, y)
            x = x + f:getWidth(tecla) + 4
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(texto, (#teclas > 0) and COLUNA_TEXTO or 30, y)
end

function estado.entrar()
    fonte = fontes.media
    -- o ecra de onde vens esta no topo da pilha
    nome = nomeDe(jogo.pilha[#jogo.pilha])
end

function estado.acao(a)
    if a == "cancelar" then
        jogo.fechar()
    end
end

function estado.desenhar()
    local normal = love.graphics.getFont()
    love.graphics.setFont(fonte)

    love.graphics.setColor(1, 1, 0.5)
    love.graphics.print("AJUDA - " .. (TITULOS[nome] or "GERAL"), 20, 16)

    love.graphics.setColor(1, 1, 1)
    local linhas = dados[nome] or {}
    for i, linha in ipairs(linhas) do
        desenharLinha(linha, 56 + (i - 1) * 26)
    end

    local y = 56 + #linhas * 26 + 22
    love.graphics.setColor(0.6, 1, 0.6)
    love.graphics.print("Em qualquer ecrã:", 20, y)
    love.graphics.setColor(1, 1, 1)
    for i, linha in ipairs(GERAL) do
        desenharLinha(linha, y + 28 + (i - 1) * 26)
    end

    love.graphics.setFont(normal)
    sprites.ajuda({{"B", "Sair"}}, 20, 446)
end

return estado
