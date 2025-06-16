local Podium = require(game.ServerScriptService.Classes.Podium)

local PodiumManager = {}
PodiumManager.__index = PodiumManager

function PodiumManager.new(podiumsFolder)
    local self = setmetatable({}, PodiumManager)
    self.Podiums = {}
    for _, model in ipairs(podiumsFolder:GetChildren()) do
        local podium = Podium.new(model)
        if podium.Id then
            self.Podiums[podium.Id] = podium
        end
    end
    return self
end

function PodiumManager:GetPodiumById(id)
    return self.Podiums[id]
end

return PodiumManager