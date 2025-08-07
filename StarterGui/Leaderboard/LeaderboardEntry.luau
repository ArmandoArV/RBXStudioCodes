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
    if self.ui then
        local targetui = self.ui
        targetui.details.lists.ping.Label.Text = tostring(ping) .. "ms"
        if ping <= 70 then
            targetui.details.lists.ping.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            targetui.details.lists.ping.Label.TextColor3 = Color3.fromRGB(67, 200, 98)
            targetui.details.lists.ping.IconImage.Image = "rbxassetid://98966243978296"
            targetui.basic.userdata.Ping.Image = "rbxassetid://98966243978296"
            tweenService:Create(targetui.details.lists.ping.UIStroke,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play();
        elseif ping <= 100 then
            targetui.details.lists.ping.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            targetui.details.lists.ping.Label.TextColor3 = Color3.fromRGB(67, 200, 98)
            targetui.details.lists.ping.IconImage.Image = "rbxassetid://80192110147601"
            targetui.basic.userdata.Ping.Image = "rbxassetid://80192110147601"
            tweenService:Create(targetui.details.lists.ping.UIStroke,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play();
        elseif ping <= 200 then
            targetui.details.lists.ping.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            targetui.details.lists.ping.Label.TextColor3 = Color3.fromRGB(221, 147, 0)
            targetui.details.lists.ping.IconImage.Image = "rbxassetid://122030464744415"
            targetui.basic.userdata.Ping.Image = "rbxassetid://122030464744415"
            tweenService:Create(targetui.details.lists.ping.UIStroke,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play();
        elseif ping <= 350 then
            targetui.details.lists.ping.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            targetui.details.lists.ping.Label.TextColor3 = Color3.fromRGB(221, 147, 0)
            targetui.details.lists.ping.IconImage.Image = "rbxassetid://82323767111213"
            targetui.basic.userdata.Ping.Image = "rbxassetid://82323767111213"
            tweenService:Create(targetui.details.lists.ping.UIStroke,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 0
            }):Play();
        elseif ping > 500 then
            targetui.details.lists.ping.BackgroundColor3 = Color3.fromRGB(84, 0, 0)
            targetui.details.lists.ping.Label.TextColor3 = Color3.fromRGB(168, 57, 59)
            targetui.details.lists.ping.IconImage.Image = "rbxassetid://110435949761986"
            targetui.basic.userdata.Ping.Image = "rbxassetid://110435949761986"
            tweenService:Create(targetui.details.lists.ping.UIStroke,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 3
            }):Play();
        end
    end
end

return LeaderboardEntry
