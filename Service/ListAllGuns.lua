-- ListAllGuns.lua
-- Script to print all gun tool names in ReplicatedStorage.Tools.Guns

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunsFolder = ReplicatedStorage:WaitForChild("Tools"):WaitForChild("Guns")

print("[GUNS LIST]")
for _, tool in pairs(GunsFolder:GetDescendants()) do
    if tool:IsA("Tool") then
        print("Gun Tool:", tool.Name)
    end
end
