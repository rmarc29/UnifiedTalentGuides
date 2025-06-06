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

-- Manual player class selection
local manualOverride = false
local selectedClass = playerClass

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

local underlineBG = UnifiedTalentGuides:CreateTexture(nil, "ARTWORK")
underlineBG:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")  
underlineBG:SetWidth(200)  
underlineBG:SetHeight(2)  
underlineBG:SetPoint("TOP", title, "BOTTOM", 0, -2)  

local underlineXP = UnifiedTalentGuides:CreateTexture(nil, "OVERLAY")
underlineXP:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")  
underlineXP:SetHeight(2)  
underlineXP:SetPoint("LEFT", underlineBG, "LEFT", 0, 0)  
underlineXP:SetVertexColor(0.5, 0, 1, 1)  

local function UpdateUnderlineXP()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local restedState = GetRestState()  

    if restedState == 1 then  
        underlineBG:SetVertexColor(0, 0, 0.3, 1) 
        underlineXP:SetVertexColor(0, 0, 1, 1) 
    else  
        underlineBG:SetVertexColor(0.3, 0, 0.3, 1) 
        underlineXP:SetVertexColor(0.5, 0, 1, 1)  
    end

    if maxXP > 0 then
        local xpProgress = currentXP / maxXP 
        underlineXP:SetWidth(200 * xpProgress)  
    end
end

UpdateUnderlineXP()

UnifiedTalentGuides:RegisterEvent("PLAYER_XP_UPDATE")
UnifiedTalentGuides:RegisterEvent("UPDATE_EXHAUSTION")  
UnifiedTalentGuides:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION" then
        UpdateUnderlineXP()
    end
end)


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
                levelText:SetPoint("LEFT", talentFrame, "LEFT", 0, -40)
                levelText:SetText("lvl " .. talentLevel .. " :")

                -- Icon + Talent Name Placement
                local icon = talentFrame:CreateTexture(nil, "ARTWORK")
                icon:SetWidth(30)
                icon:SetHeight(30)
                icon:SetPoint("LEFT", levelText, "RIGHT", 5, -5)
                icon:SetTexture(iconPath)

                -- Talent Name Placement
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
        if not manualOverride then 
            selectedClass = playerClass
            talentOrder = talentGuides[selectedClass]
        end
        UpdateTalentDisplay()
    end
end


UnifiedTalentGuides:RegisterEvent("PLAYER_LEVEL_UP")
UnifiedTalentGuides:RegisterEvent("PLAYER_ENTERING_WORLD")
UnifiedTalentGuides:SetScript("OnEvent", function(self, event, ...)
    CheckPlayerLevel()
end)

CheckPlayerLevel()

UnifiedTalentGuides:RegisterEvent("PLAYER_LOGIN")
UnifiedTalentGuides:SetScript("OnEvent", function(self, event, ...)
    UpdateTalentDisplay()
end)

-- Custom panel

local customPanel = CreateFrame("Frame", "UnifiedTalentGuides_Custom", UIParent)
customPanel:SetWidth(200)
customPanel:SetHeight(100)
customPanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

customPanel:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

customPanel:SetBackdropColor(0, 0, 0, 0.9)
customPanel:SetBackdropBorderColor(1, 1, 1, 1)
customPanel:Hide()

local customTitle = customPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
customTitle:SetPoint("TOP", customPanel, "TOP", 0, -10)
customTitle:SetText("|cFFFF8080TNS|r's Unified Talent Guides Custom panel")

local closeButton_custom = CreateFrame("Button", "UnifiedTalentGuides_CloseButton", customPanel)
closeButton_custom:SetWidth(16)
closeButton_custom:SetHeight(16)
closeButton_custom:SetPoint("TOPRIGHT", customPanel, "TOPRIGHT", -5, -5)

-- Settings panel

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
settingsTitle:SetText("|cFFFF8080TNS|r's Unified Talent Guides Settings")

local closeButton = CreateFrame("Button", "UnifiedTalentGuides_CloseButton", settingsPanel)
closeButton:SetWidth(16)
closeButton:SetHeight(16)
closeButton:SetPoint("TOPRIGHT", settingsPanel, "TOPRIGHT", -5, -5)

closeButton:SetScript("OnClick", function() settingsPanel:Hide() end)

local closeIcon = closeButton:CreateTexture(nil, "ARTWORK")
closeIcon:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
closeIcon:SetWidth(16)
closeIcon:SetHeight(16)
closeIcon:SetPoint("CENTER", closeButton, "CENTER")

local settingsButton = CreateFrame("Button", "UnifiedTalentGuides_SettingsButton", UnifiedTalentGuides)
settingsButton:SetWidth(16)
settingsButton:SetHeight(16)
settingsButton:SetPoint("TOPRIGHT", UnifiedTalentGuides, "TOPRIGHT", -6, -6)
settingsButton:EnableMouse(true)

local infoButton = CreateFrame("Button", "UnifiedTalentGuides_InfoButton", settingsPanel)
infoButton:SetWidth(16)
infoButton:SetHeight(16)
infoButton:SetPoint("BOTTOMRIGHT", settingsPanel, "BOTTOMRIGHT", -10, 10)  

local infoTitle = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoTitle:SetPoint("RIGHT", infoButton, "LEFT", -5, 0) 
infoTitle:SetText("Info")

local settingsIcon = settingsButton:CreateTexture(nil, "ARTWORK")
settingsIcon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
settingsIcon:SetWidth(16)
settingsIcon:SetHeight(16)
settingsIcon:SetPoint("CENTER", settingsButton, "CENTER")

local infoIcon = infoButton:CreateTexture(nil, "ARTWORK")
infoIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") 
infoIcon:SetWidth(16)
infoIcon:SetHeight(16)
infoIcon:SetPoint("CENTER", infoButton, "CENTER")

local infoPanel = CreateFrame("Frame", "UnifiedTalentGuides_InfoPanel", UIParent)
infoPanel:SetWidth(300)
infoPanel:SetHeight(200)
infoPanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
infoPanel:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
infoPanel:SetBackdropColor(0, 0, 0, 0.9)
infoPanel:SetBackdropBorderColor(1, 1, 1, 1)
infoPanel:Hide()

local infoTitle = infoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
infoTitle:SetPoint("TOP", infoPanel, "TOP", 0, -10)
infoTitle:SetText("|cFFFF8080TNS|r's Unified Talent Guide Info")

local infoText = infoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoText:SetPoint("TOPLEFT", infoPanel, "TOPLEFT", 15, -40)
infoText:SetWidth(270)
infoText:SetJustifyH("LEFT")
infoText:SetText("This addon helps you track the best talent progression for your class. \n\nHere are some useful chat commands :\n\n- To see other classes talents : /UTG *classname*\n- To |cFFFF8080lock|r || |cFF00FF00unlock|r the addon's frame : /UTG lock /UTG unlock\n- To reset the addon to original state : /UTG reset \n\n Any donation is |cff00ccffappreciated|r, as I work on this addon alone and in my free time :")

local donationButton = CreateFrame("Button", nil, infoPanel)
donationButton:SetWidth(200)
donationButton:SetHeight(30)
donationButton:SetPoint("TOPLEFT", infoText, "BOTTOMLEFT", 0, 0)

local donationText = donationButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
donationText:SetAllPoints()
donationText:SetText("|cff00ccffhttps://buymeacoffee.com/rmarc29|r")
donationText:SetJustifyH("CENTER")
donationText:SetTextColor(0, 0.8, 1)  

local closeInfoButton = CreateFrame("Button", "UnifiedTalentGuides_CloseInfoButton", infoPanel)
closeInfoButton:SetWidth(16)
closeInfoButton:SetHeight(16)
closeInfoButton:SetPoint("TOPRIGHT", infoPanel, "TOPRIGHT", -5, -5)

local closeInfoIcon = closeInfoButton:CreateTexture(nil, "ARTWORK")
closeInfoIcon:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
closeInfoIcon:SetWidth(16)
closeInfoIcon:SetHeight(16)
closeInfoIcon:SetPoint("CENTER", closeInfoButton, "CENTER")

closeInfoButton:SetScript("OnClick", function() infoPanel:Hide() end)

local function ToggleInfoPanel()
    if infoPanel:IsShown() then
        infoPanel:Hide()
    else
        infoPanel:Show()
    end
end

infoButton:SetScript("OnClick", function()
    settingsPanel:Hide() 
    infoPanel:Show() 
end)


local function ToggleSettings()
    if settingsPanel:IsShown() then
        settingsPanel:Hide()
    else
        settingsPanel:Show()
    end
end

-- Settings checkboxes

local showXPBarCheckbox = CreateFrame("CheckButton", "UnifiedTalentGuides_ShowXPBarCheckbox", settingsPanel, "UICheckButtonTemplate")
showXPBarCheckbox:SetWidth(24)
showXPBarCheckbox:SetHeight(24)
showXPBarCheckbox:SetPoint("TOPLEFT", settingsPanel, "TOPLEFT", 20, -70) 

showXPBarCheckbox.text = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
showXPBarCheckbox.text:SetPoint("LEFT", showXPBarCheckbox, "RIGHT", 5, 0)
showXPBarCheckbox.text:SetText("Show XP Bar")

local function ToggleXPBarVisibility()
    if showXPBarCheckbox:GetChecked() then
        underlineBG:Show()  
        underlineXP:Show() 
    else
        underlineBG:Hide() 
        underlineXP:Hide()  
    end
end

showXPBarCheckbox:SetScript("OnClick", ToggleXPBarVisibility)

showXPBarCheckbox:SetChecked(underlineBG:IsShown() and underlineXP:IsShown())

local function SaveSettings()
    if showXPBarCheckbox:GetChecked() then
        underlineBG:Show()  
        underlineXP:Show()  
    else
        underlineBG:Hide()  
        underlineXP:Hide()  
    end
end

UnifiedTalentGuides:RegisterEvent("PLAYER_LOGOUT")
UnifiedTalentGuides:RegisterEvent("PLAYER_ENTERING_WORLD")
UnifiedTalentGuides:SetScript("OnEvent", function(self, event, ...)
    SaveSettings()
end)


settingsButton:SetScript("OnClick", ToggleSettings)

local showAddonCheckbox = CreateFrame("CheckButton", "UnifiedTalentGuides_ShowCheckbox", settingsPanel, "UICheckButtonTemplate")
showAddonCheckbox:SetWidth(24)
showAddonCheckbox:SetHeight(24)
showAddonCheckbox:SetPoint("TOPLEFT", settingsPanel, "TOPLEFT", 20, -40) 

showAddonCheckbox.text = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
showAddonCheckbox.text:SetPoint("LEFT", showAddonCheckbox, "RIGHT", 5, 0)
showAddonCheckbox.text:SetText("Show Talent Guide")

local function ToggleAddonVisibility()
    if this:GetChecked() then
        UnifiedTalentGuides:SetScript("OnShow", nil)  
        UnifiedTalentGuides:Show()  
        UnifiedTalentGuides:SetAlpha(1)  
    else
        UnifiedTalentGuides:Hide()
        UnifiedTalentGuides:SetAlpha(0)  
        UnifiedTalentGuides:SetScript("OnShow", function() UnifiedTalentGuides:Hide() end) 
    end
end

showAddonCheckbox:SetScript("OnClick", ToggleAddonVisibility)
showAddonCheckbox:SetChecked(UnifiedTalentGuides:IsShown())

-- Chat cmds

SLASH_UTG1 = "/UTG"
SLASH_UTG2 = "/utg"

local function UTG_CommandHandler(msg)
    local lowerMsg = string.lower(msg)
    
    local commands = {
        settings = function()
            if UnifiedTalentGuides_Settings then
                UnifiedTalentGuides_Settings:Show()
            else
                print("|cffff8080[UTG]|r Settings panel not found!")
            end
        end,
        
        reset = function()
            manualOverride = false
            selectedClass = playerClass
            talentOrder = talentGuides[selectedClass]
            UpdateTalentDisplay()
            print("|cffff8080[UTG]|r Reset to your character's class: " .. selectedClass .. ".")
        end,
        
        lock = function()
            UnifiedTalentGuides:EnableMouse(false)
            UnifiedTalentGuides:SetMovable(false)
            UnifiedTalentGuides:ClearAllPoints()
            print("|cFFFF8080[UTG]|r Addon Frame Locked")
        end,

        unlock = function()
            UnifiedTalentGuides:EnableMouse(true)
            UnifiedTalentGuides:SetMovable(true)
            UnifiedTalentGuides:RegisterForDrag("LeftButton")
            print("|cFFFF8080[UTG]|r Addon Frame Unlocked")
        end

        custom = function()
            if UnifiedTalentGuides_Custom then
                UnifiedTalentGuides_Custom:Show()
            else
                print("|cffff8080[UTG]|r Custom panel not found!")
            end
        end
    }

    if commands[lowerMsg] then
        commands[lowerMsg]()  
    elseif talentGuides[string.upper(lowerMsg)] then
        manualOverride = true
        selectedClass = string.upper(lowerMsg)
        talentOrder = talentGuides[selectedClass]
        UpdateTalentDisplay()
        print("|cffff8080[UTG]|r Now showing talent guide for " .. selectedClass .. ".")
    else
        print("|cffff8080[UTG] Usage:|r /UTG settings, /UTG <class>, /UTG lock || unlock or /UTG reset")
    end
end

SlashCmdList["UTG"] = UTG_CommandHandler
