-- GangUI.luau (localscriptt)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local GangMenu = playerGui:WaitForChild("GangMenu")

local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

local Modules = GangMenu:WaitForChild("Modules")
local UIManager = require(Modules:WaitForChild("UIManager"))
local GangCreation = require(Modules:WaitForChild("GangCreation"))
local GangJoining = require(Modules:WaitForChild("GangJoining"))
local TurfsUI = require(Modules:WaitForChild("TurfsUI"))

local uiManager = UIManager.new(GangMenu)

local function debugPrint(...)
	uiManager:DebugPrint(...)
end

-- GangUI.luau
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GangMenu = playerGui:WaitForChild("GangMenu")
local Modules = GangMenu:WaitForChild("Modules")
local UIManager = require(Modules:WaitForChild("UIManager"))

local uiManager = UIManager.new(GangMenu)

print("GangUI loaded for player:", player.Name)

uiManager:SetupButtonConnections()

-- Optional: show default frame
uiManager:ShowFrame(uiManager.Frames:FindFirstChild("JOIN"))


-- Initialize submodules
local gangCreation = GangCreation.new(uiManager.Frames, GangRemoteEvent, debugPrint)
local gangJoining = GangJoining.new(uiManager.Frames, GangRemoteEvent, debugPrint)
local turfsUI = TurfsUI.new(uiManager.Frames, debugPrint)

gangCreation:Setup()
uiManager:SetupButtonConnections()

-- Override ShowFrame to populate TURFS
local oldShowFrame = uiManager.ShowFrame
function uiManager:ShowFrame(frameToShow)
	oldShowFrame(self, frameToShow)
	if frameToShow == self.Frames:FindFirstChild("TURFS") then
		turfsUI:PopulateTurfsUI()
	end
end

-- Handle remote events
GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
	debugPrint("Server event:", eventType, data)

	if eventType == "GangCreated" or eventType == "GangJoined" then
		debugPrint("Success:", eventType)
		GangMenu.Visible = false
		player:LoadCharacter()
	elseif eventType:find("Failed") then
		debugPrint("Failed:", data)
		local joinFrame = uiManager.Frames:FindFirstChild("JOIN")
		if joinFrame and joinFrame:FindFirstChild("Status") then
			joinFrame.Status.Text = data or "Unknown error"
		end
	elseif eventType == "RefreshGangList" then
		debugPrint("Refreshing gang list")
	end
end)

debugPrint("Gang system client initialized")
