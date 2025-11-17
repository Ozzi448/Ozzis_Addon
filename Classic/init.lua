local addonName, ns = ...
ns = ns or {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:SetScript("OnEvent", function()
  ns.inInstance           = C_Scenario.IsInScenario()
                          or IsInInstance()
                          or IsInLFGDungeon()
                          or IsInGroup(ns.Grouptype)
                          or IsInRaid(ns.Grouptype)
                          or (C_PartyInfo.IsDelveInProgress and C_PartyInfo.IsDelveInProgress())
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
	[9] = "40N", -- 40 Player
  [148] = "20N", -- 20 Player
  [173] = "N", -- Normal Party
	[174] = "Heroic", -- Heroic Party
	[175] = "10N", -- 10 Player
	[176] = "25N", -- 25 Player
	[193] = "10H", -- 10 Player Heroic
	[194] = "25H", -- 25 Player Heroic
}
ns.ClassicEra           = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.TBC                  = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
ns.Wrath                = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
ns.Cataclysm            = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
ns.MOP                  = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
ns.Reload               = C_UI.Reload
ns.D                    = GetDungeonDifficultyID
ns.DS                   = SetDungeonDifficultyID
ns.R                    = GetRaidDifficultyID
ns.SR                   = SetRaidDifficultyID
ns.btwQuests            = C_AddOns.IsAddOnLoaded("BtWQuests") or C_AddOns.DoesAddOnExist("BtWQuests")
ns.BadBoy               = C_AddOns.IsAddOnLoaded("BadBoy") or C_AddOns.DoesAddOnExist("BadBoy")
ns.QuestsChanged        = C_AddOns.IsAddOnLoaded("QuestsChanged") or C_AddOns.DoesAddOnExist("QuestsChanged")
ns.Dugi                 = C_AddOns.IsAddOnLoaded("DugiGuidesViewerZ") or C_AddOns.DoesAddOnExist("DugiGuidesViewerZ")
ns.AutoMark             = C_AddOns.IsAddOnLoaded("AutoMark") or C_AddOns.DoesAddOnExist("AutoMark")
ns.ElvUI                = C_AddOns.IsAddOnLoaded("ElvUI") or C_AddOns.DoesAddOnExist("ElvUI")
ns.TukUI                = C_AddOns.IsAddOnLoaded("TukUI") or C_AddOns.DoesAddOnExist("TukUI")
ns.GW2UI                = C_AddOns.IsAddOnLoaded("GW2_UI") or C_AddOns.DoesAddOnExist("GW2_UI")

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

    print("|cffFF00FF[Ozzis Addon]|r", message)
end

function ns:SYSPrint(...)
  local prefix = "|cffFF00FF[Ozzis Addon]|r "
  local lines = { ... }
  for _, line in ipairs(lines) do
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(line), 1.0, 1.0, 0.0)
  end
end

function ns:IsDevEnvironment()
    return (self.IsTestBuild or false)
        or (self.IsBetaBuild or false)
        or (self.IsDebugBuild or false)
        or (self.IsPublicTestClient or false)
end

if ns.btwQuests or C_AddOns.IsAddOnLoaded("BtWQuests") then SLASH_BTWQUESTS2 = "/btw" end
if ns.Dugi == true then SLASH_DG2 = "/dg" end
if ns.BadBoy or C_AddOns.IsAddOnLoaded("BadBoy") then SLASH_BADBOY2 = "/bb" end
if ns.QuestsChanged or C_AddOns.IsAddOnLoaded("QuestsChanged") then SLASH_QUESTSCHANGED2 = "/q" end
if ns.AutoMark or C_AddOns.IsAddOnLoaded("AutoMark") then SLASH_AUTOMARK2 = "/am" end