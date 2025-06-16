local PodiumManager = require(game.ServerScriptService.Manager.PodiumManager)

local podiumsFolder = workspace.Podiums
local manager = PodiumManager.new(podiumsFolder)

local podium = manager:GetPodiumById(1)
if podium then
    podium:PrintInfo()
end