local armazem = {}

-- Na consola (Linux) grava ao lado do arcane.love.
-- No PC usa a pasta de gravacoes normal do LOVE.
local function usaFicheiro()
    return love.system.getOS() == "Linux"
end

local function caminho(nome)
    return love.filesystem.getSourceBaseDirectory() .. "/" .. nome
end

function armazem.descricao()
    if usaFicheiro() then
        return love.filesystem.getSourceBaseDirectory()
    end
    return love.filesystem.getSaveDirectory()
end

function armazem.escrever(nome, texto)
    if usaFicheiro() then
        local f, erro = io.open(caminho(nome), "w")
        if not f then
            return false, erro
        end
        f:write(texto)
        f:close()
        return true
    end
    return love.filesystem.write(nome, texto)
end

-- Devolve o conteudo ou nil
function armazem.ler(nome)
    if usaFicheiro() then
        local f = io.open(caminho(nome), "r")
        if not f then
            return nil
        end
        local texto = f:read("*a")
        f:close()
        return texto
    end
    if love.filesystem.getInfo(nome) then
        return love.filesystem.read(nome)
    end
    return nil
end

function armazem.existe(nome)
    return armazem.ler(nome) ~= nil
end

function armazem.remover(nome)
    if usaFicheiro() then
        os.remove(caminho(nome))
    else
        love.filesystem.remove(nome)
    end
end

-- Iterador de linhas (vazio se o ficheiro nao existir)
function armazem.linhas(nome)
    return (armazem.ler(nome) or ""):gmatch("[^\r\n]+")
end

return armazem
