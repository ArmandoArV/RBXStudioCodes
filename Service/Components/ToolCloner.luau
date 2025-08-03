-- ToolCloner.lua
-- ModuleScript for efficient tool cloning from ReplicatedStorage.Tools

local ToolCloner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolFolder = ReplicatedStorage:WaitForChild("Tools")

-- Configuration
local DEBUG_MODE = false -- Set to true for debugging

-- Returns a clone of the tool with the given name, or nil if not found
function ToolCloner.CloneTool(toolName)
    if DEBUG_MODE then
        print("ToolCloner DEBUG: Attempting to clone tool:", toolName)
    end
    
    local tool = ToolFolder:FindFirstChild(toolName)
    if tool and tool:IsA("Tool") then
        if DEBUG_MODE then
            print("ToolCloner DEBUG: Tool found and cloned:", toolName)
        end
        return tool:Clone()
    else
        if DEBUG_MODE then
            print("ToolCloner DEBUG: Tool not found:", toolName)
            print("ToolCloner DEBUG: Available tools in ReplicatedStorage.Tools:")
            for _, child in pairs(ToolFolder:GetChildren()) do
                if child:IsA("Tool") then
                    print("  -", child.Name)
                end
            end
        end
    end
    return nil
end

-- Enable/disable debug mode
function ToolCloner.SetDebugMode(enabled)
    DEBUG_MODE = enabled
end

-- Get list of available tools
function ToolCloner.GetAvailableTools()
    local tools = {}
    for _, child in pairs(ToolFolder:GetChildren()) do
        if child:IsA("Tool") then
            table.insert(tools, child.Name)
        end
    end
    return tools
end

return ToolCloner
