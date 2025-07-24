local GangCreation = {}
GangCreation.__index = GangCreation
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local GangMenu = script.Parent.Parent
local Background = GangMenu:WaitForChild("GUIs").TeamFrame.Config.Frame:WaitForChild("Gangs")
local Frames = Background

local DEBUG_PREFIX = "[GangCreation]"
local GangRemoteEvent = ReplicatedStorage:WaitForChild("GangRemoteEvent")

local selectedBrickColor = nil

local function debugPrint(...)
	print(DEBUG_PREFIX, ...)
end

local populateAvailableColors

function GangCreation.new(frames, remoteEvent, debugPrint)
	local self = setmetatable({}, GangCreation)

	self.Frames = frames
	self.RemoteEvent = remoteEvent
	self.DebugPrint = debugPrint
	return self
end

function GangCreation:Setup(uiManager)
	local CREATEFrame = self.Frames:WaitForChild("CREATE")
	local groupIdInput = CREATEFrame:WaitForChild("ID")
	local groupImg = CREATEFrame:WaitForChild("IMG")
	local groupName = groupImg:WaitForChild("GroupName")
	local createButton = CREATEFrame:WaitForChild("Create")
	local availableColors = CREATEFrame:WaitForChild("AvailableColors")

	local colorStatusLabel = CREATEFrame:FindFirstChild("ColourDisplay")
	--if not colorStatusLabel then
	--	colorStatusLabel = Instance.new("TextLabel")
	--	colorStatusLabel.Name = "ColorStatus"
	--	colorStatusLabel.Parent = CREATEFrame
	--	colorStatusLabel.Text = ""
	--	colorStatusLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
	--	colorStatusLabel.TextSize = 14
	--	colorStatusLabel.BackgroundTransparency = 1
	--	colorStatusLabel.Size = UDim2.new(1, 0, 0, 20)
	--	colorStatusLabel.Position = UDim2.new(0, 0, 1, 5)
	--end

	local function createColorButton(brickColor)
		local btn = script.colorTemplate:Clone()
		btn.BackgroundColor3 = brickColor.Color
		btn.MouseButton1Click:Connect(function()
			selectedBrickColor = brickColor
			self.DebugPrint("Selected BrickColor:", brickColor.Name)
			colorStatusLabel.BackgroundColor3 = brickColor.Color
			--populateAvailableColors()
		end)

		return btn
	end

	populateAvailableColors = function()
		self.DebugPrint("Populating available colors")

		for _,i in pairs(availableColors:GetChildren()) do
			if i:IsA("Frame") or i:IsA("ImageButton") then i:Destroy() end
		end
		if not availableColors:IsA("ScrollingFrame") then
			warn("AvailableColors is not a ScrollingFrame! Please fix this in Studio.")
		end
		local uiListLayout = availableColors:FindFirstChildOfClass("UIListLayout")
		--if not uiListLayout then
		--	uiListLayout = Instance.new("UIListLayout")
		--	uiListLayout.Parent = availableColors
		--	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		--	uiListLayout.Padding = UDim.new(0, 4)
		--end
		local excludedColors = {}
		task.wait(0.5)
		local success1, reservedResult = pcall(function()
			return ReplicatedStorage:WaitForChild("GetExcludedGangColors"):InvokeServer()
		end)
		local success2, takenResult = pcall(function()
			return ReplicatedStorage:WaitForChild("GetTakenGangColors"):InvokeServer()
		end)
		if success1 and type(reservedResult) == "table" then
			for _, colorName in ipairs(reservedResult) do
				excludedColors[colorName] = true
			end
		end
		if success2 and type(takenResult) == "table" then
			for _, colorName in ipairs(takenResult) do
				excludedColors[colorName] = true
			end
		end
		local GangColorPalette = require(ReplicatedStorage:WaitForChild("UI"):WaitForChild("GangColorPalette"))
		local visibleIndex = 1
		for _, name in ipairs(GangColorPalette) do
			if not excludedColors[name] and (not selectedBrickColor or selectedBrickColor.Name ~= name) then
				local success, bc = pcall(BrickColor.new, name)
				if success and bc then
					local btn = createColorButton(bc)
					btn.LayoutOrder = visibleIndex
					btn.Parent = availableColors
					btn.Visible = true
					visibleIndex = visibleIndex + 1
				else
					warn("Invalid BrickColor name:", name)
				end
			end
		end

		task.wait(0.1)
		--availableColors.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
		self.DebugPrint("AvailableColors count after populate:", #availableColors:GetChildren())
	end

	local function validateGroupId(id)
		local idNum = tonumber(id)
		if not idNum then
			return false
		end

		local success, result = pcall(function()
			return ReplicatedStorage:WaitForChild("GetGroupName"):InvokeServer(idNum)
		end)

		if success and result then
			groupImg.Image = "rbxthumb://type=GroupIcon&id=" .. idNum .. "&w=150&h=150"
			groupName.Text = result
			return true
		else
			groupImg.Image = ""
			groupName.Text = "Invalid Group ID"
			return false
		end
	end

	groupIdInput.FocusLost:Connect(function(enterPressed)
		validateGroupId(groupIdInput.Text)
	end)

	createButton.Toggle.MouseButton1Click:Connect(function()
		self.DebugPrint("Create button clicked")

		local groupId = tonumber(groupIdInput.Text)
		local name = groupName.Text

		if not groupId or name == "" or name == "Invalid Group ID" or not selectedBrickColor then
			self.DebugPrint("Validation failed - Missing fields")
			createButton.Label.Text = "Please fill all fields and select a color."
			return
		end

		local colorName = selectedBrickColor.Name
		local excludedColors = {}
		local success, result = pcall(function()
			return ReplicatedStorage:WaitForChild("GetExcludedGangColors"):InvokeServer()
		end)
		if success and type(result) == "table" then
			for _, exColor in ipairs(result) do
				excludedColors[exColor] = true
			end
		end
		if excludedColors[colorName] then
			self.DebugPrint("Color is taken!")
			createButton.Label.Text = "Color is already taken. Please select another."
			return
		end

		createButton.Label.Text = "CREANDO..."
		local colorData = selectedBrickColor.Color
		self.DebugPrint("Creating gang:", name, "Group ID:", groupId, "Color:", colorData)

		self.RemoteEvent:FireServer("CreateGang", {
			name = name,
			groupId = groupId,
			color = {
				r = colorData.R,
				g = colorData.G,
				b = colorData.B
			}
		})
	end)

	populateAvailableColors()
end

return GangCreation
