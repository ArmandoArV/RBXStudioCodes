-- TurfsUI.lua
local TurfsUI = {}
TurfsUI.__index = TurfsUI

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("GUIs").TeamFrame.Config.Frame:WaitForChild("Gangs")
local Frames = Background
local template = Frames:FindFirstChild("TURFS"):FindFirstChild("FrameToDuplicate"):Clone()
local DEBUG_PREFIX = "[TurfsUI]"

-- Internal debug print
local function defaultDebugPrint(...)
	print(DEBUG_PREFIX, ...)
end

-- Constructor
function TurfsUI.new(frames, debugPrint)
	local self = setmetatable({}, TurfsUI)
	self.Frames = frames
	self.DebugPrint = debugPrint or defaultDebugPrint
	return self
end

-- Correctly named method
function TurfsUI:PopulateTurfsUI()
	local TurfsFrame = self.Frames:FindFirstChild("TURFS")
	if not TurfsFrame then
		warn("[TurfsUI] No TURFS frame found")
		return
	end

	local BackgroundFrame = TurfsFrame
	if not BackgroundFrame then
		warn("[TurfsUI] No Background in TURFS frame")
		return
	end

	if not BackgroundFrame:IsA("ScrollingFrame") then
		warn("[TurfsUI] Background is not a ScrollingFrame! Fix in Studio.")
	end
	
	if not template then
		warn("[TurfsUI] FrameToDuplicate not found")
		return
	end
	-- Clear old rows
	for _, child in ipairs(BackgroundFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local layout = BackgroundFrame:FindFirstChildOfClass("UIListLayout")
	--if not layout then
	--	layout = Instance.new("UIListLayout")
	--	layout.Parent = BackgroundFrame
	--	layout.SortOrder = Enum.SortOrder.LayoutOrder
	--	layout.Padding = UDim.new(0, 6)
	--end
	-- Get CapturePoints
	local folder = ReplicatedStorage:WaitForChild("CapturePoints")
	local capturePoints = folder:GetChildren()

	self.DebugPrint("Found capture points:", #capturePoints)


	local rowCount = 0
	for _, cpFolder in ipairs(capturePoints) do
		local name = cpFolder.Name
		local location = cpFolder:FindFirstChild("Location") and cpFolder.Location.Value or "?"
		local occupied = cpFolder:FindFirstChild("Occupied") and cpFolder.Occupied.Value or false
		local team = cpFolder:FindFirstChild("Team") and cpFolder.Team.Value or "None"

		local row = template:Clone()
		row.Name = name .. "Row"
		row.Visible = true
		row.Parent = BackgroundFrame

		local ownedBox = row:FindFirstChild("Owned")
		local payTitleBox = row:FindFirstChild("Pay")

		if ownedBox and ownedBox:IsA("TextLabel") then
			ownedBox.Text = (team ~= "None") and team or "Unoccupied"
		else
			warn("[TurfsUI] Owned TextBox missing in row", row.Name)
		end

		if payTitleBox and payTitleBox:IsA("TextLabel") then
			payTitleBox.Text = "Location: " .. location .. " | Occupied: " .. tostring(occupied)
		else
			warn("[TurfsUI] PayTitle TextBox missing in row", row.Name)
		end

		rowCount += 1
	end

	if BackgroundFrame:IsA("ScrollingFrame") and layout then
		BackgroundFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end

	self.DebugPrint("Total rows created:", rowCount)
end

return TurfsUI
