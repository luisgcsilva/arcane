local jogador = require("jogador")
local loot = require("loot")

local eventos = {}

-- Perde vida sem nunca matar (deixa sempre pelo menos 1). Devolve o dano real.
local function perder(n)
    local dano = math.max(0, math.min(n, jogador.vida - 1))
    jogador.vida = jogador.vida - dano
    jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + dano
    return dano
end

local function ignorar()
    return "Segues caminho."
end

-- Cada opcao tem um "efeito": uma funcao que devolve uma mensagem.
-- Se devolver true como segundo valor, a opcao foi recusada (sem custo)
-- e o jogador pode escolher outra.
eventos.lista = {{
    id = "fonte",
    titulo = "A fonte misteriosa",
    minSala = 2,
    texto = "Uma fonte de agua cristalina brilha no meio da sala. Sera segura?",
    opcoes = {{
        texto = "Beber da fonte",
        efeito = function()
            if math.random() < 0.5 then
                local cura = math.min(math.ceil(jogador.vida_max * 0.5), jogador.vida_max - jogador.vida)
                jogador.vida = jogador.vida + cura
                return "A agua e revigorante! Recuperas " .. cura .. " de vida."
            end
            local dano = perder(math.max(2, math.floor(jogador.vida_max * 0.2)))
            return "A agua estava envenenada! Perdes " .. dano .. " de vida."
        end
    }, {
        texto = "Ignorar",
        efeito = ignorar
    }}
}, {
    id = "altar",
    titulo = "O altar sombrio",
    minSala = 3,
    texto = "Um altar de pedra negra pede uma oferenda em troca de poder.",
    opcoes = {{
        texto = "Oferecer sangue (-25% vida, +1 ataque)",
        efeito = function()
            local custo = math.floor(jogador.vida_max * 0.25)
            if jogador.vida - custo < 1 then
                return "Estas demasiado fraco para isto.", true
            end
            jogador.vida = jogador.vida - custo
            jogador.ataque_base = jogador.ataque_base + 1
            return "O altar aceita. Perdes " .. custo .. " de vida e o teu ataque base sobe para " ..
                       jogador.ataque_base .. "."
        end
    }, {
        texto = "Oferecer 20 moedas (+3 vida maxima)",
        efeito = function()
            if jogador.moedas < 20 then
                return "Nao tens moedas suficientes.", true
            end
            jogador.moedas = jogador.moedas - 20
            jogador.vida_max = jogador.vida_max + 3
            jogador.vida = jogador.vida + 3
            return "O altar aceita. Vida maxima +3."
        end
    }, {
        texto = "Ignorar",
        efeito = ignorar
    }}
}, {
    id = "viajante",
    titulo = "O viajante dos dados",
    minSala = 2,
    texto = "Um viajante encapuzado propoe um jogo: apostas 15 moedas e, se ganhares, ele paga o mesmo.",
    opcoes = {{
        texto = "Apostar 15 moedas",
        efeito = function()
            if jogador.moedas < 15 then
                return "Nao tens 15 moedas.", true
            end
            if math.random() < 0.45 then
                jogador.ganharMoedas(15)
                return "Os dados sorriem-te! Ganhas 15 moedas."
            end
            jogador.moedas = jogador.moedas - 15
            return "Perdes. O viajante guarda as tuas 15 moedas."
        end
    }, {
        texto = "Recusar",
        efeito = function()
            return "O viajante encolhe os ombros e desaparece na sombra."
        end
    }}
}, {
    id = "espada",
    titulo = "A pedra encantada",
    minSala = 3,
    texto = "Algo brilha preso numa pedra negra. Puxas, ou nao vale o risco?",
    opcoes = {{
        texto = "Puxar com forca",
        efeito = function()
            if math.random() < 0.4 then
                local item = loot.sortear(jogador.sala + 8)
                if jogador.guardar(item) then
                    return "A pedra cede! Guardas " .. item.nome .. " (+" .. item.bonus .. ")."
                end
                local ganho = loot.precoVenda(item)
                jogador.ganharMoedas(ganho)
                return "A pedra cede, mas a mochila esta cheia. Vendes o achado por " .. ganho .. " moedas."
            end
            local dano = perder(math.max(3, math.floor(jogador.vida_max * 0.2)))
            return "Um choque percorre-te! Perdes " .. dano .. " de vida."
        end
    }, {
        texto = "Ignorar",
        efeito = ignorar
    }}
}, {
    id = "poco",
    titulo = "O poco dos desejos",
    minSala = 2,
    texto = "Um poco antigo com moedas no fundo. Dizem que quem deita uma moeda tem sorte.",
    opcoes = {{
        texto = "Deitar 10 moedas",
        efeito = function()
            if jogador.moedas < 10 then
                return "Nao tens 10 moedas.", true
            end
            jogador.moedas = jogador.moedas - 10
            local sorte = math.random(100)
            if sorte <= 50 then
                return "A agua fica em silencio. Nada acontece."
            elseif sorte <= 80 then
                jogador.darPocao("pequena")
                return "Algo borbulha e sobe a superficie: uma Pocao Pequena!"
            end
            jogador.ganharMoedas(35)
            return "O poco devolve-te 35 moedas!"
        end
    }, {
        texto = "Ignorar",
        efeito = ignorar
    }}
}, {
    id = "ferreiro",
    titulo = "O ferreiro errante",
    minSala = 3,
    texto = "Um ferreiro com a forja as costas oferece-se para melhorar o teu equipamento.",
    opcoes = {{
        texto = "Melhorar a arma (+1) por 25 moedas",
        efeito = function()
            if not jogador.arma then
                return "Nao tens nenhuma arma equipada.", true
            end
            if jogador.moedas < 25 then
                return "Nao tens 25 moedas.", true
            end
            jogador.moedas = jogador.moedas - 25
            jogador.arma.bonus = jogador.arma.bonus + 1
            return jogador.arma.nome .. " agora e +" .. jogador.arma.bonus .. "."
        end
    }, {
        texto = "Melhorar a armadura (+1) por 25 moedas",
        efeito = function()
            if not jogador.armadura then
                return "Nao tens nenhuma armadura equipada.", true
            end
            if jogador.moedas < 25 then
                return "Nao tens 25 moedas.", true
            end
            jogador.moedas = jogador.moedas - 25
            jogador.armadura.bonus = jogador.armadura.bonus + 1
            return jogador.armadura.nome .. " agora e +" .. jogador.armadura.bonus .. "."
        end
    }, {
        texto = "Seguir caminho",
        efeito = ignorar
    }}
}, {
    id = "prisioneiro",
    titulo = "O prisioneiro",
    minSala = 4,
    texto = "Um homem acorrentado pede-te que o soltes. Parece honesto... mas e tarde para desconfiar?",
    opcoes = {{
        texto = "Libertar o prisioneiro",
        efeito = function()
            if math.random() < 0.6 then
                local n = math.random(15, 25) + jogador.sala
                jogador.ganharMoedas(n)
                jogador.darPocao("pequena")
                return "Agradecido, ele da-te " .. n .. " moedas e uma Pocao Pequena."
            end
            local dano = perder(math.max(3, math.floor(jogador.vida_max * 0.25)))
            return "Era uma armadilha! Emboscam-te e perdes " .. dano .. " de vida."
        end
    }, {
        texto = "Deixa-lo la",
        efeito = ignorar
    }}
}, {
    id = "cogumelos",
    titulo = "Os cogumelos brilhantes",
    minSala = 2,
    texto = "Um grupo de cogumelos brilha na escuridao. Cheiram bem, mas quem sabe...",
    opcoes = {{
        texto = "Comer um",
        efeito = function()
            local sorte = math.random(100)
            if sorte <= 40 then
                local cura = math.min(math.ceil(jogador.vida_max * 0.3), jogador.vida_max - jogador.vida)
                jogador.vida = jogador.vida + cura
                return "Sabem a mel! Recuperas " .. cura .. " de vida."
            elseif sorte <= 80 then
                local dano = perder(math.max(2, math.floor(jogador.vida_max * 0.15)))
                return "Sentes o estomago às voltas. Perdes " .. dano .. " de vida."
            end
            jogador.vida_max = jogador.vida_max + 2
            jogador.vida = jogador.vida + 2
            return "Sentes-te mais forte! Vida maxima +2."
        end
    }, {
        texto = "Ignorar",
        efeito = ignorar
    }}
}}

function eventos.porId(id)
    for _, ev in ipairs(eventos.lista) do
        if ev.id == id then
            return ev
        end
    end
end

function eventos.existe(id)
    return eventos.porId(id) ~= nil
end

function eventos.sortear(sala)
    local elegiveis = {}
    for _, ev in ipairs(eventos.lista) do
        if ev.minSala <= sala then
            table.insert(elegiveis, ev)
        end
    end
    return elegiveis[math.random(#elegiveis)]
end

return eventos
