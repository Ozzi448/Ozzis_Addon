local addonName, ns = ...

local OzzisAddon = LibStub("AceAddon-3.0"):GetAddon("OzzisAddon")
local Slash = OzzisAddon:NewModule("Slash", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("OzzisAddon")

do
    if not (ns.ClassicEra or ns.TBC or ns.Wrath or ns.Cataclysm or ns.MOP) then
        return
    end
end

function Slash:OnInitialize()
	if not ns:IsDevEnvironment() then
        Slash:RegisterChatCommand("OZZI", "Main")
        Slash:RegisterChatCommand("R", "Raid")
        Slash:RegisterChatCommand("D", "Dungeon")
        Slash:RegisterChatCommand("NPC", "NPC")
        Slash:RegisterChatCommand("RI", "Reset")
        Slash:RegisterChatCommand("BUILD", "Bld")
        Slash:RegisterChatCommand("FS", "FrameStack")
        Slash:RegisterChatCommand("CO", "MAP")
        Slash:RegisterChatCommand("QC", "QuestCheck")
        Slash:RegisterChatCommand("MC", "Mount")
        Slash:RegisterChatCommand("AC", "AchievementCheck")
        if not (ns.ElvUI or ns.TukUI or ns.GW2UI) then
            Slash:RegisterChatCommand("RL", "Reload")
        end
    else
		Slash:RegisterChatCommand("OZZI", "Main")
		Slash:RegisterChatCommand("BUILD", "Bld")
		Slash:RegisterChatCommand("CO", "MAP")
		Slash:RegisterChatCommand("NPC", "NPC")
		Slash:RegisterChatCommand("FS", "FS")
    end
end

function Slash:OnEnable()
    function Slash:Main()
		if not ns:IsDevEnvironment() then
            ns:SYSPrint(L["Ozzi's Addon help:"])
            ns:SYSPrint("/r - " .. L["Helps get current raid setting, change raid setting to mythic for example."])
            ns:SYSPrint("/d - " .. L["Helps get current dungeon setting, change dungeon setting to herioc for example."])
            ns:SYSPrint("/npc - " .. L["Outputs NPC ID with player CoOrds."])
            ns:SYSPrint("/ri - " .. L["Resets saved instances"])
            ns:SYSPrint("/build - " .. L["Outputs all build info."])
            ns:SYSPrint("/fs - " .. L["Toggles Frames Stack."])
            ns:SYSPrint("/co - " .. L["Shows Map Name, Map ID, Player CoOrds."])
            ns:SYSPrint("/qc - " .. L["QuestCheck, input a quest id to check, will output true or false."])
            ns:SYSPrint("/mc - " .. L["Shows total collected mounts on current character"])
            ns:SYSPrint("/rec - " .. L["Records Quest Accept, Complete, Turn-ins, Notes, Instance data."])
            ns:SYSPrint("/ac - " .. L["Achievement Check, input a quest id to check, will output true ot false."])
            if not (ns.ElvUI or ns.TukUI or ns.GW2UI) then
                ns:SYSPrint("/rl - " .. L["Reloads the UI."])
            else
                return
            end
        else
            ns:SYSPrint(L["Ozzi's Addon help:"])
            ns:SYSPrint("/build - " .. L["outputs all build info."])
			ns:SYSPrint("/co - " .. L["Shows Map Name, Map ID, Player CoOrds."])
			ns:SYSPrint("/npc - " .. L["Outputs NPC ID with player CoOrds."])
			ns:SYSPrint("/fs - " .. L["Toggles Frames Stack."])
        end
    end
end

function Slash:Mount(args)
    local arg = (args or "help"):lower()

    local messages = {
        ac = function()
            local mount = C_MountJournal.GetNumMounts()
            ns:Print(L["You have collected a total of"] .. " " .. mount .. " " .. L["mounts account wide."])
        end,
        ch = function()
            local count = GetNumCompanions and GetNumCompanions("MOUNT") or 0
            ns:Print(L["You have collected a total of"] .. " " .. count .. " " .. L["mounts on your current character."])
        end,
        help = function()
            ns:Print("|cff11ff11/mc ac - |r" .. L["Shows total mounts collected account wide."])
            ns:Print("|cff11ff11/mc ch - |r" .. L["Shows total mounts collected on your current character."])
        end
    }

    (messages[arg] or messages.help)()
end

-- Achievement Check
function Slash:AchievementCheck(...)
    if not ... or ... == "" then
        ns:Print("|cfffcba03" .. L["Please enter an Achievement ID."] .. "|r")
    else
        local id = ...
        local _, name, _, _, completed = GetAchievementInfo(id)

        if not name then
            ns:Print("|cffff0000" .. L["Invalid Achievement ID."] .. "|r")
            return
        end

        local link = GetAchievementLink(id)
        ns:Print("|cfffcba03" .. L["Achievement ID:"] .. "|r" .. " " .. id)
        ns:Print("|cfffcba03" .. L["Achievement Name:"] .. "|r" .. " " .. name)
        ns:Print("|cfffcba03" .. L["Achievement Link:"] .. "|r" .. " " .. link)

        if completed then
            ns:Print("|cfffcba03" .. L["Achievement Completed:"] .. "|r" .. "|cff00ff00" .. L["True"])
        else
            ns:Print("|cfffcba03" .. L["Achievement Completed:"] .. "|r" .. "|cffff0000" .. L["False"])
        end
    end
end

function Slash:QuestCheck(msg)
    if msg == '' then
        ns:Print("|cfffcba03" .. L["Please enter a Quest ID."] .. "|r")
    else
        local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(msg)

        ns:Print("|cfffcba03" .. L["Quest ID:"] .. "|r " .. "|H" .. L["quest:"]..msg.. "|h["..msg.."]|h")
        ns:Print("|cfffcba03" .. L["Quest Completed:"] .. "|r" .. " " .. (isCompleted and "|cff00ff00" .. L["True"] .. "|r" or "|cffff0000" .. L["False"] .. "|r"))
    end
end

function Slash:MAP(arg)
    local mapID = C_Map.GetBestMapForUnit("player")
    local pos = C_Map.GetPlayerMapPosition(mapID,"player")
    local wmf = WorldMapFrame:GetMapID()
    if arg == "" then
        ns:Print(C_Map.GetMapInfo(mapID).name, mapID, "(",math.ceil(pos.x*10000)/100,",",math.ceil(pos.y*10000)/100,")")
    elseif arg == "wmf" then
        ns:Print(format("%s (%d)", C_Map.GetMapInfo(wmf).name, wmf))
    end
end

function Slash:FS()
    UIParentLoadAddOn("Blizzard_DebugTools")
    FrameStackTooltip_Toggle()
end

function Slash:Bld()
    local v, b, d, t = GetBuildInfo()
    ns:Print(L["The following is the build information:"])
    ns:Print(string.format(L["Version"] .. " = %s", v))
    ns:Print(string.format(L["Build"] .. " = %s", b))
    ns:Print(string.format(L["Date"] .. " = '%s'", d))
    ns:Print(string.format(L[".toc Version"] .. " = %s", t))
end

function Slash:Reset()
    local name, _, _, difficulty = GetInstanceInfo()

    if IsInInstance() then
        ns:Print(string.format(L["You must leave to reset"] .. " %s (%s).", name or "Unknown", difficulty or "Unknown"))
    else
        ResetInstances()
    end
end

function Slash:Reload()
    ns.Reload()
end

function Slash:NPC()
    if (UnitGUID("target") == nil) then
        ns:Print(L["You must select an NPC or a Player"])
    else
        local name = UnitName('target')
        local guid = UnitGUID("target")
        local unitLink = "|cffffff00|Hunit:%s|h[%s]|h|r"
        local link = unitLink:format(guid, name)
        local unit_type = strsplit("-", guid)
        local z = C_Map.GetBestMapForUnit("player")
        local pos = C_Map.GetPlayerMapPosition(z,"player")

        if unit_type == "Creature" or unit_type == "Vehicle" then
            local _, _, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
            ns:Print(string.format("%s (%d)", link, npc_id))
            ns:Print(L["In Map :"], C_Map.GetMapInfo(z).name, "(",math.ceil(pos.x*10000)/100, math.ceil(pos.y*10000)/100,")")
        elseif unit_type == "Player" then
            local _, server_id, player_id = strsplit("-", guid)
                ns:Print(format("%s" .. " " .. L["is a player with ID"] .. " " .. "%s", link, player_id))
            if ns.ClassicEra and isHardscore() == true then
                ns:Print("%s" .. "is Self Found")
            else
                ns:Print("%s" .. "is not Self Found")
            end
        end
    end
end

function Slash:Dungeon(args)
    if args == "" then
        ns:Print("|cff11ff11/d ? - |r" .. L["Shows Current Difficulty Setting"])
        ns:Print("|cff11ff11/d n - |r" .. L["Sets Dungeon to Normal Difficulty"])
        ns:Print("|cff11ff11/d h - |r" .. L["Sets Dungeon to Heroic Difficulty"])
        ns:Print("|cff11ff11/d c - |r" .. L["Sets Dungeon to Challenge Mode"])
    end
    if args == "?" then
        if n.D() == 1 then
            ns:Print(L["Dungeon Difficulty: Normal"])
        elseif n.D() == 2 then
            ns:Print(L["Dungeon Difficulty: Heroic"])
        elseif n.D() == 8 then
            ns:Print(L["Dungeon Difficulty: Challenge Mode"])
        end
    end
    if args == "n" then
        ns.DS(1)
    elseif args == "h" then
        ns.DS(2)
    elseif args == "m" then
        ns.DS(8)
    end
end

function Slash:Raid(args)
    if args == "" then
        ns:Print("|cff11ff11/r ? - |r" .. L["Shows Current Difficulty Setting"])
        ns:Print("|cff11ff11/r 10 - |r" .. L["Sets Raid to 10 Player"])
        ns:Print("|cff11ff11/r 25 - |r" .. L["Sets Raid to 25 Player"])
        ns:Print("|cff11ff11/r 10h - |r" .. L["Sets Raid to 10 Player (Heroic)"])
        ns:Print("|cff11ff11/r 25h - |r" .. "Sets Raid to 25 Player (Heroic)")
        ns:Print("|cff11ff11/r n - |r" .. L["Sets Raid to Normal Difficulty"])
        ns:Print("|cff11ff11/r h - |r" .. L["Sets Raid to Heroic Difficulty"])
        ns:Print("|cff11ff11/r m - |r" .. L["Sets Raid to Mythic Difficulty"])
    end
    if args == "?" then
        if n.R() == 3 then
            ns:Print(L["Raid Difficulty: 10 Player"])
        elseif ns.R() == 4 then
            ns:Print(L["Raid Difficulty: 25 Player"])
        elseif ns.R() == 5 then
            ns:Print(L["Raid Difficulty: 10 Player (Heroic)"])
        elseif ns.R() == 6 then
            ns:Print(L["Raid Difficulty: 25 Player (Heroic)"])
        elseif ns.R() == 14 then
            ns:Print(L["Raid Difficulty: Normal"])
        elseif ns.R() == 15 then
            ns:Print(L["Raid Difficulty: Heroic"])
        elseif ns.R() == 16 then
            ns:Print(L["Raid Difficulty: Mythic"])
        end
    end
    if args == "10" then
        ns.SR(3)
    elseif args == "25" then
        ns.SR(4)
    elseif args == "10h" then
        ns.SR(5)
    elseif args == "25h" then
        ns.SR(6)
    elseif args == "n" then
        ns.SR(14)
    elseif args == "h" then
        ns.SR(15)
    elseif args == "m" then
        ns.SR(16)
    end
end