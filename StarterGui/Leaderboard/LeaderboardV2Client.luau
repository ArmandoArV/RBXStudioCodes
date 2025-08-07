local starterGui = game:GetService("StarterGui")
starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
local rem = game.ReplicatedStorage:WaitForChild("ldbrdchng")
local tweenService = game:GetService("TweenService")
local Event = game.ReplicatedStorage.GunEngineAssets.KillLogFolder.KillLog
local player = game.Players.LocalPlayer
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local teams = game:GetService("Teams")
local userInputService = game:GetService("UserInputService")

local screenGui = script:FindFirstAncestorWhichIsA("ScreenGui")
local ui = screenGui.Ui.Holder
local config = require(screenGui.Config.Config)
local groups = require(screenGui.Config.GroupIcons)
local LeaderboardEntry = require(script.Parent.Classes.LeaderboardEntry)

screenGui.Enabled = true
local teamFrame = screenGui.Template.Team:Clone()
local playerFrame = screenGui.Template.Player:Clone()
local teamstable = {}
local layoutOrder = 0
local list = screenGui.Ui.Holder.Main.ListHold

-- Data structure to hold leaderboard entries
local leaderboardEntries = {}

uis = game:GetService("UserInputService")
ismobile = uis.TouchEnabled 
if ismobile then
	ui.Main.Size = UDim2.new(0.296, 0,0.602, 0)
end

--Event.OnClientEvent:Connect(function()
--	rem:FireServer("kill")
--end)
local UserInputService = game:GetService("UserInputService")
local hidden = false
UserInputService.InputBegan:Connect(function(input,gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Tab then
		if hidden == false then
			hidden = true
			ui.Main:TweenPosition(UDim2.new(1.2, 0,0.01, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
			task.wait(0.301)
			if ui.Main.Position == UDim2.new(1.2, 0,0.01, 0) then ui.Main.Visible = false else ui.Main.Visible = true end
		else
			hidden = false
			ui.Main.Visible = true
			ui.Main:TweenPosition(UDim2.new(0.995, 0,0.01, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
		end
	end
end)
--local hidebutton = ui.Parent.BarHold.Button
--hidebutton.MouseButton1Click:Connect(function()
--	if hidden == false then
--		hidebutton.Visible = false
--		ui.Main:TweenPosition(UDim2.new(1.181, 0,0.01, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
--		task.wait(0.3)
--		ui.Parent.Barhold:TweenSize(UDim2.new(1,0,0.078,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.3,true)
--	else
--		hidden = false
--		ui.Main:TweenPosition(UDim2.new(0.995, 0,0.01, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true)
--	end
--end)
if player.Name ~= "sti_bie" or player.Name~="Sr_IP" then
	ui.Main.Restart.Visible = false
else
	ui.Main.Restart.Visible = true
	ui.Main.Restart.Toggle.MouseButton1Click:Connect(function()
		local event = game:GetService("ReplicatedStorage"):FindFirstChild("LeaderboardEvent")
		if not event then
			warn("[CLIENT] LeaderboardEvent not found in workspace!")
			return
		end
		event:FireServer("Restart")
		--print("Sent request to restart leaderboard")
		ui.Main.Restart.Visible = false
		task.wait(5)
		ui.Main.Restart.Visible = true
	end)
end
local function death(ui)
	local tween = tweenService:Create(ui,TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 0}) tween:Play()
	local tween = tweenService:Create(ui.ImageLabel,TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 0}) tween:Play()
	ui.ImageLabel:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.5,true)
	task.wait(5)
	local tween = tweenService:Create(ui,TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}) tween:Play()
	task.wait(0.25)
	local tween = tweenService:Create(ui.ImageLabel,TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}) tween:Play()
	ui.ImageLabel:TweenPosition(UDim2.new(1,0,0.5,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,0.5,true)
	task.wait(0.51)
	ui.ImageLabel:TweenPosition(UDim2.new(0.35,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0,true)
end
rem.OnClientEvent:Connect(function(password,target,thing1)
	-- Find or create leaderboard entry
	local entry = leaderboardEntries[target]
	local targetui = list:FindFirstChild(target)
	if not targetui then
		warn("[CLIENT] Could not find [".. target .."] in playerlist!!")
		targetui = list:WaitForChild(target)
	end
	if not entry then
		entry = LeaderboardEntry.new(target, 0, 0, 0, targetui)
		leaderboardEntries[target] = entry
	end

	if password == "20478x04783v" then
		local Ping = tonumber(thing1)
		entry:updatePing(Ping, tweenService)
	elseif password == "dajhs8912pdj11" then
		entry:updateKills(thing1)
	elseif password == "qwdu123oejf" then
		entry:updateDeaths(thing1, death)
	end
end)