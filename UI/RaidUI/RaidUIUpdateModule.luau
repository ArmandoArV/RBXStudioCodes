-- RaidUIUpdateModule.luau
-- Updates RaidUI MainFrame and endscreen with capture point info from event system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Gui = player:WaitForChild("PlayerGui"):WaitForChild("RaidUI")
local MainFrame = Gui:FindFirstChild("MainFrame")
local End = Gui:FindFirstChild("endscreen")

local remoteEvent = ReplicatedStorage:WaitForChild("CapturePointEvent")

local function updateRaidUI(info)
    if not info then return end
    -- MainFrame updates
    if MainFrame then
        if MainFrame:FindFirstChild("Title") then
            MainFrame.Title.Text = info.Name or "Terminal"
        end
        if MainFrame:FindFirstChild("counter") then
            MainFrame.counter.Text = tostring(info.Timer)
        end
        if MainFrame:FindFirstChild("mode") then
            MainFrame.mode.Text = info.Mode or "-"
        end
        if MainFrame:FindFirstChild("official") then
            MainFrame.official.Text = info.Official and "OFFICIAL" or "UNOFFICIAL"
        end
        if MainFrame:FindFirstChild("status") then
            MainFrame.status.Text = info.Status or "-"
        end
        if MainFrame:FindFirstChild("timer") then
            MainFrame.timer.Text = tostring(info.Score)
        end
    end
    -- Endscreen updates
    if End then
        if End:FindFirstChild("Team") then
            End.Team.Text = info.Owner or "No Owner"
        end
        if End:FindFirstChild("title") then
            End.title.Text = info.Name or "Terminal"
        end
        if End:FindFirstChild("title2") then
            End.title2.Text = info.Owner or "No Owner"
        end
        if End:FindFirstChild("Code") then
            End.Code.Text = info.Code or "-"
        end
        if End:FindFirstChild("enemyflag") then
            End.enemyflag.Image = info.EnemyFlag or ""
        end
        if End:FindFirstChild("friendlyflag") then
            End.friendlyflag.Image = info.FriendlyFlag or ""
        end
    end
end

if remoteEvent then
    remoteEvent.OnClientEvent:Connect(function(action, info)
        if action == "UpdateCapturePointUI" then
            updateRaidUI(info)
        end
    end)
end

return updateRaidUI
