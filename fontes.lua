local fontes = {}

-- Caminhos. Se um ficheiro nao existir, o jogo usa a fonte por defeito (nao rebenta).
local CORPO = "fontes/PixelifySans-Regular.ttf"
local TITULO = "fontes/Alagard.ttf"

-- Tamanhos num so sitio: e aqui que afinas o aspeto
local TAMANHOS = {
    titulo = 32,
    normal = 22,
    media = 18,
    pequena = 15,
    minima = 13,
    enorme = 56
}

local function criar(caminho, tamanho)
    if love.filesystem.getInfo(caminho) then
        return love.graphics.newFont(caminho, tamanho)
    end
    return love.graphics.newFont(tamanho)
end

-- Chamar uma vez no love.load, DEPOIS do setDefaultFilter("nearest", "nearest")
function fontes.carregar()
    fontes.titulo = criar(TITULO, TAMANHOS.titulo)
    fontes.normal = criar(CORPO, TAMANHOS.normal)
    fontes.media = criar(CORPO, TAMANHOS.media)
    fontes.pequena = criar(CORPO, TAMANHOS.pequena)
    fontes.minima = criar(CORPO, TAMANHOS.minima)
    fontes.enorme = criar(TITULO, TAMANHOS.enorme)
end

return fontes
