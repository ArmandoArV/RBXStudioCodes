-- UIManager.lua
local UIManager = {}
UIManager.__index = UIManager

local DEFAULT_BUTTON_COLOR = Color3.new(0.2, 0.2, 0.2)
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(60, 120, 180)

function UIManager.new(gangMenu)
	local self = setmetatable({}, UIManager)
	self.GangMenu = gangMenu
	self.Background = gangMenu:WaitForChild("Background")
	self.Buttons = self.Background:WaitForChild("Buttons")
	self.Frames = self.Background:WaitForChild("Menu")
	return self
end

function UIManager:DebugPrint(...)
	print("[UIManager]", ...)
end

function UIManager:SetButtonColors(activeButton)
	for _, btn in ipairs(self.Buttons:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.BackgroundColor3 = (btn == activeButton) and ACTIVE_BUTTON_COLOR or DEFAULT_BUTTON_COLOR
		end
	end
end

function UIManager:ShowFrame(frameToShow)
	for _, frame in ipairs(self.Frames:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = (frame == frameToShow)
		end
	end
end

function UIManager:SetupButtonConnections()
	self:DebugPrint("Setting up buttons...")

	local turfsBtn = self.Buttons:FindFirstChild("TURFS")
	local createBtn = self.Buttons:FindFirstChild("CREATE")
	local menuBtn = self.Buttons:FindFirstChild("MENU")

	if turfsBtn then
		turfsBtn.MouseButton1Click:Connect(function()
			self:DebugPrint("TURFS clicked")
			self:ShowFrame(self.Frames:FindFirstChild("TURFS"))
			self:SetButtonColors(turfsBtn)
		end)
	end

	if createBtn then
		createBtn.MouseButton1Click:Connect(function()
			self:DebugPrint("CREATE clicked")
			self:ShowFrame(self.Frames:FindFirstChild("CREATE"))
			self:SetButtonColors(createBtn)
		end)
	end

	if menuBtn then
		menuBtn.MouseButton1Click:Connect(function()
			self:DebugPrint("MENU clicked")
			self:ShowFrame(self.Frames:FindFirstChild("JOIN"))
			self:SetButtonColors(menuBtn)
		end)
	end
end

return UIManager
