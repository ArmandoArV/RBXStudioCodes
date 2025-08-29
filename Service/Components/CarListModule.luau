-- CarListModule.luau
-- Lista de carros para la tienda, con metadatos para filtrado y UI
local CarList = {
    -- Ejemplo de entrada:
    -- ["ModelName"] = {
    --     price = 25000,
    --     gamepass = nil, -- o true/false
    --     team = nil, -- "narco", "militar", "civil", o nil
    --     category = "SEDAN", -- "SUV", "HATCHBACK", "PICKUP", etc.
    --     artillado = false, -- true si es artillado
    --     colors = {Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0)},
    --     maxSpeed = 120, -- opcional, para mostrar en UI
    --     seats = 4, -- opcional, para mostrar en UI
    --     durability = 900, -- opcional, para mostrar en UI
    -- },
    ["Sedan2021"] = {
        price = 35000,
        gamepass = nil,
        team = nil,
        category = "SEDAN",
        artillado = false,
        colors = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0)},
        maxSpeed = 140,
        seats = 4,
        durability = 900
    },
    ["NarcoSUV"] = {
        price = 80000,
        gamepass = nil,
        team = "narco",
        category = "SUV",
        artillado = true,
        colors = {Color3.fromRGB(50, 50, 50)},
        maxSpeed = 130,
        seats = 6,
        durability = 850
    }
    -- Agrega más carros aquí...
}

return CarList
