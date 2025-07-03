--[[

ADMIN POWERS

0		Player
1		VIP/Donor
2		Moderator
3		Administrator
4		Super Administrator
5		Owner
6		Game Creator

First table consists of the different variations of the command.

Second table consists of the description and an example of how to use it.

Third index is the ADMIN POWER required to use the command.

Fourth table consists of the arguments that will be returned in the args table.
'player'	-- returns an array of Players
'userid'	-- returns an array of userIds
'boolean'	-- returns a Boolean value
'color'		-- returns a Color3 value
'number'	-- returns a Number value
'string'	-- returns a String value
'time'		-- returns # of seconds
'banned'	-- returns a value from Bans table
'admin'		-- returns a value from Admins table
-- Adding / to any argument will make it optional; can return nil!!!

Fifth index consists of the function that will run when the command is executed properly.	]] local PodiumManager =
    require(game.ServerScriptService.Manager.PodiumManager)
local podiumsFolder = workspace.Podiums
local manager = PodiumManager.new(podiumsFolder)

-- Track which podium each player has claimed
local playerClaims = {}

local function setWallsCollide(podium, canCollide)
    local walls = podium.Model:FindFirstChild("Walls")
    if walls then
        for _, part in ipairs(walls:GetChildren()) do
            if part:IsA("BasePart") and part.Name == "Invisible" then
                part.CanCollide = canCollide
            end
        end
    end
end

local function setBeamColor(podium, color)
    local walls = podium.Model:FindFirstChild("Walls")
    if walls then
        for _, part in ipairs(walls:GetChildren()) do
            if part:IsA("BasePart") and part.Name == "Beam" then
                part.Beam.Color = ColorSequence.new(color)
            end
        end
    end
end

-- Auto-unclaim on player leave
game.Players.PlayerRemoving:Connect(function(player)
    for _, podium in pairs(manager.Podiums) do
        if podium.Owner == player.Name then
            podium.Owner = ""
            podium.Model.Owner.Value = ""
            podium:Close()
            setWallsCollide(podium, true)
            setBeamColor(podium, ColorSequence.c)
        end
    end
    playerClaims[player.UserId] = nil
end)

return { -- Claim command
{{'claim'}, {'Claim a podium by ID.', 'Usage: claim <id>'}, 2, {'number'}, function(pl, args)
    local podiumId = tonumber(args[1])
    if not podiumId then
        return "Invalid arguments. Usage: claim <id>"
    end

    -- Only allow one claim per player
    for _, claimedId in pairs(playerClaims) do
        if claimedId == pl.UserId then
            return "You have already claimed a podium."
        end
    end

    local podium = manager:GetPodiumById(podiumId)
    if not podium then
        return "Podium with ID " .. podiumId .. " does not exist."
    end

    if podium.Owner and podium.Owner ~= "" then
        return "Podium is already claimed by " .. podium.Owner .. "."
    end

    podium.Owner = pl.Name
    podium.Model.Owner.Value = pl.Name
    playerClaims[pl.UserId] = podiumId
    podium:Open()
    setWallsCollide(podium, false)
    return "You have claimed Podium " .. podiumId .. "."
end}, -- Unclaim command
{{'unclaim'}, {'Release your claimed podium.', 'Usage: unclaim'}, 2, {}, function(pl, args)
    local podiumId = playerClaims[pl.UserId]
    if not podiumId then
        return "You have not claimed any podium."
    end

    local podium = manager:GetPodiumById(podiumId)
    if not podium or podium.Owner ~= pl.Name then
        playerClaims[pl.UserId] = nil
        return "You do not own the claimed podium."
    end

    podium.Owner = ""
    podium.Model.Owner.Value = ""
    playerClaims[pl.UserId] = nil
    podium:Close()
    setWallsCollide(podium, true)
    return "You have released Podium " .. podiumId .. "."
end}, -- Open command
{{'open'}, {'Open your claimed podium (walls become non-collidable).', 'Usage: open'}, 2, {}, function(pl, args)
    local podiumId = playerClaims[pl.UserId]
    if not podiumId then
        return "You have not claimed any podium."
    end

    local podium = manager:GetPodiumById(podiumId)
    if not podium or podium.Owner ~= pl.Name then
        return "You do not own the claimed podium."
    end

    podium:Open()
    setWallsCollide(podium, false)
    return "You have opened Podium " .. podiumId .. "."
end}, -- Close command
{{'close'}, {'Close your claimed podium (walls become collidable).', 'Usage: close'}, 2, {}, function(pl, args)
    local podiumId = playerClaims[pl.UserId]
    if not podiumId then
        return "You have not claimed any podium."
    end

    local podium = manager:GetPodiumById(podiumId)
    if not podium or podium.Owner ~= pl.Name then
        return "You do not own the claimed podium."
    end

    podium:Close()
    setWallsCollide(podium, true)
    return "You have closed Podium " .. podiumId .. "."
end}, -- Unclaim all command (admin power 4)
{{'unclaimall'}, {'Unclaim all podiums.', 'Usage: unclaimall'}, 4, {}, function(pl, args)
    for _, podium in pairs(manager.Podiums) do
        if podium.Owner and podium.Owner ~= "" then
            podium.Owner = ""
            podium.Model.Owner.Value = ""
            podium:Close()
            setWallsCollide(podium, true)
        end
    end
    -- Clear all player claims
    for k in pairs(playerClaims) do
        playerClaims[k] = nil
    end
    return "All podiums have been unclaimed."
end},
{{'addmoney'}, {'Add money to a player\'s wallet.', 'Usage: addmoney <player> <amount>'}, 3, {'player', 'number'},
 function(pl, args)
    local targets = args[1]
    local amount = tonumber(args[2])
    if not targets or not amount then
        return "Usage: addmoney <player> <amount>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:AddFunds(amount)
        else
            warn("Wallet is not a valid member of Player " .. target.Name)
        end
    end
    return "Added " .. amount .. " to selected player's wallet(s)."
end}, -- Remove money from a player's wallet
{{'removemoney'}, {'Remove money from a player\'s wallet.', 'Usage: removemoney <player> <amount>'}, 3,
 {'player', 'number'}, function(pl, args)
    local targets = args[1]
    local amount = tonumber(args[2])
    if not targets or not amount then
        return "Usage: removemoney <player> <amount>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:RemoveFunds(amount)
        end
    end
    return "Removed " .. amount .. " from selected player's wallet(s)."
end}, -- Set a player's wallet balance
{{'setmoney'}, {'Set a player\'s wallet balance.', 'Usage: setmoney <player> <amount>'}, 4, {'player', 'number'},
 function(pl, args)
    local targets = args[1]
    local amount = tonumber(args[2])
    if not targets or not amount then
        return "Usage: setmoney <player> <amount>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:SetBalance(amount)
        end
    end
    return "Set wallet balance to " .. amount .. " for selected player(s)."
end}, -- Reset a player's wallet and bank balances
{{'resetmoney'}, {'Reset a player\'s wallet and bank balances.', 'Usage: resetmoney <player>'}, 4, {'player'},
 function(pl, args)
    local targets = args[1]
    if not targets then
        return "Usage: resetmoney <player>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:Reset()
        end
    end
    return "Reset wallet and bank balances for selected player(s)."
end}, -- Add money to a player's bank
{{'addbank'}, {'Add money to a player\'s bank.', 'Usage: addbank <player> <amount>'}, 3, {'player', 'number'},
 function(pl, args)
    local targets = args[1]
    local amount = tonumber(args[2])
    if not targets or not amount then
        return "Usage: addbank <player> <amount>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:AddBankFunds(amount)
        end
    end
    return "Added " .. amount .. " to selected player's bank(s)."
end}, -- Remove money from a player's bank
{{'removebank'}, {'Remove money from a player\'s bank.', 'Usage: removebank <player> <amount>'}, 3,
 {'player', 'number'}, function(pl, args)
    local targets = args[1]
    local amount = tonumber(args[2])
    if not targets or not amount then
        return "Usage: removebank <player> <amount>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:RemoveBankFunds(amount)
        end
    end
    return "Removed " .. amount .. " from selected player's bank(s)."
end}, -- Set a player's bank balance
{{'setbank'}, {'Set a player\'s bank balance.', 'Usage: setbank <player> <amount>'}, 4, {'player', 'number'},
 function(pl, args)
    local targets = args[1]
    local amount = tonumber(args[2])
    if not targets or not amount then
        return "Usage: setbank <player> <amount>"
    end
    for _, target in ipairs(targets) do
        if target.Wallet then
            target.Wallet:SetBankBalance(amount)
        end
    end
    return "Set bank balance to " .. amount .. " for selected player(s)."
end} -- ...existing code...
}

