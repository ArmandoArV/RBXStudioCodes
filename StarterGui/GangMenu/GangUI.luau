local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GangMenu = script.Parent

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

print("PRINT TEST", Modules:WaitForChild("UIManager")) -- Should print the ModuleScript

local gangCreation = GangCreation.new(uiManager.Frames, GangRemoteEvent, debugPrint)
local gangJoining = GangJoining.new(uiManager.Frames, GangRemoteEvent, debugPrint)
local turfsUI = TurfsUI.new(uiManager.Frames, debugPrint)

gangCreation:Setup()

uiManager:SetupButtonConnections()

GangRemoteEvent.OnClientEvent:Connect(function(eventType, data)
	debugPrint("Server event:", eventType, data)
	if eventType == "GangCreated" or eventType == "GangJoined" then
		debugPrint("Success:", eventType)
		GangMenu.Visible = false
		player:LoadCharacter()
	elseif eventType:find("Failed") then
		debugPrint("Failed:", data)
		local JOINFrame = uiManager.Frames.JOIN
		if JOINFrame and JOINFrame:FindFirstChild("Status") then
			JOINFrame.Status.Text = data or "Unknown error"
		end
	elseif eventType == "RefreshGangList" then
		debugPrint("Refreshing gang list")
		-- you can add refresh logic here
	end
end)

-- Override showFrame to populate Turfs when TURFS frame shows
local oldShowFrame = uiManager.ShowFrame
function uiManager:ShowFrame(frameToShow)
	oldShowFrame(self, frameToShow)
	if frameToShow == self.Frames:FindFirstChild("TURFS") then
		turfsUI:PopulateTurfsUI()
	end
end

debugPrint("Gang system client initialized")
