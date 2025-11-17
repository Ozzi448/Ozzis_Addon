local addonName, ns = ...
_G[addonName] = ns

local L = LibStub("AceLocale-3.0"):GetLocale("OzzisAddon")

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:SetScript("OnEvent", function()
  ns.inInstance           = IsInInstance()
end)
if C_AddOns.GetAddOnMetadata then
	ns.version = C_AddOns.GetAddOnMetadata("Ozzis_Addon", "Version")
else
	ns.version = "Unknown"
end
ns.diffMap = {
	[1] = "N", -- Normal Party
	[2] = "H", -- Heroic Party
	[3] = "10N", -- 10-player Normal
	[4] = "25N", -- 25-player Normal
	[5] = "10H", -- 10-Player Herioc
	[6] = "25H", -- 25-Player Heroic
	[7] = "LFR", -- Looking For Raid
	[8] = "M+", -- Mythic Keystone
	[9] = "40N", -- 40 Player
	[11] = "H-S", -- Scenario Heroic
	[12] = "N-S", -- Scenario Normal
	[14] = "N", -- Normal
	[15] = "H", -- Heroic
	[16] = "M", -- Mythic
	[17] = "LFR", -- LFR
	[18] = "E", -- Event
	[19] = "E", -- Event
	[20] = "E", -- Event Scenario
	[23] = "M", -- Mythic
	[24] = "TW", -- Timewalking Party
	[25] = "WPvP", -- World PvP Scenario
	[29] = "PvEvP", -- PvP
	[30] = "E", -- Event
	[32] = "WPvP", -- World PvP Scenario
	[33] = "TW", -- Timewalking Raid
	[34] = "PvP", -- PVP
	[38] = "N-S", -- Scenario Normal
	[39] = "H-S", -- Scenario Heroic
	[40] = "M-S", -- Scenario Mythic
	[45] = "PvP", -- PvP
	[147] = "N-WF", -- Warfronts
	[149] = "H-WF", -- Warfronts Heroic
	[150] = "N", -- Normal Party
	[151] = "TW LFR", -- Timewalking Looking For Raid
	[152] = "VoN", -- Visions of N'Zoth
	[153] = "TI", -- Teeming Island
	[167] = "TG", -- Torghast
	[168] = "PoA-C", -- Scenario
	[169] = "PoA-L", -- Scenario
	[170] = "PoA-W", -- Scenario
	[171] = "PoA-H", -- Scenario
	[172] = "WB", -- World Boss
	[192] = "CL1", -- Chalenge Level 1
	[205] = "F", -- Follower
	[208] = "D", -- Delves
	[216] = "Q", -- Quest Party
	[220] = "S", -- Story
	[230] = "H", -- Heroic
}
ns.JailersTowerTypeMap = {
	[0]  = "TwistingCorridors",
	[1]  = "SkoldusHalls",
	[2]  = "FractureChambers",
	[3]  = "Soulforges",
	[4]  = "Coldheart",
	[5]  = "Mortregar",
	[6]  = "UpperReaches",
	[7]  = "ArkobanHall",              -- Added in 9.0.2
	[8]  = "TormentChamberJaina",      -- Added in 9.0.2
	[9]  = "TormentChamberThrall",     -- Added in 9.0.2
	[10] = "TormentChamberAnduin",     -- Added in 9.0.2
	[11] = "AdamantVaults",            -- Added in 9.1.0
	[12] = "ForgottenCatacombs",       -- Added in 9.1.0
	[13] = "Ossuary",                  -- Added in 9.1.5
	[14] = "BossRush",                 -- Added in 9.2.0
}

ns.IsInDelve            = C_PartyInfo.IsDelveInProgress and C_PartyInfo.IsDelveInProgress()
ns.ClassicEra           = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.TBC                  = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
ns.Wrath                = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
ns.Cataclysm            = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
ns.MOP                  = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
ns.Retail               = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
ns.Grouptype            = LE_PARTY_CATEGORY_INSTANCE or LE_PARTY_CATEGORY_HOME
ns.TWW                  = LE_EXPANSION_WAR_WITHIN
ns.instance             = inInstance
ns.Leave                = C_PartyInfo.LeaveParty
ns.ConvertRaid          = C_PartyInfo.ConvertToRaid
ns.ConvertParty         = C_PartyInfo.ConvertToParty
ns.RestrictPings        = C_PartyInfo.SetRestrictPings
ns.ReadyCheck           = DoReadyCheck
ns.ConfirmReady         = ConfirmReadyCheck
ns.D                    = GetDungeonDifficultyID
ns.R                    = GetRaidDifficultyID
ns.LR                   = GetLegacyRaidDifficultyID
ns.EB1                  = ExtraActionButton1
ns.ZA                   = ZoneAbilityFrame
ns.TestBuild            = type(IsTestBuild) == "function" and IsTestBuild()
ns.IsBetaBuild          = type(IsBetaBuild) == "function" and IsBetaBuild()
ns.IsDebugBuild         = type(IsDebugBuild) == "function" and IsDebugBuild()
ns.IsPublicTestClient   = type(IsPublicTestClient) == "function" and IsPublicTestClient()
ns.SD					= C_AddOns.IsAddOnLoaded("SilverDragon") or C_AddOns.DoesAddOnExist("SilverDragon")
ns.RA					= C_AddOns.IsAddOnLoaded("RareAlert") or C_AddOns.DoesAddOnExist("RareAlert")
ns.RS					= C_AddOns.IsAddOnLoaded("RareScanner") or C_AddOns.DoesAddOnExist("RareScanner")
ns.RT					= C_AddOns.IsAddOnLoaded("RareTracker") or C_AddOns.DoesAddOnExist("RareTracker")
ns.btwQuests            = C_AddOns.IsAddOnLoaded("BtWQuests") or C_AddOns.DoesAddOnExist("BtWQuests")
ns.BadBoy               = C_AddOns.IsAddOnLoaded("BadBoy") or C_AddOns.DoesAddOnExist("BadBoy")
ns.QuestsChanged        = C_AddOns.IsAddOnLoaded("QuestsChanged") or C_AddOns.DoesAddOnExist("QuestsChanged")
ns.Dugi                 = C_AddOns.IsAddOnLoaded("DugiGuidesViewerZ") or C_AddOns.DoesAddOnExist("DugiGuidesViewerZ")
ns.AutoMark             = C_AddOns.IsAddOnLoaded("AutoMark") or C_AddOns.DoesAddOnExist("AutoMark")
ns.ElvUI                = C_AddOns.IsAddOnLoaded("ElvUI") or C_AddOns.DoesAddOnExist("ElvUI")
ns.TukUI                = C_AddOns.IsAddOnLoaded("TukUI") or C_AddOns.DoesAddOnExist("TukUI")
ns.GW2UI                = C_AddOns.IsAddOnLoaded("GW2_UI") or C_AddOns.DoesAddOnExist("GW2_UI")
ns.Mapster				= C_AddOns.IsAddOnLoaded("Mapster") or C_AddOns.DoesAddOnExist("Mapster")
ns.fow					= C_AddOns.IsAddOnLoaded("ElvUI_FogofWar") or C_AddOns.DoesAddOnExist("ElvUI_FogofWar")
ns.pa					= C_AddOns.IsAddOnLoaded("ProjectAzilroka") or C_AddOns.DoesAddOnExist("ProjectAzilroka")
ns.TOXI					= C_AddOns.IsAddOnLoaded("ElvUI_ToxiUI") or C_AddOns.DoesAddOnExist("ElvUI_ToxiUI")
ns.IsEnabled            = C_VoiceChat.IsEnabled
ns.IsMuted              = C_VoiceChat.IsMuted
ns.IsDeafened           = C_VoiceChat.IsDeafened
ns.IsLoggedIn           = C_VoiceChat.IsLoggedIn
ns.SetMuted             = C_VoiceChat.SetMuted
ns.SetDeafened          = C_VoiceChat.SetDeafened
ns.inChromieTime        = C_PlayerInfo.IsPlayerInChromieTime
ns.canEnter             = C_PlayerInfo.CanPlayerEnterChromieTime
ns.PlayerLevel          = UnitLevel("player")
ns.autoEnableLogging    = false
ns.scriptProfile        = GetCVar("scriptProfile")
ns.addonProfilerEnabled = GetCVar("addonProfilerEnabled")
ns.Friendsnameplates    = GetCVar("nameplateShowFriends")
ns.devModeEnabled		= false

function ns:Print(...)
	local args = { ... }
	local tag = nil
	local output = {}

	if args[1] == "sl" then
	  tag = "sl"
	  table.remove(args, 1)
	end

	for i = 1, #args do
	  output[i] = tostring(args[i])
	end

	local message = table.concat(output, " ")

	if tag == "sl" then
	  message = message:gsub("[\r\n]+", " ")
	end

	print("|cffFF00FF[" .. L["Ozzis Addon"] .. "]|r", message)
end

function ns:SYSPrint(...)
  local prefix = "|cffFF00FF[Ozzis Addon]|r "
  local lines = { ... }
  for _, line in ipairs(lines) do
	DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(line), 1.0, 1.0, 0.0)
  end
end

function ns:IsDevEnvironment()
	return (ns.IsTestBuild or false)
		or (ns.IsBetaBuild or false)
		or (ns.IsDebugBuild or false)
		or (ns.IsPublicTestClient or false)
end

function ns:IsInDelve()
	local difficultyID = select(3, GetInstanceInfo())
	return ns.diffMap[difficultyID] == "Delve"
end

function ns:Reload()
	C_UI.Reload()
end

if ns.btwQuests then SLASH_BTWQUESTS2 = "/btw" end
if ns.Dugi then SLASH_DG2 = "/dg" end
if ns.BadBoy then SLASH_BADBOY2 = "/bb" end
if ns.QuestsChanged then SLASH_QUESTSCHANGED2 = "/q" end
if ns.AutoMark then SLASH_AUTOMARK2 = "/am" end
