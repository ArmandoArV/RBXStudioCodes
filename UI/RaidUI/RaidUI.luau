local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataRaid = ReplicatedStorage:FindFirstChild("RaidSettings")
local tfw = require(script.Parent.tween)
local Gui = script.Parent
local MainFrame = Gui:FindFirstChild("MainFrame")
local End = Gui:FindFirstChild("endscreen")
local RS = game.ReplicatedStorage.RaidSettings
local light = game.Lighting
local marker = game.ReplicatedStorage.Markers.Terminal.Config.MarkerColor
local rueda = game.Workspace.RaidSystem.Rueda
local camera = workspace.Camera
local part = workspace.CameraPart
local terminalui = Gui:FindFirstChild("MainFrame")
local officialsound = game.Workspace.Sounds.OfficialSound
local endsound = game.Workspace.Sounds.EndSound
local EnemyName = game.Workspace.Values.EnemyName
local Player = game.Players.LocalPlayer

-- Vents Functions--
local vent1 = game.Workspace.Vents.Vent1
local vent2 = game.Workspace.Vents.Vent2
local vent3 = game.Workspace.Vents.Vent3
local vent4 = game.Workspace.Vents.Vent4
local sand1 = game.Workspace.Vents.Sand1
local sand2 = game.Workspace.Vents.Sand2

function updateUI()
    MainFrame.Bar:TweenSize(UDim2.new(0, DataRaid.TermAmount.Value / DataRaid.CaptureTime.Value * 469, 0, 19))
    MainFrame.BarShadow:TweenSize(UDim2.new(0, DataRaid.TermAmount.Value / DataRaid.CaptureTime.Value * 469, 0, 19))
    MainFrame.Bar.BackgroundColor3 = DataRaid.TermAmount.Owner.Value
    marker.Value = DataRaid.TermAmount.Owner.Value
    rueda.Color = DataRaid.TermAmount.Owner.Value
    MainFrame.timer.Text = DataRaid.TermAmount.Value .. "/" .. DataRaid.CaptureTime.Value
    MainFrame.Shadows.timershadow.Text = DataRaid.TermAmount.Value .. "/" .. DataRaid.CaptureTime.Value
    wait(.03)
end
function victory()
    print("Victory")
    Player:WaitForChild("PlayerGui").HPBar.Enabled = false
    Player:WaitForChild("PlayerGui").KillFeed.Enabled = false
    Player:WaitForChild("PlayerGui").ScreenGui.Enabled = false
    Player:WaitForChild("PlayerGui").Settings.Enabled = false
    Player:WaitForChild("PlayerGui").TeamSelector.Enabled = false
    Player:WaitForChild("PlayerGui").HUD.Interface_Weapon.Enabled = false
    game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    terminalui.Visible = false
    End.Visible = true
    endsound:Play()
    End.enemyflag.Image = game.Workspace.Values.EnemyImageUrl.Value
    End.title2.Text = game.Workspace.Values.EnemyName.Value
    End.Shadows.title2shadow.Text = End.title2.Text
    End.Code.Text = game.JobId
    End.Shadows.CodeShadow.Text = End.Code.Text
    game.StarterGui:SetCore("SendNotification", {
        Title = "TERMINAL STATUS",
        Text = "The raid is over.",
        Icon = "http://www.roblox.com/asset/?id=6682599326",
        Duration = "3",
        officialsound:Play()
    })
    tfw.tween(End.line, {
        Size = UDim2.new(1, 0, 0, 4)
    }, 1, "Quint", "Out"):Play()
    tfw.tween(End.lineshadow, {
        Size = UDim2.new(1, 0, 0, 4)
    }, 1, "Quint", "Out"):Play()
    if DataRaid.TermAmount.Owner.Value == game.Teams.MEXICO.TeamColor.Color or DataRaid.TermAmount.Owner.Value ==
        Color3.new(1, 1, 1) or DataRaid.TermAmount.Owner.Value == Color3.new(0, 0, 0) then
        End.Team.Text = "MEXICO VICTORY"
        End.Shadows.TeamShadow.Text = End.Team.Text
    elseif DataRaid.TermAmount.Owner.Value == game.Teams.INSURGENTES.TeamColor.Color then
        End.Team.Text = EnemyName.Value .. " VICTORY"
        End.Shadows.TeamShadow.Text = End.Team.Text
    end
    while true do
        wait(0)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = part.CFrame
        light.EndBlur.Enabled = true
    end
    for i, v in pairs(script.Parent.endscreen:GetChildren()) do
        if v:IsA("TextLabel") then
            tfw.tween(v, {
                TextTransparency = 0
            }, 0, "Quint", "Out"):Play()
        elseif v:IsA("ImageLabel") then
            tfw.tween(v, {
                ImageTransparency = 0
            }, 0, "Quint", "Out"):Play()
        end
    end
end
DataRaid.GameEnd.Changed:connect(function()
    print("game end changed")
    if DataRaid.GameEnd.Value == true then
        print("gameend is true")
        victory()
    end
end)
DataRaid.Official.Changed:connect(function(var)
    if var == true then
        MainFrame.official.Text = "OFFICIAL"
        MainFrame.Shadows.officialshadow.Text = "OFFICIAL"
        MainFrame.official.TextColor3 = Color3.new(0.0980392, 0.996078, 0.231373)
        officialsound:Play()
        game.StarterGui:SetCore("SendNotification", {
            Title = "TERMINAL STATUS",
            Text = "The raid has started.",
            Icon = "http://www.roblox.com/asset/?id=6682599326",
            Duration = "3"
        })
    elseif var == false then
        MainFrame.official.Text = "UNOFFICIAL"
        MainFrame.Shadows.officialshadow.Text = "UNOFFICIAL"
    end
end)
DataRaid.Mode.Changed:connect(function()
    if DataRaid.Mode.Value == 1 then
        MainFrame.mode.Text = "EASY"
        MainFrame.Shadows.modeshadow.Text = "EASY"
        officialsound:Play()
        vent1.Transparency = 1
        vent2.Transparency = 1
        vent3.Transparency = 1
        vent4.Transparency = 1
        sand1.Transparency = 0
        sand2.Transparency = 0
        sand1.CanCollide = true
        sand2.CanCollide = true
        game.StarterGui:SetCore("SendNotification", {
            Title = "TERMINAL MODE",
            Text = "Easy Mode Selected.",
            Icon = "http://www.roblox.com/asset/?id=6682599326",
            Duration = "3"
        })
    elseif DataRaid.Mode.Value == 2 then
        MainFrame.mode.Text = "NORMAL"
        MainFrame.Shadows.modeshadow.Text = "NORMAL"
        officialsound:Play()
        vent1.Transparency = 0
        vent2.Transparency = 0
        vent3.Transparency = 0
        vent4.Transparency = 0
        sand1.Transparency = 1
        sand2.Transparency = 1
        sand1.CanCollide = false
        sand2.CanCollide = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "TERMINAL MODE",
            Text = "Normal Mode Selected.",
            Icon = "http://www.roblox.com/asset/?id=6682599326",
            Duration = "3"
        })
    elseif DataRaid.Mode.Value == 3 then
        MainFrame.mode.Text = "HARD"
        MainFrame.Shadows.modeshadow.Text = "HARD"
        officialsound:Play()
        vent1.Transparency = 0
        vent2.Transparency = 0
        vent3.Transparency = 0
        vent4.Transparency = 0
        sand1.Transparency = 1
        sand2.Transparency = 1
        sand1.CanCollide = false
        sand2.CanCollide = false
        game.StarterGui:SetCore("SendNotification", {
            Title = "TERMINAL MODE",
            Text = "Hard Mode Selected.",
            Icon = "http://www.roblox.com/asset/?id=6682599326",
            Duration = "3"
        })
    end
    updateUI()
end)

DataRaid.AmbientMode.Changed:connect(function()
    if DataRaid.AmbientMode.Value == 1 then
        officialsound:Play()
        game.StarterGui:SetCore("SendNotification", {
            Title = "AMBIENT MODE",
            Text = "Night Mode Selected.",
            Icon = "http://www.roblox.com/asset/?id=6682599326",
            Duration = "3"
        })
    elseif DataRaid.AmbientMode.Value == 2 then
        officialsound:Play()
        game.StarterGui:SetCore("SendNotification", {
            Title = "AMBIENT MODE",
            Text = "Day Mode Selected.",
            Icon = "http://www.roblox.com/asset/?id=6682599326",
            Duration = "3"
        })
    end
end)

DataRaid.Counter.Changed:connect(function()
    local totalSec = DataRaid.Counter.Value
    if DataRaid.Counter.Value ~= 0 then
        local min = math.floor((totalSec / 60) % 60)
        local sec = math.floor(totalSec % 60)
        if sec < 10 then
            sec = "0" .. sec
        end
        if min < 10 then
            min = "0" .. min
        end

        local string = min .. ":" .. sec
        MainFrame.counter.Text = string
        MainFrame.Shadows.countershadow.Text = string

    else
        MainFrame.counter.Text = "OVERTIME"
        MainFrame.Shadows.countershadow.Text = "OVERTIME"
    end

    updateUI()
end)
DataRaid.Status.Changed:connect(function()
    if DataRaid.Official.Value == true then
        MainFrame.status.Text = DataRaid.Status.Value:upper()
        MainFrame.Shadows.statusshadow.Text = DataRaid.Status.Value:upper()
    end
    updateUI()
end)
DataRaid.TermAmount.Changed:connect(function()
    updateUI()
end)
DataRaid.CaptureTime.Changed:connect(function()
    updateUI()
end)
