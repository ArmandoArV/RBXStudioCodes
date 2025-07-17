-- GangColorPalette.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("GetAvailableGangColors")

-- Get the available color names from the server
local availableColorsList = remote:InvokeServer()

-- Debug: Print received color names
print("[GangColorPalette] Server returned colors:")
for _, color in ipairs(availableColorsList) do
	print("- " .. color)
end

-- Create BrickColors only from valid names
local gangColors = {}
for _, colorName in ipairs(availableColorsList) do
	local success, brickColor = pcall(BrickColor.new, colorName)
	if success and brickColor then
		table.insert(gangColors, colorName)
	else
		warn("[GangColorPalette] Failed to create BrickColor for:", colorName)
	end
end

-- Debug: Final gang colors
print("[GangColorPalette] Final usable gang colors:")
for _, color in ipairs(gangColors) do
	print("- " .. color)
end

return gangColors
