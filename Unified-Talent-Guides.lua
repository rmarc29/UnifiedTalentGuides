local Unified-Talent-Guides = CreateFrame("Frame", "Unified-Talent-Guides", UIParent)
Unified-Talent-Guides:SetWidth(220)
Unified-Talent-Guides:SetHeight(160)
Unified-Talent-Guides:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
Unified-Talent-Guides:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
Unified-Talent-Guides:SetBackdropColor(0, 0, 0, 0.8)
Unified-Talent-Guides:SetBackdropBorderColor(1, 1, 1, 1)
Unified-Talent-Guides:EnableMouse(true)
Unified-Talent-Guides:SetMovable(true)
Unified-Talent-Guides:RegisterForDrag("LeftButton")
Unified-Talent-Guides:SetScript("OnDragStart", function() Unified-Talent-Guides:StartMoving() end)
Unified-Talent-Guides:SetScript("OnDragStop", function() Unified-Talent-Guides:StopMovingOrSizing() end)

-- Ensure talent order tables are loaded
if not druidTalentOrder or not hunterTalentOrder or not warriorTalentOrder or not warlockTalentOrder then
    print("Error: Talent order tables not loaded correctly.")
    return
end

-- Fetching player class
local _, playerClass = UnitClass("player")

-- Assign the correct talent order table
local talentGuides = {
    ["DRUID"] = druidTalentOrder,
    ["HUNTER"] = hunterTalentOrder,
    ["WARRIOR"] = warriorTalentOrder,
    ["WARLOCK"] = warlockTalentOrder
}
local talentOrder = talentGuides[playerClass]

-- Function to update talent display
local function UpdateTalentDisplay()
    if not talentOrder then
        print("No talent guide available for this class.")
        return
    end

    local level = UnitLevel("player")
    for i = 1, 3 do
        local talentLevel = level + (i - 1)
        local talentInfo = talentOrder[talentLevel]

        if talentInfo then
            local talentName, iconPath = unpack(talentInfo)

            if not Unified-Talent-Guides["Talent" .. i] then
                local talentFrame = CreateFrame("Frame", nil, Unified-Talent-Guides)
                talentFrame:SetWidth(190)
                talentFrame:SetHeight(30)
                talentFrame:SetPoint("TOP", Unified-Talent-Guides, "TOP", 0, -((i - 1) * 35))

                local levelText = talentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                levelText:SetPoint("LEFT", talentFrame, "LEFT", 0, -20)
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
                Unified-Talent-Guides["Talent" .. i] = talentFrame
            else
                local talentFrame = Unified-Talent-Guides["Talent" .. i]
                talentFrame.levelText:SetText("lvl " .. talentLevel .. " :")
                talentFrame.icon:SetTexture(iconPath)
                talentFrame.text:SetText(talentName)
            end
        end
    end
end

-- Event handling for level-up updates
Unified-Talent-Guides:RegisterEvent("PLAYER_LEVEL_UP")
Unified-Talent-Guides:RegisterEvent("PLAYER_ENTERING_WORLD")
Unified-Talent-Guides:SetScript("OnEvent", function(self, event, ...)
    UpdateTalentDisplay()
end)

-- Initial update
UpdateTalentDisplay()
