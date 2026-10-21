local jogo = require("jogo")
local historico = require("historico")
local fontes = require("fontes")
local ui = require("ui")
local sprites = require("sprites")

local estado = {}

local indice
local fonte

function estado.entrar()
    fonte = fontes.media
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
    love.graphics.print("ÚLTIMAS PARTIDAS", 20, 16)
    love.graphics.setFont(fonte)

    if #historico.partidas == 0 then
        love.graphics.print("(ainda não há partidas registadas)", 20, 60)
    end

    local altura = fonte:getHeight()
    for i, p in ipairs(historico.partidas) do
        local sel = (i == indice)
        local y = 56 + (i - 1) * 22
        if sel then
            love.graphics.setColor(1, 1, 1)
            if not ui.cursor(20, y + (altura - 13) / 2, 1) then
                love.graphics.print(">", 20, y)
            end
        end
        love.graphics.setColor(sel and {1, 0.85, 0.2} or {1, 1, 1})
        love.graphics.print(string.format("#%s  %s  %s  sala %s  nv %s%s%s", p.numero, p.data, p.classe, p.sala,
            p.nivel, p.recorde == "1" and "  (recorde)" or "",
            p.vitoria == "1" and "  VITÓRIA" or ""), 44, y)
    end

    local p = historico.partidas[indice]
    if p then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("Nível %s   Vida máx %s   Ataque %s   Defesa %s   Moedas %s", p.nivel,
            p.vida_max, p.ataque, p.defesa, p.moedas), 20, 274)
        love.graphics.print(historico.itens(p.arma, "Arma: "), 20, 296)
        love.graphics.print(historico.itens(p.armadura, "Armadura: "), 20, 318)
        love.graphics.print(string.format("Dano causado %s   Dano sofrido %s   Poções %s", p.dano_causado,
            p.dano_sofrido, p.pocoes), 20, 340)
        love.graphics.print(string.format("Inimigos %s (chefes %s) ", p.inimigos, p.chefes), 20, 362)
        if p.causa == "?" and p.vitoria == "1" then
            love.graphics.print({{1, 0.85, 0.2}, "Terminou a aventura Vitorioso"}, 20, 362)
        else
            love.graphics.print({{1, 1, 1}, "Morto por: ", historico.corInimigo(p.causa), p.causa}, 260, 362)
        end
        if p.cruz == "1" then
            love.graphics.print({{1, 1, 0.75}, "Cruz Sagrada: Salvou-te nesta partida"}, 20, 384)
        end
    end

    love.graphics.setFont(normal)
    love.graphics.setColor(1, 1, 1)
    sprites.ajuda({"CIMABAIXO", "Cima/Baixo", "B", "voltar"}, 20, 440)
end

return estado
