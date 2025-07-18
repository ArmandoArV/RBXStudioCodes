-- Script to create capture points from manually placed objects in Workspace.CapturePoints
-- Place this in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CapturePointHandler = require(ReplicatedStorage:WaitForChild("Handler"):WaitForChild("CapturePointHandler"))
local replicateCapturePoints = require(ReplicatedStorage:WaitForChild("Service"):WaitForChild("ReplicateCapturePoints"))
local folder = Workspace:WaitForChild("CapturePoints")

for _, obj in ipairs(folder:GetChildren()) do
    local name = obj.Name
    local location
    if obj:IsA("BasePart") then
        location = obj.Position
    elseif obj:IsA("Model") and obj.PrimaryPart then
        location = obj.PrimaryPart.Position
    end
    if name and location then
        CapturePointHandler:CreateCapturePoint(name, location)
        print("Created capture point:", name, location)
    else
        warn("Could not create capture point for object:", obj:GetFullName())
    end
end

replicateCapturePoints()
