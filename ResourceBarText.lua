-- ============================================================================
-- Labels
-- ============================================================================

local function CreateBarLabel(bar, name)
    local lbl = bar:CreateFontString(name, "OVERLAY", "GameFontNormalLarge")
    lbl:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
    lbl:SetTextColor(1, 1, 1, 1)
    lbl:SetFont(lbl:GetFont(), 14, "OUTLINE")
    return lbl
end

local label   = CreateBarLabel(PersonalResourceDisplayFrame.PowerBar, "ResourceLabel")
local hpLabel = CreateBarLabel(PersonalResourceDisplayFrame.HealthBarsContainer.healthBar, "HPLabel")

-- ============================================================================
-- Update functions
-- ============================================================================

local PERCENT_POWER_TYPES = {
    [Enum.PowerType.Mana] = true, -- can be millions
}

local function UpdateResource()
    local powerType = UnitPowerType("player")
    if PERCENT_POWER_TYPES[powerType] then
        label:SetFormattedText("%.0f%%", UnitPowerPercent("player", powerType, nil, CurveConstants.ScaleTo100))
    else
        label:SetText(UnitPower("player", powerType))
    end
end

local function UpdateHP()
    hpLabel:SetFormattedText("%0.f%%", UnitHealthPercent("player", nil, CurveConstants.ScaleTo100))
end

-- ============================================================================
-- Class-specific setup
-- ============================================================================

local function SetupClassEvents()
    local _, classID = UnitClassBase("player")
    if classID == "DRUID" then
        resourceFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end
end

-- ============================================================================
-- Event frames
-- ============================================================================

-- Initial setup and spec changes
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        SetupClassEvents()
    end
    UpdateResource()
    UpdateHP()
end)

-- HP tracking
local hpFrame = CreateFrame("Frame")
hpFrame:RegisterEvent("UNIT_HEALTH")
hpFrame:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        UpdateHP()
    end
end)

-- Resource tracking
local resourceFrame = CreateFrame("Frame")
resourceFrame:RegisterEvent("UNIT_POWER_UPDATE")
resourceFrame:RegisterEvent("UNIT_POWER_FREQUENT")
resourceFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "UPDATE_SHAPESHIFT_FORM" or unit == "player" then
        UpdateResource()
    end
end)
