--[[

ADMIN POWERS

0		Player
1		VIP/Donor
2		Moderator
3		Administrator
4		Super Administrator
5		Owner
6		Game Creator

First table consists of the different variations of the command.

Second table consists of the description and an example of how to use it.

Third index is the ADMIN POWER required to use the command.

Fourth table consists of the arguments that will be returned in the args table.
'player'	-- returns an array of Players
'userid'	-- returns an array of userIds
'boolean'	-- returns a Boolean value
'color'		-- returns a Color3 value
'number'	-- returns a Number value
'string'	-- returns a String value
'time'		-- returns # of seconds
'banned'	-- returns a value from Bans table
'admin'		-- returns a value from Admins table
-- Adding / to any argument will make it optional; can return nil!!!

Fifth index consists of the function that will run when the command is executed properly.	]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaidSettings = require(ReplicatedStorage:WaitForChild("Service"):WaitForChild("RaidSettingsModule"))
local ChatEvent = ReplicatedStorage:FindFirstChild("ChatEvent")
local grp = game:GetService("GroupService")
local lighting = game:GetService("Lighting")
local CurrentDefenders = 0
local CurrentRaiders = 0
local DefenderLimit = 999
local RaiderLimit = 999
local defenderlocked = false
local raiderlocked = false
local Players = game.Players

local initialMessage = false
local ServerHistroy = {}
local CapturePointTerminalHandler = require(game.ServerScriptService.Handler:WaitForChild("CapturePointTerminalHandler"))
return {

	{{'official', 'start'}, {'Run this command to make the raid official and reset capture points.'}, 3, {}, function(pl, args)
		RaidSettings.Official = true
		for i, plr in pairs(Players:GetPlayers()) do
			plr:LoadCharacter()
		end
		if CapturePointTerminalHandler.ResetCapturePoints then
			CapturePointTerminalHandler:ResetCapturePoints()
		end
		return "Raid is now official. Capture points have been reset."
	end},

	{{'easy', 'emode'}, {'Run this command to select easy mode for all capture points.'}, 3, {}, function(pl, args)
	RaidSettings.Rollback = 2
	RaidSettings.CaptureTime = 1200
	RaidSettings.Mode = 1
		local folder = workspace:FindFirstChild("CapturePoint")
		if folder then
			for _, part in ipairs(folder:GetChildren()) do
				CapturePointTerminalHandler:AddCapturePointFromPart(part, "Easy")
			end
		end
		return "All capture points set to Easy mode."
	end},

	{{'normal', 'nmode'}, {'Run this command to select normal mode for all capture points.'}, 3, {}, function(pl, args)
	RaidSettings.Rollback = 3
	RaidSettings.CaptureTime = 1500
	RaidSettings.Mode = 2
		local folder = workspace:FindFirstChild("CapturePoint")
		if folder then
			for _, part in ipairs(folder:GetChildren()) do
				CapturePointTerminalHandler:AddCapturePointFromPart(part, "Medium")
			end
		end
		return "All capture points set to Medium mode."
	end},

	{{'hard', 'hmode'}, {'Run this command to select hard mode for all capture points.'}, 3, {}, function(pl, args)
	RaidSettings.Rollback = 0
	RaidSettings.CaptureTime = 2000
	RaidSettings.Mode = 3
		local folder = workspace:FindFirstChild("CapturePoint")
		if folder then
			for _, part in ipairs(folder:GetChildren()) do
				CapturePointTerminalHandler:AddCapturePointFromPart(part, "Hard")
			end
		end
		return "All capture points set to Hard mode."
	end},

};