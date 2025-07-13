
-- Returns a list of BrickColor names for gang creation UI, excluding those used in GroupIds
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("GetExcludedGangColors")
local excludedColorsList = remote:InvokeServer()

local excludedColors = {}
for _, colorName in ipairs(excludedColorsList) do
	excludedColors[colorName] = true
end

local allColors = {
	"Bright red", "Bright blue", "Bright yellow", "Bright green", "Black", "White", "Medium stone grey",
	"Dark stone grey", "Really red", "Really blue", "Really black", "Really white", "Bright orange",
	"Bright violet", "Bright yellowish green", "Bright bluish green", "Bright pink", "Bright purple"
}

local gangColors = {}
for _, colorName in ipairs(allColors) do
	if not excludedColors[colorName] then
		table.insert(gangColors, colorName)
	end
end

return gangColors
