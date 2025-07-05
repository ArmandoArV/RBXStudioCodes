-- ToolCloner.lua
-- ModuleScript for efficient tool cloning from ReplicatedStorage.Tools

local ToolCloner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolFolder = ReplicatedStorage:WaitForChild("Tools")

-- Returns a clone of the tool with the given name, or nil if not found
function ToolCloner.CloneTool(toolName)
    local tool = ToolFolder:FindFirstChild(toolName)
    if tool and tool:IsA("Tool") then
        return tool:Clone()
    end
    return nil
end

return ToolCloner
