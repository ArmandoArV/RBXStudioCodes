-- ProximityPromptModule.luau
-- A modular component for handling ProximityPrompt events and custom actions

local ProximityPromptModule = {}

-- Connects a ProximityPrompt to a custom callback
-- prompt: the ProximityPrompt instance
-- callback: function(player, prompt) to run when triggered
function ProximityPromptModule.connect(prompt, callback)
	if not prompt or not prompt:IsA("ProximityPrompt") then
		error("Invalid ProximityPrompt instance")
	end
	if type(callback) ~= "function" then
		error("Callback must be a function")
	end
	prompt.Triggered:Connect(function(player)
		callback(player, prompt)
	end)
end

return ProximityPromptModule
