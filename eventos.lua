local jogador = require("jogador")
local loot = require("loot")
local bencoes = require("bencoes")

local eventos = {}

local BRANCO = {1, 1, 1}
local COR_ATAQUE = {1, 0.5, 0.4}
local COR_VIDA = {0.4, 1, 0.5}
local COR_GANHO = {0.4, 1, 0.4}
local COR_PERDA = {1, 0.4, 0.4}

-- Texto colorido: antes (branco) + destaque (na cor dada) + depois (branco)
local function colorir(antes, cor, destaque, depois)
    return {BRANCO, antes, cor, destaque, BRANCO, depois or ""}
end

local function chancePonte()
    return math.min(0.9, 0.4 + 0.03 * jogador.defesaTotal())
end

-- Perde vida sem nunca matar (deixa sempre pelo menos 1). Devolve o dano real.
local function perder(n)
    local dano = math.max(0, math.min(n, jogador.vida - 1))
    jogador.vida = jogador.vida - dano
    jogador.stats.dano_sofrido = jogador.stats.dano_sofrido + dano
    return dano
end

-- preco que cresce com a sala
local function preco(base, porSala)
    return base + porSala * jogador.sala
end

local function precoTreinador()
    return preco(60, 10)
end

-- quantas moedas o ladrao leva: 15% da bolsa, no minimo 5 (nunca mais do que tens)
local function roubo()
    return math.min(jogador.moedas, math.max(5, math.floor(jogador.moedas * 0.15)))
end

local function ignorar()
    return "Segues caminho."
end

-- preco que cresce com a sala
local function preco(base, porSala)
    return base + porSala * jogador.sala
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
        texto = "Oferecer 100 moedas (+3 vida maxima)",
        efeito = function()
            if jogador.moedas < 100 then
                return "Nao tens moedas suficientes.", true
            end
            jogador.moedas = jogador.moedas - 100
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
    texto = "Um viajante encapuzado propoe um jogo: apostas 50 moedas e, se ganhares, ele paga o mesmo.",
    opcoes = {{
        texto = "Apostar 50 moedas",
        efeito = function()
            if jogador.moedas < 50 then
                return "Nao tens 50 moedas.", true
            end
            if math.random() < 0.45 then
                jogador.ganharMoedas(50)
                return "Os dados sorriem-te! Ganhas 50 moedas."
            end
            jogador.moedas = jogador.moedas - 50
            return "Perdes. O viajante guarda as tuas 50 moedas."
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
        texto = "Deitar 50 moedas",
        efeito = function()
            if jogador.moedas < 50 then
                return "Nao tens 10 moedas.", true
            end
            jogador.moedas = jogador.moedas - 50
            local sorte = math.random(100)
            if sorte <= 50 then
                return "A agua fica em silencio. Nada acontece."
            elseif sorte <= 80 then
                jogador.darPocao("pequena")
                return "Algo borbulha e sobe a superficie: uma Pocao Pequena!"
            end
            jogador.ganharMoedas(150)
            return "O poco devolve-te 150 moedas!"
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
        texto = "Melhorar a arma (+1) por 50 moedas",
        efeito = function()
            if not jogador.arma then
                return "Nao tens nenhuma arma equipada.", true
            end
            if jogador.moedas < 50 then
                return "Nao tens 50 moedas.", true
            end
            jogador.moedas = jogador.moedas - 50
            jogador.forja.arma = jogador.forja.arma + 1
            return jogador.arma.nome .. " agora e " .. jogador.textoBonus(jogador.arma) .. "."
        end
    }, {
        texto = "Melhorar a armadura (+1) por 50 moedas",
        efeito = function()
            if not jogador.armadura then
                return "Nao tens nenhuma armadura equipada.", true
            end
            if jogador.moedas < 50 then
                return "Nao tens 50 moedas.", true
            end
            jogador.moedas = jogador.moedas - 50
            jogador.forja.armadura = jogador.forja.armadura + 1
            return jogador.armadura.nome .. " agora e " .. jogador.textoBonus(jogador.armadura) .. "."
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
}, {
    id = "treinador",
    titulo = "O treinador",
    minSala = 4,
    texto = "Um veterano cansado oferece-se para te ensinar, por um preco justo.",
    opcoes = {{
        texto = function()
            return "Treino de combate (+1 ataque) por " .. precoTreinador() .. " moedas"
        end,
        colorido = function(prefixo)
            return colorir(prefixo .. "Treino de combate (", COR_ATAQUE, "+1 ataque",
                ") por " .. precoTreinador() .. " moedas")
        end,
        efeito = function()
            local p = precoTreinador()
            if jogador.moedas < p then
                return "Nao tens " .. p .. " moedas.", true
            end
            jogador.moedas = jogador.moedas - p
            jogador.ataque_base = jogador.ataque_base + 1
            return colorir("Aprendes um golpe novo. ", COR_ATAQUE, "Ataque base: " .. jogador.ataque_base, ".")
        end
    }, {
        texto = function()
            return "Treino de resistencia (+5 vida maxima) por " .. precoTreinador() .. " moedas"
        end,
        colorido = function(prefixo)
            return colorir(prefixo .. "Treino de resistencia (", COR_VIDA, "+5 vida maxima",
                ") por " .. precoTreinador() .. " moedas")
        end,
        efeito = function()
            local p = precoTreinador()
            if jogador.moedas < p then
                return "Nao tens " .. p .. " moedas.", true
            end
            jogador.moedas = jogador.moedas - p
            jogador.vida_max = jogador.vida_max + 5
            jogador.vida = jogador.vida + 5
            return colorir("Ficas mais rijo. ", COR_VIDA, "Vida maxima: " .. jogador.vida_max, ".")
        end
    }, {
        texto = "Recusar",
        efeito = ignorar
    }}
}, {
    id = "ponte",
    titulo = "A ponte podre",
    minSala = 3,
    texto = "Uma ponte de corda balanca sobre um abismo. Do outro lado ha um cofre.",
    opcoes = {{
        texto = function()
            return "Atravessar (" .. math.floor(chancePonte() * 100) .. "% de chance)"
        end,
        efeito = function()
            if math.random() < chancePonte() then
                local n = 20 + 5 * jogador.sala
                jogador.ganharMoedas(n)
                return colorir("Chegas ao outro lado! O cofre tem ", COR_GANHO, n .. " moedas", ".")
            end
            local dano = perder(math.max(3, math.floor(jogador.vida_max * 0.25)))
            return colorir("A ponte cede! Perdes ", COR_PERDA, dano .. " de vida", ".")
        end
    }, {
        texto = "Dar a volta",
        efeito = ignorar
    }}
}, {
    id = "espelho",
    titulo = "O espelho antigo",
    minSala = 5,
    texto = "Um espelho mostra uma versao diferente de ti. Promete trocar forca por resistencia, ou o contrario.",
    opcoes = {{
        texto = "Trocar 1 de ataque base por 8 de vida maxima",
        efeito = function()
            if jogador.ataque_base < 2 then
                return "Nao tens ataque que chegue para trocar.", true
            end
            jogador.ataque_base = jogador.ataque_base - 1
            jogador.vida_max = jogador.vida_max + 8
            jogador.vida = jogador.vida + 8
            return "O espelho brilha. Ataque base " .. jogador.ataque_base .. ", vida maxima " .. jogador.vida_max ..
                       "."
        end
    }, {
        texto = "Trocar 8 de vida maxima por 1 de ataque base",
        efeito = function()
            if jogador.vida_max < 28 then
                return "Estas demasiado fragil para isto.", true
            end
            jogador.vida_max = jogador.vida_max - 8
            jogador.vida = math.min(jogador.vida, jogador.vida_max)
            jogador.ataque_base = jogador.ataque_base + 1
            return "O espelho brilha. Ataque base " .. jogador.ataque_base .. ", vida maxima " .. jogador.vida_max ..
                       "."
        end
    }, {
        texto = "Afastar-te",
        efeito = ignorar
    }}
}, {
    id = "sacrificio",
    titulo = "A pira do sacrificio",
    minSala = 4,
    texto = "Uma pira antiga pede uma oferenda. Em troca, as chamas curam-te por completo.",
    opcoes = function()
        -- os itens da mochila com a posicao, do mais fraco para o mais forte
        local itens = {}
        for i, item in ipairs(jogador.inventario) do
            table.insert(itens, {
                item = item,
                pos = i
            })
        end
        table.sort(itens, function(a, b)
            if a.item.bonus ~= b.item.bonus then
                return a.item.bonus < b.item.bonus
            end
            return a.pos < b.pos -- empate: mantem a ordem da mochila
        end)

        local lista = {}
        for i = 1, math.min(3, #itens) do
            local item = itens[i].item
            table.insert(lista, {
                texto = "Queimar " .. item.nome .. " (+" .. item.bonus .. ")",
                colorido = function(prefixo)
                    return loot.nomeColorido(item, prefixo .. "Queimar ", " (+" .. item.bonus .. ")")
                end,
                efeito = function()
                    if jogador.vida >= jogador.vida_max then
                        return "Ja tens a vida cheia.", true
                    end
                    -- procura o item de novo: a mochila pode ter mudado
                    for j, outro in ipairs(jogador.inventario) do
                        if outro == item then
                            jogador.largar(j)
                            local cura = jogador.vida_max - jogador.vida
                            jogador.vida = jogador.vida_max
                            return "As chamas consomem " .. item.nome .. ". Recuperas " .. cura .. " de vida."
                        end
                    end
                    return "Esse item ja nao esta na mochila.", true
                end
            })
        end
        table.insert(lista, {
            texto = (#itens == 0) and "A mochila esta vazia. Afastar-te" or "Afastar-te",
            efeito = ignorar
        })
        return lista
    end
}, {
    id = "ladrao",
    titulo = "O ladrao",
    minSala = 3,
    texto = "Um vulto salta das sombras e agarra a tua bolsa. Talvez o consigas apanhar.",
    opcoes = {{
        texto = "Deixar levar 15% das moedas",
        efeito = function()
            local n = roubo()
            jogador.moedas = jogador.moedas - n
            return "O ladrao foge com " .. n .. " moedas."
        end
    }, {
        texto = "Persegui-lo (50%: ficas com a bolsa dele; senao, -25% vida)",
        efeito = function()
            if math.random() < 0.5 then
                local n = math.max(10, math.floor(jogador.moedas * 0.15)) + jogador.sala
                jogador.ganharMoedas(n)
                return "Apanhas o ladrao! Ficas com " .. n .. " moedas."
            end
            local dano = perder(math.max(3, math.floor(jogador.vida_max * 0.25)))
            local n = roubo()
            jogador.moedas = jogador.moedas - n
            return "Foge-te e ainda tropecas. Perdes " .. dano .. " de vida e " .. n .. " moedas."
        end
    }}
}, {
    id = "monge",
    titulo = "O monge viajante",
    minSala = 5,
    texto = "Um monge oferece uma bencao ao acaso, a metade do preco do santuario.",
    opcoes = {{
        texto = "Aceitar uma bencao ao acaso",
        efeito = function()
            local b = bencoes.porId(bencoes.sortearOferta(1)[1])
            local ok, mensagem, colorida = bencoes.aplicar(b, jogador, 0.5)
            if not ok then
                return mensagem, true
            end
            return colorida
        end
    }, {
        texto = "Recusar",
        efeito = ignorar
    }}
}, {
    id = "biblioteca",
    titulo = "A biblioteca esquecida",
    minSala = 3,
    texto = "Estantes cobertas de po guardam livros antigos e alguns frascos.",
    opcoes = {{
        texto = "Estudar os livros (experiencia)",
        efeito = function()
            local xp = math.ceil(jogador.xpNecessario() / 2)
            local subiu = jogador.ganharXp(xp)
            return "Aprendes bastante: +" .. xp .. " de experiencia." .. (subiu > 0 and " Subiste de nivel!" or "")
        end
    }, {
        texto = "Levar uma pocao media",
        efeito = function()
            jogador.darPocao("media")
            return "Encontras uma Pocao Media numa estante."
        end
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
