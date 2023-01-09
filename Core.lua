-- AceAddon Setup
PartyCharms = LibStub("AceAddon-3.0"):NewAddon("PartyCharms", "AceConsole-3.0", "AceEvent-3.0")

local charmsTable = {[1] = "Star", [2] = "Circle", [3] = "Diamond", [4] = "Triangle", [5] = "Moon", [6] = "Square"}
local raidDifficultyIDs = {3,4,5,6,7,9,14,15,16,17}
local dungeonDifficultyIDs = {1,2,8,23,24,150}

local options = {
    name = "PartyCharms",
    handler = PartyCharms,
    type = 'group',
    args = {
        dungeon ={
            name = "Dungeon Group Settings",
            type = "group",
            args = {
                healercharm = {
                    name = "Healer Charm",
                    order = 2,
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.dungeon.healercharm end,
                    set = function(info, input) PartyCharms.db.profile.dungeon.healercharm = input end,
                },
                tankcharm = {
                    name = "Tank Charm",
                    order = 1,
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.dungeon.tankcharm end,
                    set = function(info, input) PartyCharms.db.profile.dungeon.tankcharm = input end,
                },
                dps1charm = {
                    name = "DPS1 Charm",
                    order = 3,
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.dungeon.dps1charm end,
                    set = function(info, input) PartyCharms.db.profile.dungeon.dps1charm = input end,
                },
                dps2charm = {
                    name = "DPS2 Charm",
                    order = 4,
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.dungeon.dps2charm end,
                    set = function(info, input) PartyCharms.db.profile.dungeon.dps2charm = input end,
                },
                dps3charm = {
                    name = "DPS3 Charm",
                    order = 5,
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.dungeon.dps3charm end,
                    set = function(info, input) PartyCharms.db.profile.dungeon.dps3charm = input end,
                },
            }
        },
        party ={
            name = "Party Group Settings",
            type = "group",
            args = {
                party1 = {
                    name = "Party 1 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.party.party1charm end,
                    set = function(info, input) PartyCharms.db.profile.party.party1charm = input end,
                },
                party2 = {
                    name = "Party 2 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.party.party2charm end,
                    set = function(info, input) PartyCharms.db.profile.party.party2charm = input end,
                },
                party3 = {
                    name = "Party 3 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.party.party3charm end,
                    set = function(info, input) PartyCharms.db.profile.party.party3charm = input end,
                },
                party4 = {
                    name = "Party 4 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.party.party4charm end,
                    set = function(info, input) PartyCharms.db.profile.party.party4charm = input end,
                },
                player = {
                    name = "Self Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.party.selfcharm end,
                    set = function(info, input) PartyCharms.db.profile.party.selfcharm = input end,
                },
            }
        },
        raid ={
            name = "Raid Group Settings",
            type = "group",
            args = {
                tank1 = {
                    name = "Tank 1 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.raid.tank1charm end,
                    set = function(info, input) PartyCharms.db.profile.raid.tank1charm = input end,
                },        
                tank2 = {
                    name = "Tank 2 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.raid.tank2charm end,
                    set = function(info, input) PartyCharms.db.profile.raid.tank2charm = input end,
                },
                assist = {
                    name = "Assist 1 Charm",
                    type = "select",
                    values = charmsTable,
                    get = function(info) return PartyCharms.db.profile.raid.assistcharm end,
                    set = function(info, input) PartyCharms.db.profile.raid.assistcharm = input end,
                },        
            }
        },
    },    
}

local defaults = {
    profile = {
        party = {
        },
        dungeon = {
        },
        raid = {

        },
    }
}

local function has_value (tab, val)
    for index, value in ipairs(tab) do  
        if value == val then
            return true
        end
    end

    return false
end

function PartyCharms:PrintDebug(message)
    if PartyCharms.db.global.debug then print(message) end
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("PartyCharms", options, {"pc", "partycharms"})

function PartyCharms:OnInitialize()
    -- SavedVariables DB Setup
    self.db = LibStub("AceDB-3.0"):New("PartyCharmsDB", defaults, true)

    -- Event Listeners Setup
    PartyCharms:RegisterEvent("GROUP_ROSTER_UPDATE", "GroupRosterUpdateHandler")

    -- Blizz Options UI Setup
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PartyCharms", "PartyCharms")

    --[[ Trying to get charms to update when the config table has changed
    -- Config change handler
    LibStub("AceConfigRegistry-3.0").RegisterCallback(PartyCharms, "ConfigTableChange", "ConfigTableChanged")
    --]]
end

--[[
function PartyCharms:ConfigTableChanged(event, appName)
    PartyCharms:PrintDebug("Table changed")
end
--]]

function PartyCharms:GroupRosterUpdateHandler()
    if UnitIsGroupLeader("player") then
        if PartyCharms:IsDungeon() then
            PartyCharms:DungeonRosterUpdateHandler()
        elseif PartyCharms:IsRaid() then
            PartyCharms:RaidRosterUpdateHandler()
        else
            PartyCharms:PartyRosterUpdateHandler()
        end
    end
end

function PartyCharms:IsDungeon()
    local _, _, dungeonDifficultyID = GetInstanceInfo()

    return (IsInGroup()  and GetNumGroupMembers("_HOME") > 1 and has_value(dungeonDifficultyIDs, dungeonDifficultyID))
end

function PartyCharms:IsRaid()
    local _, _, raidDifficultyID = GetInstanceInfo()

    return (IsInGroup()  and GetNumGroupMembers("_HOME") > 1 and has_value(raidDifficultyIDs, raidDifficultyID))
end

function PartyCharms:DungeonRosterUpdateHandler()
    local function DungeonCharmHelper(unit, dpsTable)
        -- Check self role
        local playerRole = UnitGroupRolesAssigned(unit)

        if playerRole == "TANK" then
            SetRaidTarget(unit, PartyCharms.db.profile.dungeon.tankcharm)
        elseif playerRole == "HEALER" then
            SetRaidTarget(unit, PartyCharms.db.profile.dungeon.healercharm)
        elseif playerRole == "DAMAGER" then
            -- Add to DPS Table for later application
            table.insert(dpsTable, unit)
        end
    end

    local dpsTable = {}

    -- Check self combat role
    DungeonCharmHelper("player", dpsTable)

    -- Check dungeon combat roles
    for i=1,GetNumGroupMembers("_HOME")-1 do
        DungeonCharmHelper("party"..i, dpsTable)
    end

    -- Assign DPS charms
    for i=1,3 do
        if dpsTable[i] then
            SetRaidTarget(dpsTable[i], PartyCharms.db.profile.dungeon["dps"..i.."charm"])
        end
    end
end

function PartyCharms:RaidRosterUpdateHandler()
    local tankTable = {}
    -- Loop through each raid member
    for i=1,40 do
        -- Check role, store tanks
        local _, _, _, _, _, _, _, _, _, role, _, _ = GetRaidRosterInfo(i)
        if role then
            if role == "MAINTANK" then
                table.insert(tankTable, "raid"..i)
            elseif role == "MAINASSIST" then
                SetRaidTarget("raid"..i, PartyCharms.db.profile.raid.assistcharm)
            end
        end
    end

    -- Assign tank charms
    for i=1,2 do
        if tankTable[i] then
            SetRaidTarget(tankTable[i], PartyCharms.db.profile.raid["tank"..i.."charm"])
        end
    end
end

function PartyCharms:PartyRosterUpdateHandler()
    -- Assign Self Charm
    SetRaidTarget("player", PartyCharms.db.profile.party.selfcharm)

    -- Loop through each party member
    for i=1,GetNumGroupMembers("_HOME")-1 do
        -- Assign Charm
        SetRaidTarget("party"..i,  PartyCharms.db.profile.party["party"..i.."charm"])
    end
end

