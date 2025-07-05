-- ProximityPromptUI.luau
-- Example usage of ProximityPromptModule to open a GUI from StarterGui

local ProximityPromptModule = require(script.Parent.Service.ProximityPromptModule)
local Players = game:GetService("Players")

-- Replace these with your actual ProximityPrompt and GUI names/locations
local prompt = workspace:FindFirstChild("ProximityPrompt")
local guiName = "YourGuiName" -- Change this to your GUI's name

if prompt then
    local lastState = false
    ProximityPromptModule.connect(prompt, function(player, _)
        if player and player:IsA("Player") then
            local playerGui = player:FindFirstChildOfClass("PlayerGui")
            if playerGui then
                local gui = playerGui:FindFirstChild(guiName)
                if not gui then
                    -- Clone from StarterGui if not present
                    local starterGui = game:GetService("StarterGui")
                    local template = starterGui:FindFirstChild(guiName)
                    if template then
                        gui = template:Clone()
                        gui.Parent = playerGui
                    end
                end
                if gui then
                    gui.Enabled = not gui.Enabled
                end
            end
        end
    end)
else
    warn("ProximityPrompt not found in workspace.")
end
