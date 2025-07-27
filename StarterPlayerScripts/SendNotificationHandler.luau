local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sendNotification = ReplicatedStorage:WaitForChild("SendNotification")

local notiS = script.Notification

sendNotification.OnClientEvent:Connect(function(data)
	game.StarterGui:SetCore("SendNotification", {
		Title = data.Title or "",
		Text = data.Text or "",
		Icon = data.Icon or "",
		Duration = data.Duration or 3
	})
	
	notiS:Play()
end)