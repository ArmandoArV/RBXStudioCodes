-- LeaderboardEntry.luau
-- Luau OOP class for leaderboard player entry

local LeaderboardEntry = {}
LeaderboardEntry.__index = LeaderboardEntry

function LeaderboardEntry.new(playerName, kills, deaths, ping, ui)
    local self = setmetatable({}, LeaderboardEntry)
    self.playerName = playerName
    self.kills = kills or 0
    self.deaths = deaths or 0
    self.ping = ping or 0
    self.ui = ui -- Reference to the player's UI frame
    return self
end

function LeaderboardEntry:updateKills(kills)
    self.kills = kills
    if self.ui then
        self.ui.details.lists.kills.Label.Text = tostring(kills)
    end
end

function LeaderboardEntry:updateDeaths(deaths, deathCallback)
    self.deaths = deaths
    if self.ui then
        self.ui.details.lists.deaths.Label.Text = tostring(deaths)
        if deathCallback then
            deathCallback(self.ui.basic.Died)
        end
    end
end

function LeaderboardEntry:updatePing(ping, tweenService)
    self.ping = ping
    if not self.ui then
        warn("[LeaderboardEntry] updatePing: UI reference is nil")
        return
    end
    
    local targetui = self.ui
    
    -- Check if details structure exists
    if not targetui:FindFirstChild("details") then
        warn("[LeaderboardEntry] updatePing: details not found in UI")
        return
    end
    
    local details = targetui.details
    if not details:FindFirstChild("lists") then
        warn("[LeaderboardEntry] updatePing: lists not found in details")
        return
    end
    
    local lists = details.lists
    if not lists:FindFirstChild("ping") then
        warn("[LeaderboardEntry] updatePing: ping not found in lists")
        return
    end
    
    local pingElement = lists.ping
    if not pingElement:FindFirstChild("Label") then
        warn("[LeaderboardEntry] updatePing: Label not found in ping element")
        return
    end
    
    pingElement.Label.Text = tostring(ping) .. "ms"
    
    -- Apply styling based on ping value
    if ping <= 70 then
        pingElement.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        pingElement.Label.TextColor3 = Color3.fromRGB(67, 200, 98)
        if pingElement:FindFirstChild("IconImage") then
            pingElement.IconImage.Image = "rbxassetid://98966243978296"
        end
        if targetui:FindFirstChild("basic") and targetui.basic:FindFirstChild("userdata") and targetui.basic.userdata:FindFirstChild("Ping") then
            targetui.basic.userdata.Ping.Image = "rbxassetid://98966243978296"
        end
        if pingElement:FindFirstChild("UIStroke") and tweenService then
            tweenService:Create(pingElement.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play()
        end
    elseif ping <= 100 then
        pingElement.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        pingElement.Label.TextColor3 = Color3.fromRGB(67, 200, 98)
        if pingElement:FindFirstChild("IconImage") then
            pingElement.IconImage.Image = "rbxassetid://80192110147601"
        end
        if targetui:FindFirstChild("basic") and targetui.basic:FindFirstChild("userdata") and targetui.basic.userdata:FindFirstChild("Ping") then
            targetui.basic.userdata.Ping.Image = "rbxassetid://80192110147601"
        end
        if pingElement:FindFirstChild("UIStroke") and tweenService then
            tweenService:Create(pingElement.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play()
        end
    elseif ping <= 200 then
        pingElement.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        pingElement.Label.TextColor3 = Color3.fromRGB(221, 147, 0)
        if pingElement:FindFirstChild("IconImage") then
            pingElement.IconImage.Image = "rbxassetid://122030464744415"
        end
        if targetui:FindFirstChild("basic") and targetui.basic:FindFirstChild("userdata") and targetui.basic.userdata:FindFirstChild("Ping") then
            targetui.basic.userdata.Ping.Image = "rbxassetid://122030464744415"
        end
        if pingElement:FindFirstChild("UIStroke") and tweenService then
            tweenService:Create(pingElement.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play()
        end
    elseif ping <= 350 then
        pingElement.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        pingElement.Label.TextColor3 = Color3.fromRGB(221, 147, 0)
        if pingElement:FindFirstChild("IconImage") then
            pingElement.IconImage.Image = "rbxassetid://82323767111213"
        end
        if targetui:FindFirstChild("basic") and targetui.basic:FindFirstChild("userdata") and targetui.basic.userdata:FindFirstChild("Ping") then
            targetui.basic.userdata.Ping.Image = "rbxassetid://82323767111213"
        end
        if pingElement:FindFirstChild("UIStroke") and tweenService then
            tweenService:Create(pingElement.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play()
        end
    elseif ping > 500 then
        pingElement.BackgroundColor3 = Color3.fromRGB(84, 0, 0)
        pingElement.Label.TextColor3 = Color3.fromRGB(168, 57, 59)
        if pingElement:FindFirstChild("IconImage") then
            pingElement.IconImage.Image = "rbxassetid://110435949761986"
        end
        if targetui:FindFirstChild("basic") and targetui.basic:FindFirstChild("userdata") and targetui.basic.userdata:FindFirstChild("Ping") then
            targetui.basic.userdata.Ping.Image = "rbxassetid://110435949761986"
        end
        if pingElement:FindFirstChild("UIStroke") and tweenService then
            tweenService:Create(pingElement.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 3
            }):Play()
        end
    end
end

return LeaderboardEntry
