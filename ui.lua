local sprites = require("sprites")
local loot = require("loot")

local ui = {}

local FOLHA = "imagens/ui/interface.png"
local BASE = 512 -- largura da folha a 1x (se o ficheiro tiver 1536, o fator interno e 3)

ui.FUNDO = {0.09, 0.06, 0.09, 0.95} -- fundo escuro dos paineis

-- Pecas simples, em coordenadas a 1x: {x, y, largura, altura}
local MAO = {83, 100, 11, 8} -- aponta para a ESQUERDA (espelhamos quando e preciso)
local LINHA = {0, 72, 48, 2}
local SETAS = {
    esquerda = {5, 102, 5, 5},
    direita = {22, 102, 5, 5},
    baixo = {38, 102, 5, 5},
    cima = {54, 101, 5, 5}
}
local MAO_CIMA = {116, 98, 8, 11} -- mao a apontar para cima

-- os 10 espacos da folha: um a cada 16 px, em y = 80
local SLOTS = {
    vazio = 0,
    bolsa = 1,
    elmo = 2,
    malha = 3,
    espada = 4,
    peitoral = 5,
    escudo = 6,
    anel = 7,
    bota = 8,
    maca = 9
}

-- Pecas em 3 fatias: {x, y, largura, altura, ponta}
local PECAS = {
    botao = {1, 130, 46, 13, 3},
    botaoSel = {48, 129, 48, 14, 4}, -- inclui o brilho laranja a volta
    faixa = {0, 50, 48, 13, 9}
}
-- Paineis em 9 fatias: {x, y, largura, altura, ponta, borda}
-- "borda" = grossura da moldura visivel (a parte que fica por baixo do fundo escuro)
local PAINEIS = {
    rosa = {6, 6, 36, 36, 10, 6},
    laranja = {54, 6, 36, 36, 10, 4},
    ouro = {99, 3, 42, 42, 11, 7}
}

local quadros = {} -- chave -> quad(s), criados so quando sao precisos

local function zoom(img)
    return img:getWidth() / BASE
end

-- true se a folha existe (se nao, os ecras desenham so o texto)
function ui.disponivel()
    return sprites.carregar(FOLHA) ~= nil
end

-- Desenha um retangulo simples da folha em (x, y). espelhar = vira para o outro lado.
local function peca(chave, r, x, y, escala, espelhar)
    local img = sprites.carregar(FOLHA)
    if not img then
        return false
    end
    local z = zoom(img)
    if not quadros[chave] then
        quadros[chave] = love.graphics.newQuad(r[1] * z, r[2] * z, r[3] * z, r[4] * z, img:getDimensions())
    end
    local e = escala / z
    love.graphics.setColor(1, 1, 1)
    if espelhar then
        -- escala negativa vira a imagem; deslocamos para ela continuar a ocupar o mesmo sitio
        love.graphics.draw(img, quadros[chave], x + r[3] * escala, y, 0, -e, e)
    else
        love.graphics.draw(img, quadros[chave], x, y, 0, e, e)
    end
    return true
end

-- Desenha uma peca em 3 fatias: ponta esquerda, miolo esticado, ponta direita.
local function tres(nome, x, y, largura, escala)
    local img = sprites.carregar(FOLHA)
    if not img then
        return false
    end
    local z = zoom(img)
    local p = PECAS[nome]
    local px, py, pw, ph, ponta = p[1] * z, p[2] * z, p[3] * z, p[4] * z, p[5] * z

    if not quadros[nome] then
        quadros[nome] = {love.graphics.newQuad(px, py, ponta, ph, img:getDimensions()),
                         love.graphics.newQuad(px + ponta, py, z, ph, img:getDimensions()), -- 1 coluna do meio
        love.graphics.newQuad(px + pw - ponta, py, ponta, ph, img:getDimensions())}
    end
    local q = quadros[nome]

    local e = escala / z
    local larguraPonta = ponta * e
    local meio = largura - 2 * larguraPonta

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, q[1], x, y, 0, e, e)
    love.graphics.draw(img, q[2], x + larguraPonta, y, 0, meio / z, e)
    love.graphics.draw(img, q[3], x + largura - larguraPonta, y, 0, e, e)
    return true
end

-- estado: "normal" ou "sel"
function ui.botao(estado, x, y, largura, escala)
    if estado == "sel" then
        return tres("botaoSel", x - escala, y - escala, largura + 2 * escala, escala)
    end
    return tres("botao", x, y, largura, escala)
end

function ui.faixa(x, y, largura, escala)
    return tres("faixa", x, y, largura, escala)
end

-- Painel em 9 fatias: 4 cantos (nao esticam), 4 lados e o centro (esticam).
-- estilo: "ouro", "rosa" ou "laranja". fundo (opcional): cor que cobre o interior claro.
function ui.painel(estilo, x, y, w, h, escala, fundo)
    local img = sprites.carregar(FOLHA)
    local p = PAINEIS[estilo]
    if not img or not p then
        return false
    end
    local z = zoom(img)
    local px, py, pw, ph, capa = p[1] * z, p[2] * z, p[3] * z, p[4] * z, p[5] * z
    local meioW, meioH = pw - 2 * capa, ph - 2 * capa -- tamanho do miolo na folha

    local chave = "painel_" .. estilo
    if not quadros[chave] then
        local iw, ih = img:getDimensions()
        local function q(qx, qy, qw, qh)
            return love.graphics.newQuad(qx, qy, qw, qh, iw, ih)
        end
        quadros[chave] = {q(px, py, capa, capa), q(px + capa, py, meioW, capa), q(px + pw - capa, py, capa, capa),
                          q(px, py + capa, capa, meioH), q(px + capa, py + capa, meioW, meioH),
                          q(px + pw - capa, py + capa, capa, meioH), q(px, py + ph - capa, capa, capa),
                          q(px + capa, py + ph - capa, meioW, capa), q(px + pw - capa, py + ph - capa, capa, capa)}
    end
    local qs = quadros[chave]

    local e = escala / z
    local c = capa * e -- ponta no ecra
    local mw, mh = w - 2 * c, h - 2 * c -- o que sobra para esticar
    local sx, sy = mw / meioW, mh / meioH

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, qs[1], x, y, 0, e, e)
    love.graphics.draw(img, qs[2], x + c, y, 0, sx, e)
    love.graphics.draw(img, qs[3], x + w - c, y, 0, e, e)
    love.graphics.draw(img, qs[4], x, y + c, 0, e, sy)
    love.graphics.draw(img, qs[5], x + c, y + c, 0, sx, sy)
    love.graphics.draw(img, qs[6], x + w - c, y + c, 0, e, sy)
    love.graphics.draw(img, qs[7], x, y + h - c, 0, e, e)
    love.graphics.draw(img, qs[8], x + c, y + h - c, 0, sx, e)
    love.graphics.draw(img, qs[9], x + w - c, y + h - c, 0, e, e)

    if fundo then
        local b = p[6] * escala -- grossura da moldura no ecra
        love.graphics.setColor(fundo)
        love.graphics.rectangle("fill", x + b, y + b, w - 2 * b, h - 2 * b)
        love.graphics.setColor(1, 1, 1)
    end
    return true
end

-- Cursor de lista: mao a apontar para a direita, com um balanco suave
function ui.cursor(x, y, escala)
    local balanco = math.floor(math.sin(love.timer.getTime() * 6) * 3)
    return ui.mao(x + balanco, y, escala, false)
end

-- Mao a apontar (para a esquerda; espelhar = true aponta para a direita)
function ui.mao(x, y, escala, espelhar)
    return peca("mao", MAO, x, y, escala, espelhar)
end

-- Mao a apontar para cima
function ui.maoCima(x, y, escala)
    return peca("mao_cima", MAO_CIMA, x, y, escala)
end

-- Cursor para apontar para algo por cima: sobe e desce suavemente
function ui.cursorCima(x, y, escala)
    local balanco = math.floor(math.sin(love.timer.getTime() * 6) * 3)
    return ui.maoCima(x, y + balanco, escala)
end

-- Mao ao lado de uma linha de texto. y = topo da linha, altura = altura da linha.
-- Plano B: se a imagem faltar, desenha ">".
function ui.cursorLinha(x, y, altura)
    if not ui.cursor(x, y + (altura - 26) / 2, 2) then
        love.graphics.print(">", x, y)
    end
end

function ui.seta(direcao, x, y, escala)
    local r = SETAS[direcao]
    if not r then
        return false
    end
    return peca("seta_" .. direcao, r, x, y, escala)
end

function ui.moedas(x, y, n, escala, semDinheiro)
    escala = escala or 2
    local tipo = semDinheiro and "vermelha" or "normal"
    local cor = semDinheiro and {1, 0.45, 0.4} or {1, 0.85, 0.3}
    local lado = 16 * escala

    love.graphics.setColor(cor)
    if sprites.moeda(x, y, escala, tipo) then
        local f = love.graphics.getFont()
        love.graphics.print(n, x + lado + 6, y + (lado - f:getHeight()) / 2)
    else
        love.graphics.print(n .. " moedas", x, y)
    end
    love.graphics.setColor(1, 1, 1)
end
-- Um espaco de equipamento (16x16 na folha): "espada", "peitoral", "vazio", ...
function ui.slot(nome, x, y, escala)
    local i = SLOTS[nome]
    if not i then
        return false
    end
    return peca("slot_" .. nome, {i * 16, 80, 16, 16}, x, y, escala)
end

-- Linha separadora esticada na largura que quiseres
function ui.linha(x, y, largura, escala)
    local img = sprites.carregar(FOLHA)
    if not img then
        return false
    end
    local z = zoom(img)
    if not quadros.linha then
        quadros.linha = love.graphics.newQuad(LINHA[1] * z, LINHA[2] * z, LINHA[3] * z, LINHA[4] * z,
            img:getDimensions())
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, quadros.linha, x, y, 0, largura / (LINHA[3] * z), escala / z)
    return true
end

-- Ranhura de equipamento: icone do slot, moldura na cor da raridade e texto ao lado.
-- texto pode ser uma string ou um texto colorido; parte linha dentro de `largura`.
function ui.ranhura(tipo, item, texto, x, y, largura)
    local comIcone = item and loot.caminhoIcone(item)
    if comIcone then
        love.graphics.setColor(ui.FUNDO)
        love.graphics.rectangle("fill", x, y, 32, 32) -- fundo escuro por baixo do icone
        ui.icone(item, x, y, 2)
    else
        ui.slot((tipo == "arma") and "espada" or "peitoral", x, y, 2)
    end
    if item then
        love.graphics.setColor(loot.cores[item.raridade])
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 1, y - 1, 34, 34)
        love.graphics.setLineWidth(1)
    end
    local fonte = love.graphics.getFont()
    local _, linhas = fonte:getWrap(texto, largura)
    love.graphics.setColor(1, 1, 1)
    -- centrado na vertical em relacao ao slot (32 px), mesmo que o texto ocupe 2 linhas
    love.graphics.printf(texto, x + 44, y + 16 - #linhas * fonte:getHeight() / 2, largura)
end

local imagensCache = {} -- nil = ainda nao tentei; false = nao existe

function ui.imagem(caminho, x, y, escala, cor)
    if not caminho then
        return false
    end
    if imagensCache[caminho] == nil then
        imagensCache[caminho] = love.filesystem.getInfo(caminho) and love.graphics.newImage(caminho) or false
    end
    if not imagensCache[caminho] then
        return false
    end
    love.graphics.setColor(cor or {1, 1, 1})
    love.graphics.draw(imagensCache[caminho], x, y, 0, escala, escala)
    love.graphics.setColor(1, 1, 1)
    return true
end

function ui.icone(item, x, y, escala)
    return ui.imagem(loot.caminhoIcone(item), x, y, escala)
end

-- Painel de detalhe: icone grande com moldura, titulo e descricao, centrados.
-- Devolve o y onde a descricao comeca.
function ui.detalhe(x, y, w, h, caminho, cor, titulo, texto)
    ui.painel("ouro", x, y, w, h, 2, ui.FUNDO)
    local cx = x + w / 2
    if cor then
        love.graphics.setColor(cor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", cx - 34, y + 16, 68, 68)
        love.graphics.setLineWidth(1)
    end
    ui.imagem(caminho, cx - 32, y + 18, 4)
    love.graphics.setColor(1, 1, 1)
    local f = love.graphics.getFont()
    local yTexto = y + 96 + f:getHeight() + 12
    love.graphics.printf(titulo, x + 10, y + 96, w - 20, "center")
    love.graphics.printf(texto, x + 10, yTexto, w - 20, "center")
    return yTexto
end

-- "rotulo [moeda] n" centrado em cx, a altura y
function ui.linhaMoedas(cx, rotulo, corRotulo, n, escala, y, semDinheiro)
    local f = love.graphics.getFont()
    local lado = 16 * escala
    local largura = f:getWidth(rotulo) + lado + 6 + f:getWidth(tostring(n))
    local x0 = cx - largura / 2
    local alto = math.max(lado, f:getHeight())
    love.graphics.setColor(corRotulo)
    love.graphics.print(rotulo, x0, y + (alto - f:getHeight()) / 2)
    ui.moedas(x0 + f:getWidth(rotulo), y + (alto - lado) / 2, n, escala, semDinheiro)
end

return ui
