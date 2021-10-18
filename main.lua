function PrintDebug(message)
    if PartyCharmsDebugging then print(message) end
end

-- Setting up slash commands
local function PartyCharms_SlashCommands(message, editbox)
    PrintDebug("PartyCharms::SlashCommand")

    -- pattern matching that skips leading whitespace and whitespace between cmd and args
    -- any whitespace at end of args is retained
    local _, _, cmd, args = string.find(message, "%s?(%w+)%s?(.*)")
    local argVals = {}

    if args then
        for i in string.gmatch(args, "%S+") do
            table.insert(argVals, i)
        end
    end
    
    if cmd == "list" then
        local defaultChatHeight = C_Console.GetFontHeight()

        print "Configured Party Charms:"
        for player, icon in pairs(PartyCharmsPlayerIcons) do
            print(player .. ": |T13700" .. icon .. ":".. defaultChatHeight .."|t")
        end
    elseif cmd == "add" then
        PartyCharmsPlayerIcons[argVals[1]] = argVals[2]
        PartyCharms_OnGroupRosterUpdate(_)
    elseif cmd == "remove" then
        PartyCharmsPlayerIcons[argVals[1]] = nil
        PartyCharms_OnGroupRosterUpdate(_)
    elseif cmd == "apply" then
        PartyCharms_OnGroupRosterUpdate(_)
    elseif cmd == "debug" then
        PartyCharmsDebugging = not PartyCharmsDebugging
        print("Party Charms debug: ", PartyCharmsDebugging)
    else
        print("Party Charms usage:")
        print("/partycharms list : Lists all configured party charms")
        print("/partycharms add <playername> <icon index> : Adds configuration for player icon")
        print("/partycharms remove <playername> : Removes configuration for player icon")
    end
end

SLASH_PARTYCHARMS1, SLASH_PARTYCHARMS2 = "/partycharms", "/pc"
SlashCmdList["PARTYCHARMS"] = PartyCharms_SlashCommands

-- Event Registering
local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, ...)
    if (event == "ADDON_LOADED") then
        if PartyCharmsPlayerIcons == nil then
            PartyCharmsPlayerIcons = {}
        end

        if PartyCharmsDebugging == nil then
            PartyCharmsDebugging = false
        end
    elseif (event == "GROUP_ROSTER_UPDATE") then
        PartyCharms_OnGroupRosterUpdate(event)
    end
end)

function PartyCharms_OnGroupRosterUpdate(event)
    PrintDebug("PartyChamrs::OnGroupRosterUpdate")
    -- Check if just a Party and Leader
    if (IsInGroup() and UnitIsGroupLeader("player") and GetNumGroupMembers("_HOME") > 1) then
        PrintDebug("PartyCharms::OnGroupRosterUpdate::SettingIcons")
        -- Checking for self [name,icon]
        local playerLoc = PlayerLocation:CreateFromUnit("player")
        local playerName = C_PlayerInfo.GetName(playerLoc)

        if PartyCharmsPlayerIcons[playerName] then
            PrintDebug("PartyChamrs::OnGroupRosterUpdate::SelfNameIcon")
            SetRaidTarget("player", PartyCharmsPlayerIcons[playerName])
        end

        -- Check for configured [names,icons] and set icons
        local homePlayers = GetHomePartyInfo()

        -- Checking for group [name,icon]
        for _, player in ipairs(homePlayers) do
            PrintDebug("PartyCharms::OnGroupRosterUpdate::homePlayers::"..player)
            if PartyCharmsPlayerIcons[player] then
                PrintDebug("PartyCharms::OnGroupRosterUpdate::homePlayers::IconSet::"..player)
                SetRaidTarget(player, PartyCharmsPlayerIcons[player])
            else
                PrintDebug("PartyCharms::OnGroupRosterUpdate::homePlayers::IconClear::"..player)
                SetRaidTarget(player, 0)
            end
        end
    end
end

PrintDebug("PartyCharms::Source Code Load")