-- UIManager.lua
local UIManager = {}
UIManager.__index = UIManager

local DEFAULT_BUTTON_COLOR = Color3.new(0.2, 0.2, 0.2)
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(60, 120, 180)

function UIManager.new(gangMenu)
	local self = setmetatable({}, UIManager)
	self.GangMenu = gangMenu
	self.Background = gangMenu:FindFirstChild("Background")
	if not self.Background then
		warn("[UIManager] Background not found in GangMenu!")
	end
	self.Buttons = self.Background and self.Background:FindFirstChild("Buttons") or nil
	if not self.Buttons then
		warn("[UIManager] Buttons not found in Background!")
	end
	self.Frames = self.Background and self.Background:FindFirstChild("Menu") or nil
	if not self.Frames then
		warn("[UIManager] Menu (Frames) not found in Background!")
	end
	return self
end

function UIManager:DebugPrint(...)
	print("[UIManager]", ...)
end

function UIManager:SetButtonColors(activeButton)
	if not self.Buttons then
		self:DebugPrint("Buttons container missing in SetButtonColors!")
		return
	end
	for _, btn in ipairs(self.Buttons:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.BackgroundColor3 = (btn == activeButton) and ACTIVE_BUTTON_COLOR or DEFAULT_BUTTON_COLOR
		end
	end
end

function UIManager:ShowFrame(frameToShow)
	if not self.Frames then
		self:DebugPrint("Frames container missing in ShowFrame!")
		return
	end
	for _, frame in ipairs(self.Frames:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = (frame == frameToShow)
		end
	end
end

function UIManager:SetupButtonConnections()
	self:DebugPrint("Setting up buttons...")
	if not self.Buttons then
		self:DebugPrint("Buttons container missing in SetupButtonConnections!")
		return
	end
	if not self.Frames then
		self:DebugPrint("Frames container missing in SetupButtonConnections!")
		return
	end

	local turfsBtn = self.Buttons:FindFirstChild("TURFS")
	local createBtn = self.Buttons:FindFirstChild("CREATE")
	local menuBtn = self.Buttons:FindFirstChild("MENU")

	if not turfsBtn then self:DebugPrint("TURFS button not found!") end
	if not createBtn then self:DebugPrint("CREATE button not found!") end
	if not menuBtn then self:DebugPrint("MENU button not found!") end

	if turfsBtn then
		turfsBtn.MouseButton1Click:Connect(function()
			self:DebugPrint("TURFS clicked")
			local frame = self.Frames:FindFirstChild("TURFS")
			if not frame then self:DebugPrint("TURFS frame not found!") end
			self:ShowFrame(frame)
			self:SetButtonColors(turfsBtn)
		end)
	end

	if createBtn then
		createBtn.MouseButton1Click:Connect(function()
			self:DebugPrint("CREATE clicked")
			local frame = self.Frames:FindFirstChild("CREATE")
			if not frame then self:DebugPrint("CREATE frame not found!") end
			self:ShowFrame(frame)
			self:SetButtonColors(createBtn)
		end)
	end

	if menuBtn then
		menuBtn.MouseButton1Click:Connect(function()
			self:DebugPrint("MENU clicked")
			local frame = self.Frames:FindFirstChild("JOIN")
			if not frame then self:DebugPrint("JOIN frame not found!") end
			self:ShowFrame(frame)
			self:SetButtonColors(menuBtn)
		end)
	end
end

return UIManager
