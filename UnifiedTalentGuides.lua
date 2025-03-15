local UnifiedTalentGuides = CreateFrame("Frame", "UnifiedTalentGuides", UIParent)
UnifiedTalentGuides:SetWidth(220)
UnifiedTalentGuides:SetHeight(160)
UnifiedTalentGuides:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
UnifiedTalentGuides:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
UnifiedTalentGuides:SetBackdropColor(0, 0, 0, 0.5)
UnifiedTalentGuides:SetBackdropBorderColor(1, 1, 1, 1)
UnifiedTalentGuides:EnableMouse(true)
UnifiedTalentGuides:SetMovable(true)
UnifiedTalentGuides:RegisterForDrag("LeftButton")
UnifiedTalentGuides:SetScript("OnDragStart", function() UnifiedTalentGuides:StartMoving() end)
UnifiedTalentGuides:SetScript("OnDragStop", function() UnifiedTalentGuides:StopMovingOrSizing() end)

-- Fetching player class ( _ to ignore localized class names, need of English class token)
local _, playerClass = UnitClass("player")

local talentGuides = {
    ["DRUID"] = druidTalentOrder,
    ["HUNTER"] = hunterTalentOrder,
    ["WARRIOR"] = warriorTalentOrder,
    ["WARLOCK"] = warlockTalentOrder,
    ["PALADIN"] = paladinTalentOrder,
    ["ROGUE"] = rogueTalentOrder,
    ["MAGE"] = mageTalentOrder,
    ["PRIEST"] = priestTalentOrder,
    ["SHAMAN"] = shamanTalentOrder,
}
local talentOrder = talentGuides[playerClass]

-- Hiding the frame below level 10
local function ForceHideFrame()
    UnifiedTalentGuides:Hide()
    UnifiedTalentGuides:SetAlpha(0)  
    UnifiedTalentGuides:SetScript("OnShow", function(self) self:Hide() end)  
    UnifiedTalentGuides:UnregisterAllEvents() 
end

-- Restoring visibility when reaching level 10
local function RestoreFrame()
    UnifiedTalentGuides:SetAlpha(1)  
    UnifiedTalentGuides:SetScript("OnShow", nil)  
    UnifiedTalentGuides:RegisterEvent("PLAYER_LEVEL_UP")
    UnifiedTalentGuides:RegisterEvent("PLAYER_ENTERING_WORLD")
    UnifiedTalentGuides:Show()
end

local title = UnifiedTalentGuides:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", UnifiedTalentGuides, "TOP", 0, -10)
title:SetText("|cFFFF8080TNS|r's Unified Talent Guides")

local underline = UnifiedTalentGuides:CreateTexture(nil, "ARTWORK")
underline:SetTexture("Interface\\Buttons\\WHITE8x8") 
underline:SetHeight(2) 
underline:SetWidth(200) 
underline:SetPoint("TOP", title, "BOTTOM", 0, -2) 
underline:SetVertexColor(1, 1, 1, 0.5) 

local function UpdateTalentDisplay()
    local level = UnitLevel("player")

    if level < 10 then
        ForceHideFrame()
        return
    else
        RestoreFrame()
    end

    -- Clear previous talent frames before updating
    for i = 1, 3 do
        if UnifiedTalentGuides["Talent" .. i] then
            UnifiedTalentGuides["Talent" .. i]:Hide()
        end
    end

    -- Update talent frames based on the player's level
    for i = 1, 3 do
        local talentLevel = level + (i - 1)
        local talentInfo = talentOrder[talentLevel]

        if talentInfo then
            local talentName, iconPath = unpack(talentInfo)

            if not UnifiedTalentGuides["Talent" .. i] then
                local talentFrame = CreateFrame("Frame", nil, UnifiedTalentGuides)
                talentFrame:SetWidth(190)
                talentFrame:SetHeight(30)
                talentFrame:SetPoint("TOP", UnifiedTalentGuides, "TOP", 0, -((i - 1) * 35))

                local levelText = talentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                levelText:SetPoint("LEFT", talentFrame, "LEFT", 0, -30)
                levelText:SetText("lvl " .. talentLevel .. " :")

                local icon = talentFrame:CreateTexture(nil, "ARTWORK")
                icon:SetWidth(30)
                icon:SetHeight(30)
                icon:SetPoint("LEFT", levelText, "RIGHT", 5, -5)
                icon:SetTexture(iconPath)

                local text = talentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
                text:SetWidth(120)
                text:SetJustifyH("LEFT")
                text:SetText(talentName)

                talentFrame.levelText = levelText
                talentFrame.icon = icon
                talentFrame.text = text
                UnifiedTalentGuides["Talent" .. i] = talentFrame
            else
                local talentFrame = UnifiedTalentGuides["Talent" .. i]
                talentFrame.levelText:SetText("lvl " .. talentLevel .. " :")
                talentFrame.icon:SetTexture(iconPath)
                talentFrame.text:SetText(talentName)
                talentFrame:Show()
            end
        end
    end
end

local function CheckPlayerLevel()
    local level = UnitLevel("player")

    if level < 10 then
        ForceHideFrame()
    else
        RestoreFrame()
        UpdateTalentDisplay()
    end
end

-- Event handling for level-up updates
UnifiedTalentGuides:RegisterEvent("PLAYER_LEVEL_UP")
UnifiedTalentGuides:RegisterEvent("PLAYER_ENTERING_WORLD")
UnifiedTalentGuides:SetScript("OnEvent", function(self, event, ...)
    CheckPlayerLevel()
end)

-- Check and apply the correct frame state on startup
CheckPlayerLevel()

-- Ensure talent display updates properly after /reload or initial login
UnifiedTalentGuides:RegisterEvent("PLAYER_LOGIN")
UnifiedTalentGuides:SetScript("OnEvent", function(self, event, ...)
    UpdateTalentDisplay()
end)

-- Settings

local settingsPanel = CreateFrame("Frame", "UnifiedTalentGuides_Settings", UIParent)
settingsPanel:SetWidth(250)
settingsPanel:SetHeight(150)
settingsPanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

settingsPanel:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
settingsPanel:SetBackdropColor(0, 0, 0, 0.9)
settingsPanel:SetBackdropBorderColor(1, 1, 1, 1)
settingsPanel:Hide()

local settingsTitle = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
settingsTitle:SetPoint("TOP", settingsPanel, "TOP", 0, -10)
settingsTitle:SetText("Talent Guide Settings")

local closeButton = CreateFrame("Button", "UnifiedTalentGuides_CloseButton", settingsPanel)
closeButton:SetWidth(16)
closeButton:SetHeight(16)
closeButton:SetPoint("TOPRIGHT", settingsPanel, "TOPRIGHT", -5, -5)

local closeIcon = closeButton:CreateTexture(nil, "ARTWORK")
closeIcon:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
closeIcon:SetWidth(16)
closeIcon:SetHeight(16)
closeIcon:SetPoint("CENTER", closeButton, "CENTER")

closeButton:SetScript("OnClick", function() settingsPanel:Hide() end)

local settingsButton = CreateFrame("Button", "UnifiedTalentGuides_SettingsButton", UnifiedTalentGuides)
settingsButton:SetWidth(16)
settingsButton:SetHeight(16)
settingsButton:SetPoint("TOPRIGHT", UnifiedTalentGuides, "TOPRIGHT", -5, -5)
settingsButton:EnableMouse(true)

local settingsIcon = settingsButton:CreateTexture(nil, "ARTWORK")
settingsIcon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
settingsIcon:SetWidth(16)
settingsIcon:SetHeight(16)
settingsIcon:SetPoint("CENTER", settingsButton, "CENTER")

local function ToggleSettings()
    if settingsPanel:IsShown() then
        settingsPanel:Hide()
    else
        settingsPanel:Show()
    end
end

settingsButton:SetScript("OnClick", ToggleSettings)
