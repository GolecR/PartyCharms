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
                enabled = {
                    name = "Enabled",
                    order = 1,
                    type = "toggle",
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                healercharm = {
                    name = "Healer Charm",
                    order = 3,
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                tankcharm = {
                    name = "Tank Charm",
                    order = 2,
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                dps1charm = {
                    name = "DPS1 Charm",
                    order = 4,
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                dps2charm = {
                    name = "DPS2 Charm",
                    order = 5,
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                dps3charm = {
                    name = "DPS3 Charm",
                    order = 6,
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
            }
        },
        party ={
            name = "Party Group Settings",
            type = "group",
            args = {
                enabled = {
                    name = "Enabled",
                    order = 1,
                    type = "toggle",
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },                
                party1charm = {
                    name = "Party 1 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                party2charm = {
                    name = "Party 2 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                party3charm = {
                    name = "Party 3 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                party4charm = {
                    name = "Party 4 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                playercharm = {
                    name = "Self Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
            }
        },
        raid ={
            name = "Raid Group Settings",
            type = "group",
            args = {
                enabled = {
                    name = "Enabled",
                    order = 1,
                    type = "toggle",
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },                
                tank1charm = {
                    name = "Tank 1 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },        
                tank2charm = {
                    name = "Tank 2 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },
                assistcharm = {
                    name = "Assist 1 Charm",
                    type = "select",
                    values = charmsTable,
                    get = "OptionsTableGetter",
                    set = "OptionsTableSetter",
                },        
            }
        },
    },    
}

local defaults = {
    profile = {
        party = {
            enabled = true,
            party1charm = 1,
            party2charm = 2,
            party3charm = 3,
            party4charm = 4,
            playercharm = 5,
        },
        dungeon = {
            enabled = true,
            healercharm = 1,
            tankcharm = 2,
            dps1charm = 3,
            dps2charm = 4,
            dps3charm = 5,
        },
        raid = {
            enabled = true,
            tank1charm = 1,
            tank2charm = 2,
            assistcharm = 3,
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

function PartyCharms:OnInitialize()
    -- SavedVariables DB Setup
    self.db = LibStub("AceDB-3.0"):New("PartyCharmsDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("PartyCharms", options, {"pc", "partycharms"})

    -- Event Listeners Setup
    PartyCharms:RegisterEvent("GROUP_ROSTER_UPDATE", "GroupRosterUpdateHandler")
    PartyCharms:RegisterEvent("READY_CHECK", "GroupRosterUpdateHandler")

    -- Blizz Options UI Setup
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PartyCharms", "PartyCharms")
end

function PartyCharms:OptionsTableSetter(info, value)
    self.db.profile[info[#info-1]][info[#info]] = value

    PartyCharms:GroupRosterUpdateHandler()
end

function PartyCharms:OptionsTableGetter(info)
    return self.db.profile[info[#info-1]][info[#info]]
end

function PartyCharms:GroupRosterUpdateHandler()
    if UnitIsGroupLeader("player") then
        if PartyCharms:IsDungeon() and PartyCharms.db.profile.dungeon.enabled then
            PartyCharms:DungeonRosterUpdateHandler()
        elseif PartyCharms:IsRaid() and PartyCharms.db.profile.raid.enabled then
            PartyCharms:RaidRosterUpdateHandler()
        elseif PartyCharms:IsParty() and PartyCharms.db.profile.party.enabled then
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

function PartyCharms:IsParty()
    local _, instanceType = GetInstanceInfo()

    return (IsInGroup() and (1 < GetNumGroupMembers("_HOME") <= 5) and instanceType == "none")
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
    SetRaidTarget("player", PartyCharms.db.profile.party.playercharm)

    -- Loop through each party member
    for i=1,GetNumGroupMembers("_HOME")-1 do
        -- Assign Charm
        SetRaidTarget("party"..i,  PartyCharms.db.profile.party["party"..i.."charm"])
    end
end
