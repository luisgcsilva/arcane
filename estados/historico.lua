local jogo = require("jogo")
local historico = require("historico")

local estado = {}

local indice
local fonte

function estado.entrar()
    fonte = fonte or love.graphics.newFont(16)
    indice = 1
end

function estado.acao(a)
    local n = #historico.partidas
    if a == "cima" and n > 0 then
        indice = indice - 1
        if indice < 1 then
            indice = n
        end
    elseif a == "baixo" and n > 0 then
        indice = indice + 1
        if indice > n then
            indice = 1
        end
    elseif a == "cancelar" then
        jogo.mudar("menu")
    end
end

function estado.desenhar()
    local normal = love.graphics.getFont()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("ULTIMAS PARTIDAS", 20, 16)
    love.graphics.setFont(fonte)

    if #historico.partidas == 0 then
        love.graphics.print("(ainda nao ha partidas registadas)", 20, 60)
    end

    for i, p in ipairs(historico.partidas) do
        local sel = (i == indice)
        love.graphics.setColor(sel and {1, 0.85, 0.2} or {1, 1, 1})
        love.graphics.print(string.format("%s #%s  %s  %s  sala %s  nv %s%s", sel and ">" or " ", p.numero, p.data,
            p.classe, p.sala, p.nivel, p.recorde == "1" and "  (recorde)" or ""), 20, 56 + (i - 1) * 22)
    end

    local p = historico.partidas[indice]
    if p then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("Nivel %s   Vida max %s   Ataque %s   Defesa %s   Moedas %s", p.nivel,
            p.vida_max, p.ataque, p.defesa, p.moedas), 20, 270)
        love.graphics.print(historico.itens(p.arma, "Arma: "), 20, 292)
        love.graphics.print(historico.itens(p.armadura, "Armadura: "), 20, 314)
        love.graphics.print(string.format("Inimigos %s (chefes %s)   Dano causado %s   Dano sofrido %s   Pocoes %s",
            p.inimigos, p.chefes, p.dano_causado, p.dano_sofrido, p.pocoes), 20, 336)
        love.graphics.print({{1, 1, 1}, "Morto por: ", historico.corInimigo(p.causa), p.causa}, 20, 358)
    end

    love.graphics.setFont(normal)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Cima/baixo  B voltar", 20, 440)
end

return estado
