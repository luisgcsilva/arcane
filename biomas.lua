local biomas = {}

biomas.SALAS_POR_BIOMA = 10

-- A ordem da lista e a da progressao: o 1.o bioma e das salas 1-10, etc.
biomas.lista = {{
    id = "cavernas",
    nome = "Cavernas",
    cor = {0.75, 0.6, 0.4}
}, {
    id = "pantano",
    nome = "Pantano",
    cor = {0.5, 0.8, 0.4}
}, {
    id = "catacumbas",
    nome = "Catacumbas",
    cor = {0.8, 0.8, 0.85}
}, {
    id = "fortaleza",
    nome = "Fortaleza",
    cor = {0.6, 0.65, 0.8}
}, {
    id = "torre",
    nome = "Torre Arcana",
    cor = {0.75, 0.5, 0.95}
}, {
    id = "tundra",
    nome = "Tundra Gelada",
    cor = {0.6, 0.85, 1}
}, {
    id = "vulcao",
    nome = "Vulcao",
    cor = {1, 0.5, 0.2}
}, {
    id = "afundada",
    nome = "Cidade Afundada",
    cor = {0.3, 0.7, 0.75}
}, {
    id = "abismo",
    nome = "Abismo",
    cor = {0.8, 0.25, 0.35}
}, {
    id = "trono",
    nome = "Trono Eterno",
    cor = {1, 0.85, 0.3}
}}

function biomas.daSala(sala)
    local i = math.floor((sala - 1) / biomas.SALAS_POR_BIOMA) + 1
    i = math.max(1, math.min(i, #biomas.lista)) -- sala 0 -> 1; depois do ultimo, fica o ultimo
    return biomas.lista[i]
end

-- Sem campo "biomas", o modelo aparece em todos.
function biomas.permite(modelo, id)
    if modelo.biomas == nil then
        return true
    end
    for _, b in ipairs(modelo.biomas) do
        if b == id then
            return true
        end
    end
    return false
end

return biomas
