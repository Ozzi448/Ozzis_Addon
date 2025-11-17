DumpedFontsTable = DumpedFontsTable or {}
OzzisAddonDB = OzzisAddonDB or {
	enableWorldEntryTweaks = true
}

local addonName, ns = ...
OzzisMapData = OzzisMapData or {}
MountDataDB = MountDataDB or {}

local OzzisAddon = LibStub("AceAddon-3.0"):GetAddon("OzzisAddon")
local Slash = OzzisAddon:NewModule("Slash", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("OzzisAddon")
if not OzzisAddon then return end

local MapTypeLookup = {
    c = Enum.UIMapType.Continent,
    w = Enum.UIMapType.World,
    z = Enum.UIMapType.Zone,
    d = Enum.UIMapType.Dungeon,
    m = Enum.UIMapType.Micro,
    o = Enum.UIMapType.Orphan,
}

function Slash:OnInitialize()
	local commands = {
		r = "Raid",
		d = "Dungeon",
		em = "Edit",
		dev = "ToggleDevMode",
		lg = "LeaveGroup",
		tp = "TeleportOut",
		es = "EtherealStrands",
		est = "EtherealStrandsTraits",
		darkmaul = "DarkMaul",
		dusklight = "DuskLight",
		ri = "Reset",
		qc = "QuestCheck",
		ac = "AchievementCheck",
		clear = "ClearChat",
		rl = "Reload",
		gp = "GuildPartyCheck",
		window = "ToggleWindow",
		lc = "LockoutCheck",
		aui = "ArtifactUI",
	}

	for cmd, handler in pairs(commands) do
		local skipRL = cmd == "rl" and (ns.ElvUI or ns.TukUI or ns.GW2UI)
		if not skipRL then
			self:RegisterChatCommand(cmd, handler)
		end
	end
end

function Slash:ToggleDevMode()
	ns.devModeEnabled = not ns.devModeEnabled

	local devCommands = {
		npc = "NPC",
		build = "Bld",
		fs = "FS",
		co = "MAP",
		mci = "GetMapChildren",
		emt = "ExploredMapTextures",
		md = "DumpAllMounts",
	}

	for cmd, handler in pairs(devCommands) do
		if ns.devModeEnabled then
			self:RegisterChatCommand(cmd, handler)
		else
			self:UnregisterChatCommand(cmd)
		end
	end

	if ns.devModeEnabled then
		ns:Print(L["Developer mode ENABLED. Dev commands unlocked."])
	else
		ns:Print(L["Developer mode DISABLED. Dev commands removed."])
	end
end

function Slash:DumpAllMounts()
    MountDataDB["Mounts"] = ""

    local mountIDs = C_MountJournal.GetMountIDs()
    local count = 0
    local lines = {}

    for _, mountID in ipairs(mountIDs) do
        local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific,
              faction, shouldHideOnChar, isCollected, mountDisplayID = C_MountJournal.GetMountInfoByID(mountID)
        local _, description, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)

        creatureName = tostring(creatureName or "Unknown")
        spellID = spellID or 0
        mountDisplayID = mountDisplayID or 0
        sourceText = tostring(sourceText or "Unknown Source")

        sourceText = sourceText
            :gsub("(|c%x%x%x%x%x%x%x%x)", "%1")
            :gsub("(|r)", "%1")
            :gsub("(|T.-|t)", "%1")

        local entry = string.format(
            "|MSID|%d| |DID|%d| |GUIDE|| |ST|%s| |Name|%s| |MID|%d|",
            spellID,
            mountDisplayID,
            sourceText,
            creatureName,
            mountID
        )

        table.insert(lines, entry)
        count = count + 1
    end

    MountDataDB["Mounts"] = lines

    ns:Print(string.format("%d%s", count, L["total mounts dumped to MountDataDB['Mounts']"]))
end

function Slash:ExploredMapTextures(msg)
    local uiMapID = tonumber(msg:match("^(%d+)$"))
    if not uiMapID then
        ns:Print(L["Usage:"] .. " " .. "/emt <uiMapID>")
        return
    end

    local uiMapArtID = C_Map.GetMapArtID(uiMapID)
    local textures = C_MapExplorationInfo.GetExploredMapTextures(uiMapID)

    if textures and #textures > 0 then
        emtDB = emtDB or {}
        emtDB[uiMapArtID] = emtDB[uiMapArtID] or {}

        for _, tex in ipairs(textures) do
            local key = tex.textureWidth * 2^39
                      + tex.textureHeight * 2^26
                      + tex.offsetX * 2^13
                      + tex.offsetY
            local value = table.concat(tex.fileDataIDs, ",")
            emtDB[uiMapArtID][key] = value
        end

        ns:Print(L["Exploration textures recorded for mapID"] .. " " .. uiMapID)
    else
        ns:Print(L["No textures found for mapID"] .. " " .. uiMapID)
    end
end

function Slash:ArtifactUI(msg)
    local seasonID = PlayerGetTimerunningSeasonID()

	local input = ""
	if type(msg) == "string" then
		input = msg:lower():gsub("%s+", ""):gsub("%s+$", "")
	end

	if input == "fis" then
		if seasonID ~= nil then
			ns:Print("|cffff0000" .. L["Cannot open Underlight Angler during a Timerunning season."] .. "|r")
			return
		end

		UIParentLoadAddOn("Blizzard_ArtifactUI")
		ShowUIPanel(ArtifactFrame)
		return
	elseif input == "hoa" then
		if seasonID ~= nil then
			ns:Print("|cffff0000" .. L["Cannot open Heart of Azeroth during a Timerunning season."] .. "|r")
			return
		end

		UIParentLoadAddOn("Blizzard_AzeriteEssenceUI")

		if AzeriteEssenceUI and AzeriteEssenceUI:IsShown() then
			HideUIPanel(AzeriteEssenceUI)
		else
			SocketInventoryItem(INVSLOT_NECK)

			if AzeriteEssenceUI then
				ShowUIPanel(AzeriteEssenceUI)
			else
				ns:Print("|cffff0000" .. L["Could not open the Heart of Azeroth UI. Make sure the Heart of Azeroth is equipped."] .. "|r")
			end
		end
		return
	end

	if seasonID == nil then
		UIParentLoadAddOn("Blizzard_ArtifactUI")
		if ArtifactFrame and ArtifactFrame:IsShown() then
			HideUIPanel(ArtifactFrame)
		else
			SocketInventoryItem(INVSLOT_MAINHAND)

			if ArtifactFrame then
				ShowUIPanel(ArtifactFrame)
			else
				ns:Print("|cffff0000" .. L["Could not open the Artifact UI. Make sure the Artifact Weapon is equipped."] .. "|r")
			end
		end
		return
	elseif seasonID == 2 then
		if RemixArtifactFrame and RemixArtifactFrame:IsShown() then
			HideUIPanel(RemixArtifactFrame)
		else
			SocketInventoryItem(INVSLOT_MAINHAND)

			if RemixArtifactFrame then
				ShowUIPanel(RemixArtifactFrame)
			else
				ns:Print("|cffff0000" .. L["Could not open the Artifact UI. Make sure the Artifact Weapon is equipped."] .. "|r")
			end
		end
		return
	else
		ns:Print("|cffff0000" .. L["Your character is not in a supported Timerunning season."] .. "|r")
		return
	end
end

local commandHandlers = {
	[""] = function() ToggleWindowed() RestartGx() end,
	["u"] = function() UpdateWindow() end,
	["r"] = function() RestartGx() end,
}

function Slash:ToggleWindow(val)
	val = string.lower(val or "")
	local handler = commandHandlers[val]
	if handler then
		handler()
	else
		ns:Print("|cff11ff11/window|r -" .. " " .. L["Toggles windowed mode or fullscreen mode."])
		ns:Print("|cff11ff11/window u|r -" .. " " .. L["When in Windowed Mode, updates the window position and size."])
		ns:Print("|cff11ff11/window r|r -" .. " " .. L["Restarts the graphics engine. This is required if changed from Fullscreen to Windowed."])
	end
end

function Slash:GetMapChildren(input)
    local mapTypeKey, uiMapID = input:match("^(%S+)%s*(%d+)$")
    if not mapTypeKey or not uiMapID then
        ns:Print(L["Usage:"] .. " " .. "/mci [type] [uiMapID]")
        ns:Print(L["Example:"] .. " " .. "/mci c 946  →" .. " " .. L["children continents of 946"])
        ns:Print("         /mci w 942  →" .. " " .. L["child worlds of 942"])
        ns:Print("         /mci z 13   →" .. " " .. L["zones, dungeons, and raids under map 13"])
        return
    end

    local mapType = MapTypeLookup[mapTypeKey:lower()]
    if not mapType then
        ns:Print(L["Invalid map type key. Use:"] .. " " .. "c, w, z, d, m, o")
        return
    end

    local info = C_Map.GetMapChildrenInfo(tonumber(uiMapID), mapType, true)
    if not info or #info == 0 then
        ns:Print(L["No child maps found for"] .. " " .. uiMapID)
        return
    end

    OzzisMapData[uiMapID] = {}
    -- ns:Print("=== Children of mapID: " .. uiMapID .. " ===")
    for _, map in ipairs(info) do
        table.insert(OzzisMapData[uiMapID], { id = map.mapID, name = map.name, mapType = map.mapType })
        -- print(map.mapID, "-", map.name)
		ns:Print(L["Found maps for"] .. " " .. uiMapID .. " " .. L["reloadui or logout to save data to savedvariables."])
    end
end

-- function Slash:GuildPartyCheck()
-- 	if InGuildParty() then
-- 		ns:Print("You are in a guild party.")
-- 	else
-- 		ns:Print("You are not in a guild party.")
-- 	end
-- end
function Slash:GuildPartyCheck(numGuildRequired)
	numGuildRequired = tonumber(numGuildRequired) or 5

	local numGuildMembers = 0
	local numPartyMembers = GetNumSubgroupMembers()

	for i = 1, numPartyMembers do
		local unit = "party" .. i
		if UnitIsInMyGuild(unit) then
			numGuildMembers = numGuildMembers + 1
		end
	end

	if UnitIsInMyGuild("player") then
		numGuildMembers = numGuildMembers + 1
	end

	if numGuildMembers >= numGuildRequired then
		ns:Print(L["Guild party confirmed with"] .. " " .. numGuildMembers .. " " .. L["guild members (required:"] .. " " .. numGuildRequired .. ").")
	else
		ns:Print(L["Only"] .. " " .. numGuildMembers .. " " .. L["guild members in party. Need at least"] .. " " .. numGuildRequired .. ".")
	end
end

-- function Slash:PhraseLog()
-- 	local phraseLog = {}

-- 	local frame = CreateFrame("Frame")
-- 	frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
-- 	frame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
-- 	frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
-- 	frame:SetScript("OnEvent", function(_, event, msg, sender)
-- 		if not phraseLog[sender] then phraseLog[sender] = {} end
-- 		if not tContains(phraseLog[sender], msg) then
-- 			table.insert(phraseLog[sender], msg)
-- 			print(string.format("Logged phrase from %s: \"%s\"", sender, msg))
-- 		end
-- 	end)
-- end

function Slash:DarkMaul()
	local lootedCount = 0
	local turnInQuestID = 64376
	local lootedQuests = {64351, 64354, 64355, 64356, 64357}

	for _, questID in ipairs(lootedQuests) do
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			lootedCount = lootedCount + 1
		end
	end

	local _, _, _, turnedIn, _, total = GetQuestObjectiveInfo(turnInQuestID, 0, false)
	local turnedInCount = turnedIn or 0
	local totalDaily = 5
	local totalRequired = 10

	ns:Print(string.format(L["Invasive Mushrooms opened today:"] .. " " .. "%d of %d." .. " " .. L["Turned in"] .. " " .. "%d of %d", lootedCount, totalDaily, turnedInCount, totalRequired))
end

function Slash:DuskLight()
	local lootedCount = 0
	local turnInQuestID = 64274
	local eggLootQuests = {64280, 64281}

	for _, questID in ipairs(eggLootQuests) do
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			lootedCount = lootedCount + 1
		end
	end

	local _, _, _, turnedIn, _, total = GetQuestObjectiveInfo(turnInQuestID, 0, false)
	local turnedInCount = turnedIn or 0
	local totalDaily = 2
	local totalRequired = 10

	ns:Print(string.format(L["Eggs looted today:"] .. " " .. "%d of %d." .. " " .. L["You have turned in"] .. " " .. "%d of %d" .. " " .. L["eggs"], lootedCount, totalDaily, turnedInCount, totalRequired))
end

function Slash:EtherealStrands()
	local CURRENCY_ID = 3278
	local info = C_CurrencyInfo.GetCurrencyInfo(CURRENCY_ID)

	if not info then
		return ns:Print(L["Currency info not found for ID"] .. " " .. CURRENCY_ID)
	end
	ns:Print((L["You have earned"] .. " " .. "%d of %d" .. " " .. L["possible Ethereal Strands"]):format(info.quantity, info.maxQuantity))
end

function Slash:EtherealStrandsTraits()
	local questID = {84910, 91781}

	for _, id in ipairs(questID) do
		local title = C_QuestLog.GetTitleForQuestID(id)
		if not title then
			title = "Unknown Quest"
		end

		if not C_QuestLog.IsQuestFlaggedCompleted(id) then
			ns:Print((L["You will need to complete"] .. "|Hquest:%d|h[%s]|h"):format(id, title))
			return
		end
	end

	local SYSTEM_ID   = 29
	local TREE_ID     = 1115

	GenericTraitUI_LoadUI()
	GenericTraitFrame:SetSystemID(SYSTEM_ID)
	GenericTraitFrame:SetTreeID(TREE_ID)
	ToggleFrame(GenericTraitFrame)
end

function Slash:DumpFonts()
	ns:Print(L["Available fonts:"])
	local fonts = GetFonts()

	DumpedFontsTable = DumpedFontsTable or {}
	table.wipe(DumpedFontsTable)

	for i, font in ipairs(fonts) do
		Slash:Print(i .. ": " .. font)
		table.insert(DumpedFontsTable, font)
	end
end

-- function Slash:ChromieTime()
-- 	local inCT = ns.inChromieTime()
-- 	local level = ns.PlayerLevel

-- 	if level < 10 then
-- 		ns:Print(L["You are level"] .. " " .. level .. " " .. L["and you can't be in Chromie Time until you are level 10."])
-- 	elseif level > 71 then
-- 		ns:Print(L["You are level"] .. " " .. level .. " " .. L["and you can't be in Chromie Time."])
-- 	elseif not inCT then
-- 		ns:Print(L["You are level"] .. " " .. level .. " " .. L["and you are not in Chromie Time."])
-- 		ns:Print(L["Speak to Chromie and select a TimeLine to Enable Chromie Time."])
-- 	else
-- 		ns:Print(L["You are level"] .. " " .. level .. " " .. L["and you are in Chromie Time."])
-- 	end
-- end

function Slash:ChromieTimeCheck()
	local targetRace = UnitRace("target")
	local chromieID = UnitChromieTimeID("target")

	if not targetRace then
		ns:Print(L["You must select a player."])
		return
	end

	local timelineMap = {
		[0]  = L["Chromie Time is not enabled."],
		[5]  = L["Chromie Time is set to The Cataclysm."],
		[6]  = L["Chromie Time is set to Portal to Outland."],
		[7]  = L["Chromie Time is set to Fall of the Lich King."],
		[8]  = L["Chromie Time is set to Wilds of Pandaria."],
		[9]  = L["Chromie Time is set to Draenor."],
		[10] = L["Chromie Time is set to The Legion Invasion."],
		[14] = L["Chromie Time is set to Shadowlands."],
		[15] = L["Chromie Time is set to Battle for Azeroth."],
		[16] = L["Chromie Time is set to Dragonflight."]
	}

	local message = timelineMap[chromieID]
	if message then
		ns:Print(message)
	else
		ns:Print(L["Chromie Time is set to an unknown timeline"] .. " " .. "(" .. chromieID .. ").")
	end
end

-- Lockout Check
function Slash:LockoutCheck(args)
	local lockouts = {
		mop = {
			Galleon = 32098,
			Sha = 32099,
			Nalak = 32518,
			Oondasta = 32519
		},
		wod = {
			Rukhmar = 37464,
			Kazzak = 39380,
			Seals = 36055,
			PlatINV = 38482
		},
		sl = {
			Worldedge = 58259,
			Famu = 61618,
			-- Sundancer = 62465 -- Add missing ID if needed
		},
		ed = {
			Keevah = 78213,
			Moragh = 78210,
			Ristar = 77890,
			Mosa = 77940,
			Cian = 78211,
			Talthonei = 77994
		}
	}

	if args == "" then
		ns:Print("|cff11ff11/lc mop - |r" .. L["Outputs your lockouts for Galleon, Sha, Nalak, and Oondasta in MoP."])
		ns:Print("|cff11ff11/lc wod - |r" .. L["Outputs your lockouts for Rukhmar, Kazzak, Seals, and PlatINV in WoD."])
		ns:Print("|cff11ff11/lc sl - |r" .. L["Outputs your lockouts for Worldedge Gorger, Famu the Infinite in Shadowlands."])
		ns:Print("|cff11ff11/lc ed - |r" .. L["Output's your lockouts for Emerald Dream rares in Dragonflight."])
		return
	end

	local selected = lockouts[args:lower()]
	if selected then
		for boss, questID in pairs(selected) do
			local complete = C_QuestLog.IsQuestFlaggedCompleted(questID)
			local color = complete and "|cff00ff00" .. L["Yes"] .. "|r" or "|cffff0000" .. L["No"] .. "|r"
			ns:Print(format("%s: %s", boss, color))
		end
	else
		ns:Print("|cffff0000" .. L["Invalid argument. Type"] .. " " .. "|r|cff11ff11/lc|r |cffff0000" .. L["to see valid options."])
	end
end

function Slash:LeaveGroup()
	if IsInGroup() then
		local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or "PARTY"
		SendChatMessage("TY!", chatType)
		C_PartyInfo.LeaveParty()
	else
		ns:Print(L["You are not in a group."])
	end
end

function Slash:TeleportOut()
	if ns:IsInDelve() then
		if C_PartyInfo.IsDelveComplete() then
			C_PartyInfo.DelveTeleportOut()
		else
			ns:Print(L["You will need to complete the Delve first."])
		end
	elseif ns.inInstance then
		LFGTeleport(ns.Grouptype)
	else
		ns:Print(L["You are not in a group."])
	end
end

-- Mount Check
-- function Slash:Mount(args)
-- 	local arg = (args or "help"):lower()

-- 	local messages = {
-- 		ac = function()
-- 			local mount = C_MountJournal.GetNumMounts()
-- 			ns:Print("You have collected a total of" .. " " .. mount .. " " .. L["mounts account wide."])
-- 		end,
-- 		ch = function()
-- 			local count = GetNumCompanions and GetNumCompanions("MOUNT") or 0
-- 			ns:Print("You have collected a total of" .. " " .. count .. " " .. "mounts on your current character.")
-- 		end,
-- 		help = function()
-- 			ns:Print("|cff11ff11/mc ac - |r" .. L["Shows total mounts collected account wide."])
-- 			ns:Print("|cff11ff11/mc ch - |r" .. L["Shows total mounts collected on your current character."])
-- 		end
-- 	}

-- 	(messages[arg] or messages.help)()
-- end

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
		ns:Print("|cfffcba03" .. L["Achievement ID:"] .. "|r " .. id)
		ns:Print("|cfffcba03" .. L["Achievement Name:"] .. "|r " .. name)
		ns:Print("|cfffcba03" .. L["Achievement Link:"] .. "|r " .. link)

		if completed then
			ns:Print("|cfffcba03" .. L["Achievement Completed:"] .. "|r |cff00ff00" .. L["True"])
		else
			ns:Print("|cfffcba03" .. L["Achievement Completed:"] .. "|r |cffff0000" .. L["False"])
		end
	end
end

function Slash:QuestCheck(msg)
	msg = msg and msg:match("^%d+$") -- Basic numeric validation

	if not msg then
		ns:Print("|cfffcba03" .. L["Please enter a valid Quest ID."] .. "|r")
		return
	end

	local questID = tonumber(msg)
	local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
	local isCampaign = C_CampaignInfo.IsCampaignQuest(questID)
	local title = C_QuestLog.GetTitleForQuestID(questID)

	ns:Print("|cfffcba03" .. L["Quest ID:"] .. "|r |H" .. L["quest:"]..questID.."|h["..questID.."]|h")
	if title then
		ns:Print("|cfffcba03" .. L["Quest Title:"] .. "|r " ..title)
	else
		ns:Print(L["Unable to retrieve quest title for ID"] .. " " ..questID)
	end
	ns:Print("|cfffcba03" .. L["Quest Completed:"] .. "|r " .. (isCompleted and "|cff00ff00" .. L["True"] .. "|r" or "|cffff0000" .. L["False"] .. "|r"))
	ns:Print("|cfffcba03" .. L["Campaign:"] .. "|r " .. (isCampaign and "|cff00ff00" .. L["True"] .. "|r" or "|cffff0000" .. L["False"] .. "|r"))
end

function Slash:MAP(arg)
	local mapID    = C_Map.GetBestMapForUnit("player")
	local mapInfo  = mapID  and C_Map.GetMapInfo(mapID)
	local pos      = mapID  and C_Map.GetPlayerMapPosition(mapID, "player")
	local wmfID    = WorldMapFrame and WorldMapFrame:GetMapID()
	local wmfInfo  = wmfID  and C_Map.GetMapInfo(wmfID)

	local isInSpecial = C_Scenario.IsInScenario()
						or IsInInstance()
						or IsInLFGDungeon()
						or IsInGroup(ns.Grouptype)
						or IsInRaid(ns.Grouptype)
						or C_PartyInfo.IsDelveInProgress()

	local output
	if arg == "" then
		if mapInfo then
			if isInSpecial then
				-- just name and ID
				output = mapInfo.name .. " " .. mapID

			else
				if pos then
					local x = math.ceil(pos.x * 10000) / 100
					local y = math.ceil(pos.y * 10000) / 100
					output = mapInfo.name .. " " .. mapID
						.. " (" .. x .. ", " .. y .. ")"
				else
					output = mapInfo.name .. " " .. mapID
						.. "(Unknown Position)"
				end
			end
		else
			output = L["Unable to determine map info."]
		end

	elseif arg == "wmf" and wmfInfo then
		output = format("%s (%d)", wmfInfo.name, wmfID)

	else
		output = L["Invalid argument or map data unavailable."]
	end

	ns:Print(output)
end

-- Player Info
-- function Slash:PLI()
-- 	if not UnitRace("target") then
-- 		ns:Print(L["You must select a player."])
-- 		return
-- 	end

-- 	local name, realm = UnitFullName("target")
-- 	local raceLocale, raceEnglish, raceID = UnitRace("target")
-- 	local className, classID = UnitClass("target")
-- 	local faction = UnitFactionGroup("target") or "Unknown"
-- 	local level = UnitLevel("target")
-- 	local unit = "target"
-- 	local msg
-- 	local reason = UnitPhaseReason("target")
-- 	if reason == Enum.PhaseReason.WarMode then
-- 		msg = L["has a different War Mode"]
-- 	elseif reason == Enum.PhaseReason.ChromieTime then
-- 		msg = L["either of you is doing a Timewalking Campaign"]
-- 	elseif reason == Enum.PhaseReason.Phasing then
-- 		msg = L["is in a different Phase"]
-- 	elseif reason == Enum.PhaseReason.Sharding then
-- 		msg = L["is in a different Shard"]
-- 	elseif reason == nil then
-- 		msg = L["is in the same Phase"]
-- 	else
-- 		msg = L["has an unknown phase reason"] .. " " .. "(" .. tostring(reason) .. ")"
-- 	end

-- 	ns:Print("==================================")
-- 	ns:Print(L["Player Info:"])
-- 	ns:Print("==================================")
-- 	ns:Print(string.format(L["Player Name:"] .. " " .. "%s", name))
-- 	ns:Print(string.format(L["Realm:"] .. " " .. "%s", realm and realm ~= "" and realm or GetRealmName()))
-- 	ns:Print(string.format(L["Player Class:"] .. " " .. "%s", className))
-- 	ns:Print(string.format(L["Player Class ID:"] .. " " .. "%d", classID))
-- 	ns:Print(string.format(L["Player Faction:"] .. " " .. "%s", faction))
-- 	ns:Print(string.format(L["Player Level:"] .. " " .. "%d", level))
-- 	ns:Print(string.format(L["Localized Race Name:"] .. " " .."%s", raceLocale))
-- 	ns:Print(string.format(L["English Race Name:"] .. " " .. "%s", raceEnglish))
-- 	ns:Print(string.format(L["Race ID:"] .. " " .. "%d", raceID))
-- 	ns:Print(string.format(L["XP is"] .. " " .. "%s", IsXPUserDisabled() and "|cffff0000" .. L["disabled"] .. "|r" or "|cff00ff00" .. L["enabled"] .. "|r"))
-- 	ns:Print(L["Player is"] .. " " .. (UnitIsPVP("target") and "" or L["not"] .. " ") .. L["flagged for PVP"])
-- 	ns:Print(L["Player is"] .. " " .. (UnitIsAFK("target") and "" or L["not"] .. " ") .. L["AFK"])
-- 	ns:Print("sl", name, msg)
-- end

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

function Slash:CriteriaID(index)
	if (not IsInInstance()) then
		ns:Print(L["You must be in an instance to use this command."])
	else
		if not index or index == "" then
			ns:Print("|cfffcba03" .. L["Please enter a Criteria ID."] .. "|r")
		else
			local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(index)
			if not criteriaInfo or criteriaInfo == "" then
				ns:Print("|cfffcba03" .. L["No criteria found for ID:"] .. " " .. "|r" .. index)
			else
				if criteriaInfo.criteriaID then
					ns:Print(L["Criteria ID:"] .. " " .. criteriaInfo.criteriaID)
					ns:Print(L["Description:"] .. " " .. criteriaInfo.description)
					ns:Print(L["Step ID:"] .. " " .. criteriaInfo.assetID)
					if criteriaInfo.completed == true then
						ns:Print(L["Completed"])
					else
						ns:Print(L["Incomplete"])
					end
				end
			end
		end
	end
end

function Slash:ScenarioID()
	local scenarioID = C_ScenarioInfo.GetScenarioInfo()
	if (IsInInstance() == true) then
		if scenarioID and scenarioID.scenarioID then
			ns:Print(L["Name:"] .. " " .. scenarioID.name)
			ns:Print(L["Scenario ID:"] .. " " .. scenarioID.scenarioID)
		end
	else
		ns:Print(L["You must be in an instance to use this command."])
	end
end

function Slash:GossipID()
	local info = C_GossipInfo.GetOptions()
	if (UnitGUID("target") == nil) then
		ns:Print(L["You must select an NPC"])
	else
		if info then
			for i, v in pairs(info) do
				ns:Print(L["Gossip ID:"] .. " ", v.gossipOptionID)
				ns:Print(L["Option Text:"] .. " ", v.name)
				ns:Print(L["Order Index:"] .. " ", v.orderIndex)
			end
		else
			ns:Print(L["No gossip options available."])
		end
	end
end

function Slash:Reset()
	local name, _, _, difficulty = GetInstanceInfo()

	if IsInInstance() then
		ns:Print(string.format(L["You must leave to reset"] .. " " .. "%s (%s).", name or "Unknown", difficulty or "Unknown"))
	else
		ResetInstances()
	end
end

function Slash:Reload()
	ns:Reload()
end

function Slash:Edit()
	if not InCombatLockdown() and not UnitAffectingCombat("player") and not IsFalling() then
		if EditModeManagerFrame:IsShown() then
			HideUIPanel(EditModeManagerFrame)
		else
			ShowUIPanel(EditModeManagerFrame)
		end
	else
		ns:Print(L["You cannot edit UI while in combat or falling."])
	end
end

function Slash:NPC()
	local guid = UnitGUID("target")
	if not guid then
		ns:Print(L["You must select an NPC or a Player"])
		return
	end

	local name = UnitName("target") or "Unknown"
	local link = string.format("|cffffff00|Hunit:%s|h[%s]|h|r", guid, name)
	local unit_type = guid and strsplit("-", guid)
	if not unit_type then
		ns:Print(L["Unable to parse GUID properly."])
		return
	end

	local mapID = C_Map.GetBestMapForUnit("player")
	local mapInfo = mapID and C_Map.GetMapInfo(mapID)
	local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")

	if unit_type == "Creature" or unit_type == "Vehicle" then
		local _, _, _, _, _, npc_id = strsplit("-", guid)
		ns:Print(string.format("%s (" .. L["NPC ID:"] .." %d)", link, tonumber(npc_id)))
		if mapInfo and pos then
			local x = math.ceil(pos.x * 10000) / 100
			local y = math.ceil(pos.y * 10000) / 100
			ns:Print(string.format(L["In Map:"] .. " %s (%s, %s)", mapInfo.name, x, y))
		end

	elseif unit_type == "Player" then
		local _, _, player_id = strsplit("-", guid)
		ns:Print(string.format("%s " .. L["is a player with ID"] .. " %s", link, player_id))
	end
end

function Slash:Dungeon(args)
	local difficultyMap = {
		n = { id = 1, label = L["Normal"] },
		h = { id = 2, label = L["Heroic"] },
		mk = { id = 8, label = L["Mythic Keystone"]},
		m = { id = 23, label = L["Mythic"]},
		t = { id = 24, label = L["Timewalking"]},
		f = { id = 205, label = L["Follower"]},
		["?"] = true
	}

	if args == "" then
		ns:Print("|cff11ff11/d ? - |r" .. L["Shows Current Difficulty Setting"])
		ns:Print("|cff11ff11/d n - |r" .. L["Sets Dungeon to Normal Difficulty"])
		ns:Print("|cff11ff11/d h - |r" .. L["Sets Dungeon to Heroic Difficulty"])
		ns:Print("|cff11ff11/d m - |r" .. L["Sets Dungeon to Mythic Difficulty"])
		return
	end

	local entry = difficultyMap[args:lower()]
	if entry == true then
		local current = GetDungeonDifficultyID()
		for _, info in pairs(difficultyMap) do
			if type(info) == "table" and info.id == current then
				ns:Print(L["Dungeon Difficulty:"] .. " " .. info.label)
				return
			end
		end
		ns:Print(L["Dungeon Difficulty: Unknown"] .." (" .. tostring(current) .. ")")
	elseif type(entry) == "table" then
		SetDungeonDifficultyID(entry.id)
	else
		ns:Print(L["Invalid argument. Type"] .. " |cff11ff11/d|r" .. " " .. L["for help."])
	end
end

function Slash:Raid(args)
	local raidDifficulties = {
		n = { id = 14, label = L["Normal"] },
		h = { id = 15, label = L["Heroic"] },
		m = { id = 16, label = L["Mythic"] },
		["?"] = true
	}

	local legacyDifficulties = {
		["l 10"] = { id = 3, label = L["10 player"] },
		["l 25"] = { id = 6, label = L["25 player"] },
	}

	args = args:match("^%s*(.-)%s*$"):lower()

	if args:match("^$") then
		ns:Print("|cff11ff11/r ? - |r" .. L["Shows Current Difficulty Setting"])
		ns:Print("|cff11ff11/r n - |r" .. L["Sets Raid to Normal Difficulty"])
		ns:Print("|cff11ff11/r h - |r" .. L["Sets Raid to Heroic Difficulty"])
		ns:Print("|cff11ff11/r m - |r" .. L["Sets Raid to Mythic Difficulty"])
		ns:Print("|cff11ff11/r l ? - |r" .. L["Shows Current Legacy Raid Setting"])
		ns:Print("|cff11ff11/r l 10 - |r" .. L["Sets Legacy Raid to 10 Player"])
		ns:Print("|cff11ff11/r l 25 - |r" .. L["Sets Legacy Raid to 25 Player"])
		return
	end

	if args:match("^%?$") then --/r ?
		local current = GetRaidDifficultyID()
		for _, info in pairs(raidDifficulties) do
			if info.id == current then
				ns:Print(L["Raid Difficulty:"] .. " " .. info.label)
				return
			end
		end
		ns:Print(L["Raid Difficulty: Unknown"] .. " " .. "(" .. tostring(current) .. ")")
		return
	end

	if args:match("^l%s*%?$") then --/r l ?
		local legacyID = GetLegacyRaidDifficultyID()
		local labels = {
			[3] = L["10 player"],
			[6] = L["25 player"],
			[7] = L["Looking For Raid"],
			[9] = L["40 player"],
			[33] = L["10-30 player Timewalking"]
		}
		local label = labels[legacyID]
		ns:Print(label and L["Legacy Raid Difficulty is set to"] .. " " .. label .. "." or L["Legacy Raid Difficulty: Unknown"] .. " " .. "(" .. tostring(legacyID) .. ")")
		return
	end

	if raidDifficulties[args] then
		SetRaidDifficultyID(raidDifficulties[args].id)
	elseif legacyDifficulties[args] then
		SetLegacyRaidDifficultyID(legacyDifficulties[args].id)
	else
		ns:Print(L["Invalid argument. Type"] .. " " .. "|cff11ff11/r|r ? " .. L["for help."])
	end
end

function Slash:CheckSpell(input)
	local spellID = tonumber(input)
	if not spellID then
		ns:Print(L["Invalid input. Numeric spell ID required."])
		return
	end

	local spellInfo = C_Spell.GetSpellInfo(spellID)
	local spellName = spellInfo and spellInfo.name or ("ID " .. spellID)
	local spellIcon = spellInfo and spellInfo.icon or 136243 -- fallback icon

	local status = IsSpellKnown(spellID) and "Is Known" or "Is Unknown"
	local message = "|T" .. spellIcon .. ":0|t " .. spellName .. " - (" .. spellID .. "): " .. status
	ns:Print(message)
end

function Slash:Window()
	ToggleWindowed()
end

function Slash:Spec()
	local target = "target"
	local isTargeting = UnitExists(target)
	local specID, specName

	if isTargeting and UnitIsPlayer(target) then
		local guid = UnitGUID(target)
		local specInfo = GetInspectSpecialization(target)

		if specInfo and specInfo ~= 0 then
			specID = specInfo
			local _, name = GetSpecializationInfoByID(specID)
			specName = name
			ns:Print(UnitName(target) .. L["'s"] .. " " .. L["spec:"] .. " " .. (specName or "Unknown"))
		else
			ns:Print(L["Unable to retrieve spec info."])
		end
	else
		local currentSpecIndex = GetSpecialization()
		if currentSpecIndex then
			specID = GetSpecializationInfo(currentSpecIndex)
			local _, name = GetSpecializationInfoByID(specID)
			specName = name
			ns:Print(L["Your spec:"] .. " " .. (specName or "Unknown"))
		else
			ns:Print(L["You don't have a specialization yet."])
		end
	end
end

function Slash:ClearChat()
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i]:Clear()
	end
	ns:Print(L["All chat windows cleared."])
end

-- -- Create a frame to listen for PLAYER_ENTERING_WORLD
-- local WorldEntryFrame = CreateFrame("Frame")

-- WorldEntryFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- WorldEntryFrame:SetScript("OnEvent", function(Slash, event)
--     if event == "PLAYER_ENTERING_WORLD" then
-- 		-- local db == OzzisAddon.db and OzzisAddon.db.profile
-- 		-- if not db or not db.enableWorldEntryTweaks then return end

-- 		C_Timer.After(2, function()
-- 			if ns.EB1 and ns.EB1.style:IsShown() then
-- 				ns.EB1.style:Hide()
-- 			end

-- 			if ns.ZA and ns.ZA.Style:IsShown() then
-- 				ns.ZA.Style:Hide()
-- 			end

-- 			local showTutorials = GetCVar("showTutorials")
-- 			if showTutorials == "1" or showTutorials == nil or showTutorials == false then
-- 				ns:Print(L["Tutorials are Enabled"])
-- 				C_CVar.SetCVar("showTutorials", "0")
-- 				ns:Print(L["Tutorials are now Disabled"])
-- 			end

-- 			local hideAlerts = GetCVar("hideAdventureJournalAlerts")
-- 			if hideAlerts == "0" or hideAlerts == nil or hideAlerts == false then
-- 				ns:Print(L["Adventure Journal Alerts are currently enabled."])
-- 				C_CVar.SetCVar("hideAdventureJournalAlerts", "1")
-- 				ns:Print(L["Alerts have now been hidden."])
-- 			end

-- 			if ns.scriptProfile ~= "0" then
-- 				C_CVar.SetCVar("scriptProfile", "0")
-- 				ns:Print(L["Script Profiling was enabled and is now disabled, you will need to reload the ui using /rl or /reload slash commands."])
-- 			end

-- 			if not ns:IsDevEnvironment() then
-- 				if ns.addonProfilerEnabled == nil then
-- 					C_CVar.RegisterCVar("addonProfilerEnabled", "1"); C_CVar.SetCVar("addonProfilerEnabled", "0")
-- 				elseif ns.addonProfilerEnabled ~= "0" then
-- 					C_CVar.SetCVar("addonProfilerEnabled", "0")
-- 					ns:Print(L["Addon Profiling was enabled and is now disabled, you will need to reload the UI using /rl or /reload slash commands."])
-- 				end
-- 			end

-- 			local Plater = _G.Plater
-- 			if Plater and Plater.SetCVars then
-- 				Plater.SetCVars = function() end  -- disables Plater's CVar enforcement
-- 				ns:Print("Plater CVar enforcement disabled.")
-- 			end
-- 		end)
--     end
-- end)

-- local f = CreateFrame("Frame")
-- f:RegisterEvent("PLAYER_ENTERING_WORLD")
-- f:SetScript("OnEvent", function(_, _, isLogin, isReload)
--     -- Only zoom out on login or reload
--     C_Timer.After(1, function()
--         Minimap:SetZoom(0)
--     end)
-- end)

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("LOOT_OPENED")
EventFrame:RegisterEvent("BAG_UPDATE_DELAYED")

EventFrame:SetScript("OnEvent", function(self, event, ...)
	local db = OzzisAddon.db.profile

	if event == "PLAYER_ENTERING_WORLD" then
		local isLogin, isReload = ...

		C_Timer.After(1, function()
			if db.autoZoomOutMinimap then
				Minimap:SetZoom(0)
			end
		end)

		C_Timer.After(2, function()
			if db.hideEB1Style and ns.EB1 and ns.EB1.style:IsShown() then
				ns.EB1.style:Hide()
			end

			if db.hideZAStyle and ns.ZA and ns.ZA.Style:IsShown() then
				ns.ZA.Style:Hide()
			end

			-- if db.disableScriptProfiling and ns.scriptProfile ~= "0" then
			-- 	C_CVar.SetCVar("scriptProfile", "0")
			-- end

			-- if db.disableAddonProfiler and not ns:IsDevEnvironment() then
			-- 	if ns.addonProfilerEnabled ~= "0" then
			-- 		C_CVar.RegisterCVar("addonProfilerEnabled", "1")
			-- 		C_CVar.SetCVar("addonProfilerEnabled", "0")
			-- 	end
			-- end

			if db.disablePlaterCVars then
				local Plater = _G.Plater
				if Plater and Plater.SetCVars then
					Plater.SetCVars = function() end
				end
			end
		end)

	elseif event == "BAG_UPDATE_DELAYED" then
		if db.autoOpenCaches then
			local seasonID = PlayerGetTimerunningSeasonID()
			if seasonID == 2 then
				local itemIDsToOpen = {
                    [237812] = true,
					[245553] = true,
                    [246812] = true,
                    [246814] = true,
                    [246815] = true,
                    [251821] = true,
					[256763] = true,
					-- [246936] = true,
				}
				for bag = 0, NUM_BAG_FRAMES do
					local numSlots = C_Container.GetContainerNumSlots(bag)
					for slot = 1, numSlots do
						local item = C_Container.GetContainerItemInfo(bag, slot)
						if item and item.itemID and itemIDsToOpen[item.itemID] then
							C_Container.UseContainerItem(bag, slot)
						end
					end
				end
			else
				return
			end
		end

	elseif event == "LOOT_OPENED" then
		local autoLoot = GetCVar("autoLootDefault") == "1"
		local isShiftKeyDown = IsShiftKeyDown()

		if db.autoLootFix then
			if autoLoot and not isShiftKeyDown then
				for i = 1, GetNumLootItems() do
					LootSlot(i)
				end
			end
		end
	end
end)
