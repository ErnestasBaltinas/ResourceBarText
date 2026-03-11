-- ============================================================================
-- Constants
-- ============================================================================

local CVAR_PERSONAL_RESOURCE = "nameplateShowSelf"
local MSG_DISPLAY_DISABLED   = "|cffffffffResourceBarText|r: |cffffff00Personal Resource Display is turned off.|r"

local LABEL_PADDING_RAW      = -12

-- ============================================================================
-- Labels
-- ============================================================================

local function CreateBarLabel(bar, name, offsetX)
    local lbl = bar:CreateFontString(name, "OVERLAY", "GameFontNormalLarge")
    lbl:SetPoint("RIGHT", bar, "RIGHT", offsetX or 0, 0)
    lbl:SetTextColor(1, 1, 1, 1)
    lbl:SetFont(lbl:GetFont(), 14, "OUTLINE")
    return lbl
end

local resourceLabel    = CreateBarLabel(PersonalResourceDisplayFrame.PowerBar, "ResourceLabel", LABEL_PADDING_RAW)
local resourcePctLabel = CreateBarLabel(PersonalResourceDisplayFrame.PowerBar, "ResourcePctLabel")
local hpLabel          = CreateBarLabel(PersonalResourceDisplayFrame.HealthBarsContainer.healthBar, "HPLabel",
    LABEL_PADDING_RAW)
local hpPctLabel       = CreateBarLabel(PersonalResourceDisplayFrame.HealthBarsContainer.healthBar, "HPPctLabel")

resourcePctLabel:SetText("%")
hpPctLabel:SetText("%")

-- ============================================================================
-- Update functions
-- ============================================================================

local PERCENT_POWER_TYPES = {
    [Enum.PowerType.Mana] = true, -- can be millions
}

local function UpdateResourceLabel()
    local powerType = UnitPowerType("player")
    if PERCENT_POWER_TYPES[powerType] then
        resourceLabel:SetFormattedText("%.0f", UnitPowerPercent("player", powerType, nil, CurveConstants.ScaleTo100))
        resourcePctLabel:Show()
    else
        resourceLabel:SetText(UnitPower("player", powerType))
        resourcePctLabel:Hide()
    end
end

local function UpdateHealthLabel()
    hpLabel:SetFormattedText("%.0f", UnitHealthPercent("player", nil, CurveConstants.ScaleTo100))
end

-- ============================================================================
-- Event frames (created here; events registered/unregistered based on CVar)
-- ============================================================================

-- HP tracking
local hpFrame = CreateFrame("Frame")
hpFrame:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        UpdateHealthLabel()
    end
end)

-- Resource tracking
local resourceFrame = CreateFrame("Frame")
resourceFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "UPDATE_SHAPESHIFT_FORM" or unit == "player" then
        UpdateResourceLabel()
    end
end)

-- ============================================================================
-- Tracking control
-- ============================================================================

local function IsPersonalResourceEnabled()
    return GetCVar(CVAR_PERSONAL_RESOURCE) == "1"
end

local function SetupClassEvents()
    local _, classID = UnitClassBase("player")
    if classID == "DRUID" then
        resourceFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end
end

local function RegisterHPTracking()
    hpFrame:RegisterEvent("UNIT_HEALTH")
end

local function UnregisterHPTracking()
    hpFrame:UnregisterAllEvents()
end

local function RegisterResourceTracking()
    resourceFrame:RegisterEvent("UNIT_POWER_UPDATE")
    resourceFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    SetupClassEvents()
end

local function UnregisterResourceTracking()
    resourceFrame:UnregisterAllEvents()
end

local function NotifyPersonalResourceDisabled()
    print(MSG_DISPLAY_DISABLED)
end

local function ApplyPersonalResourceState()
    if IsPersonalResourceEnabled() then
        RegisterHPTracking()
        RegisterResourceTracking()
        UpdateHealthLabel()
        UpdateResourceLabel()
    else
        UnregisterHPTracking()
        UnregisterResourceTracking()
        NotifyPersonalResourceDisabled()
    end
end

-- ============================================================================
-- Init frame
-- ============================================================================

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyPersonalResourceState()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        if IsPersonalResourceEnabled() then
            SetupClassEvents()
            UpdateResourceLabel()
            UpdateHealthLabel()
        end
    end
end)

-- ============================================================================
-- CVar tracking
-- ============================================================================

local cvarFrame = CreateFrame("Frame")
cvarFrame:RegisterEvent("CVAR_UPDATE")
cvarFrame:SetScript("OnEvent", function(self, event, cvarName)
    if cvarName == CVAR_PERSONAL_RESOURCE then
        ApplyPersonalResourceState()
    end
end)
