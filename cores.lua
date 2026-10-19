local cores = {}

local BRANCO = {1, 1, 1}
local AMARELO = {1, 0.85, 0.2}
local VERMELHO = {1, 0.3, 0.3}
local FUNDO = {0.25, 0.25, 0.25}
cores.LARANJA = {1, 0.6, 0.3}

-- Texto colorido: so o nome leva a cor da coisa (inimigo, pocao...).
-- prefixo e sufixo sao opcionais.
function cores.nome(coisa, prefixo, sufixo)
    return {BRANCO, prefixo or "", coisa.cor or BRANCO, coisa.nome, BRANCO, sufixo or ""}
end

-- fracao: 0 a 1 (vida atual / vida maxima)
function cores.daVida(fracao)
    if fracao > 0.5 then
        return BRANCO
    elseif fracao >= 0.25 then
        return AMARELO
    else
        return VERMELHO
    end
end

-- Desenha uma barra de vida em (x, y). fracao: 0 a 1.
function cores.barra(x, y, largura, altura, fracao)
    fracao = math.max(0, math.min(1, fracao))

    love.graphics.setColor(FUNDO)
    love.graphics.rectangle("fill", x, y, largura, altura)

    love.graphics.setColor(cores.daVida(fracao))
    love.graphics.rectangle("fill", x, y, largura * fracao, altura)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, largura, altura)
end

return cores
