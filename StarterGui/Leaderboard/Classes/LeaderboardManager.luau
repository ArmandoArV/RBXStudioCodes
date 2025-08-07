-- LeaderboardManager.luau
-- Manages all leaderboard logic

local LeaderboardManager = {}
LeaderboardManager.__index = LeaderboardManager

function LeaderboardManager.new()
    local self = setmetatable({}, LeaderboardManager)
    self.teams = {}
    self.players = {}
    return self
end

function LeaderboardManager:addTeam(teamEntry)
    self.teams[teamEntry.teamName] = teamEntry
end

function LeaderboardManager:addPlayer(playerEntry)
    self.players[playerEntry.player.Name] = playerEntry
    if playerEntry.team and self.teams[playerEntry.team] then
        self.teams[playerEntry.team]:addPlayer(playerEntry)
    end
end

function LeaderboardManager:removePlayer(playerName)
    local entry = self.players[playerName]
    if entry and entry.team and self.teams[entry.team] then
        self.teams[entry.team]:removePlayer(playerName)
    end
    self.players[playerName] = nil
end

function LeaderboardManager:getPlayer(playerName)
    return self.players[playerName]
end

function LeaderboardManager:getTeam(teamName)
    return self.teams[teamName]
end

return LeaderboardManager
