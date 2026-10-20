local sprites = {}

local cache = {} -- caminho -> imagem, ou false se nao existe

-- Carrega uma imagem uma unica vez. Devolve nil se o ficheiro nao existir.
function sprites.carregar(caminho)
    if cache[caminho] == nil then
        if love.filesystem.getInfo(caminho) then
            cache[caminho] = love.graphics.newImage(caminho)
        else
            cache[caminho] = false
        end
    end
    return cache[caminho] or nil
end

-- "Rato Gigante" -> "imagens/inimigos/rato_gigante.png"
function sprites.caminhoInimigo(inimigo)
    local nome = inimigo.sprite or (inimigo.nome:lower():gsub("%s+", "_"))
    return "imagens/inimigos/" .. nome .. ".png"
end

-- "guerreiro" -> "imagens/classes/guerreiro.png"
function sprites.caminhoClasse(id)
    return "imagens/classes/" .. (id or "guerreiro") .. ".png"
end

local quadros = {}

-- Desenha centrado em (x, y). Devolve true se desenhou, false se nao ha imagem.
-- espelhar = true vira a imagem para a esquerda
function sprites.desenhar(caminho, x, y, escala, fps, espelhar)
    local img = sprites.carregar(caminho)
    if not img then
        return false
    end

    local lado = img:getHeight()
    local n = math.floor(img:getWidth() / lado)

    if not quadros[caminho] then
        quadros[caminho] = {}
        for i = 0, n - 1 do
            quadros[caminho][i + 1] = love.graphics.newQuad(i * lado, 0, lado, lado, img:getDimensions())
        end
    end

    local frame = math.floor(love.timer.getTime() * (fps or 6)) % n + 1
    local escalaX = espelhar and -escala or escala -- escala negativa = espelho
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, quadros[caminho][frame], x, y, 0, escalaX, escala, lado / 2, lado / 2)
    return true
end

-- Barras de vida (folha Pixel UI pack 3/04.png, copiada para imagens/ui/barras.png)
-- Barras de vida (folha Pixel UI pack 3/04.png, copiada para imagens/ui/barras.png)
local BARRAS = "imagens/ui/barras.png"
local MOLDURA = {
    x = 0,
    w = 48,
    h = 11
} -- o y depende do estilo
local MOLDURAS = {
    prata = 3,
    azul = 19,
    bronze = 35
} -- y de cada moldura na folha
local ENCHER = {
    x = 51,
    w = 42,
    h = 5
} -- preenchimento cheio: so muda a linha (y) conforme a cor
local LINHA = {
    vermelho = 6,
    amarelo = 22,
    verde = 54
}
local MARGEM = 3 -- pixeis entre a borda da moldura e o preenchimento: (48-42)/2 e (11-5)/2

local quadrosMoldura = {} -- estilo -> quad, criado so quando e preciso
local quadroEncher

-- Desenha uma barra de vida em (x, y). fracao de 0 a 1.
-- estilo (opcional): "prata" (por defeito), "azul" ou "bronze".
-- Devolve false se nao ha imagem.
function sprites.barra(x, y, fracao, escala, estilo)
    local img = sprites.carregar(BARRAS)
    if not img then
        return false
    end
    fracao = math.max(0, math.min(1, fracao))

    if not MOLDURAS[estilo] then
        estilo = "prata" -- sem estilo (ou estilo desconhecido): moldura normal
    end
    if not quadrosMoldura[estilo] then
        quadrosMoldura[estilo] = love.graphics.newQuad(MOLDURA.x, MOLDURAS[estilo], MOLDURA.w, MOLDURA.h,
            img:getDimensions())
    end
    if not quadroEncher then
        quadroEncher = love.graphics.newQuad(0, 0, 1, 1, img:getDimensions()) -- ajustado a cada desenho
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, quadrosMoldura[estilo], x, y, 0, escala, escala)

    local largura = math.floor(ENCHER.w * fracao + 0.5)
    if largura > 0 then
        local linha = (fracao > 0.5 and LINHA.verde) or (fracao > 0.25 and LINHA.amarelo) or LINHA.vermelho
        quadroEncher:setViewport(ENCHER.x, linha, largura, ENCHER.h) -- corta a largura da vida
        love.graphics.draw(img, quadroEncher, x + MARGEM * escala, y + MARGEM * escala, 0, escala, escala)
    end
    return true
end

-- Botoes e controlos (folha de 578x408: grelha de icones 16x16 com passo de 17 px)
local CONTROLOS = "imagens/ui/controlos.png"
local PASSO = 17 -- 16 de icone + 1 de separacao
local LADO = 16

-- tecla -> {coluna, linha}, a contar de 0
local TECLAS = {
    A = {13, 1},
    B = {14, 1},
    X = {15, 1},
    Y = {16, 1},
    L1 = {7, 19},
    R1 = {8, 19},
    L2 = {7, 17},
    R2 = {8, 17},
    SELECT = {18, 23},
    START = {19, 23},
    ESQDIR = {5, 1},
    CIMABAIXO = {6, 1},
    DPAD = {7, 1}
}

local quadrosTecla = {} -- tecla -> quad, criado so quando e preciso

-- Desenha o icone da tecla em (x, y). Devolve false se nao ha imagem ou tecla.
function sprites.botao(tecla, x, y, escala)
    local img = sprites.carregar(CONTROLOS)
    local celula = TECLAS[tecla]
    if not img or not celula then
        return false
    end
    if not quadrosTecla[tecla] then
        quadrosTecla[tecla] = love.graphics.newQuad(celula[1] * PASSO, celula[2] * PASSO, LADO, LADO,
            img:getDimensions())
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, quadrosTecla[tecla], x, y, 0, escala, escala)
    return true
end

-- Linha de ajuda: itens = {{"A", "comprar"}, {"SELECT", "inventario"}, {"B", "sair"}}
-- Se uma tecla nao tiver icone, sai como texto cinzento.
function sprites.ajuda(itens, x, y, escala)
    escala = escala or 2
    local fonte = love.graphics.getFont()
    local ty = y + (LADO * escala - fonte:getHeight()) / 2 -- texto alinhado ao centro do icone
    for _, item in ipairs(itens) do
        local tecla, texto = item[1], item[2]
        if sprites.botao(tecla, x, y, escala) then
            x = x + LADO * escala + 6
        else
            love.graphics.print({{0.7, 0.7, 0.7}, tecla}, x, ty)
            x = x + fonte:getWidth(tecla) + 6
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(texto, x, ty)
        x = x + fonte:getWidth(texto) + 22
    end
    return x
end

local MOEDAS = {
    normal = "imagens/itens/moeda.png",
    vermelha = "imagens/itens/moedaVerm.png"
}
local moedaImgs = {} -- nil = ainda nao tentei; false = nao existe

function sprites.moeda(x, y, escala, tipo)
    tipo = tipo or "normal"
    if moedaImgs[tipo] == nil then
        local caminho = MOEDAS[tipo]
        moedaImgs[tipo] = love.filesystem.getInfo(caminho) and love.graphics.newImage(caminho) or false
    end
    if not moedaImgs[tipo] then
        return false
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(moedaImgs[tipo], x, y, 0, escala, escala)
    return true
end

return sprites
