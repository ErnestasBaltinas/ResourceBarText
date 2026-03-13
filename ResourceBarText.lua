local _, RBT                 = ...
RBT.Core                     = {}
local DB                     = RBT.DB

-- ============================================================================
-- Constants
-- ============================================================================

local CVAR_PERSONAL_RESOURCE = "nameplateShowSelf"
local MSG_DISPLAY_DISABLED   = "|cffffffffResourceBarText|r: |cffffff00Personal Resource Display is turned off.|r"
local CLASS_DRUID            = "DRUID"
local CLASS_DEATHKNIGHT      = "DEATHKNIGHT"
local RUNE_COUNT             = 6
local RUNE_TICKER_INTERVAL   = 1.0

-- ============================================================================
-- Shared predicate
-- ============================================================================

local function IsPersonalResourceEnabled()
    return GetCVar(CVAR_PERSONAL_RESOURCE) == "1"
end

local function IsDruid()
    local classFilename = UnitClassBase("player")
    return classFilename == CLASS_DRUID
end

local function IsDeathKnight()
    local classFilename = UnitClassBase("player")
    return classFilename == CLASS_DEATHKNIGHT
end

-- ============================================================================
-- Shared utilities
-- ============================================================================

local function CreateBarLabel(bar, name)
    local lbl = bar:CreateFontString(name, "OVERLAY", "GameFontNormalLarge")
    lbl:SetTextColor(1, 1, 1, 1)
    lbl:SetFont(lbl:GetFont(), 14, "OUTLINE")
    return lbl
end

local function PositionLabelPair(bar, valueLabel, pctLabel, alignment)
    valueLabel:ClearAllPoints()
    pctLabel:ClearAllPoints()
    if alignment == "LEFT" then
        valueLabel:SetPoint("LEFT", bar, "LEFT", 2, 0)
        pctLabel:SetPoint("LEFT", valueLabel, "RIGHT", 0, 0)
    elseif alignment == "CENTER" then
        valueLabel:SetPoint("CENTER", bar, "CENTER", 0, 0)
        pctLabel:SetPoint("LEFT", valueLabel, "RIGHT", 0, 0)
    else -- RIGHT
        valueLabel:SetPoint("RIGHT", bar, "RIGHT", -14, 0)
        pctLabel:SetPoint("LEFT", valueLabel, "RIGHT", 0, 0)
    end
end

function RBT.Core.RefreshHPLabelPosition(alignment)
    PositionLabelPair(RBT.Core.healthBar, RBT.Core.hpLabel, RBT.Core.hpPctLabel, alignment)
end

function RBT.Core.RefreshResourceLabelPosition(alignment)
    PositionLabelPair(RBT.Core.powerBar, RBT.Core.resourceLabel, RBT.Core.resourcePctLabel, alignment)
end

-- ============================================================================
-- HP
-- ============================================================================

local function PrepareHPLabels()
    RBT.Core.healthBar  = PersonalResourceDisplayFrame.HealthBarsContainer.healthBar
    RBT.Core.hpLabel    = CreateBarLabel(RBT.Core.healthBar, "HPLabel")
    RBT.Core.hpPctLabel = CreateBarLabel(RBT.Core.healthBar, "HPPctLabel")
    RBT.Core.hpPctLabel:SetText("%")
    RBT.Core.RefreshHPLabelPosition(DB.GetHPAlignment())
end

local function UpdateHealthLabel()
    RBT.Core.hpLabel:SetFormattedText("%.0f", UnitHealthPercent("player", nil, CurveConstants.ScaleTo100))
end

local hpFrame = CreateFrame("Frame")
hpFrame:SetScript("OnEvent", function(self, event)
    UpdateHealthLabel()
end)

local function RegisterHPTracking()
    hpFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
end

local function UnregisterHPTracking()
    hpFrame:UnregisterAllEvents()
end

local function ShowHPLabel()
    UpdateHealthLabel()
    RBT.Core.hpLabel:Show()
    RBT.Core.hpPctLabel:Show()
end

local function HideHPLabel()
    RBT.Core.hpLabel:Hide()
    RBT.Core.hpPctLabel:Hide()
end

function RBT.Core.RefreshHPLabelState()
    if IsPersonalResourceEnabled() and DB.IsHPEnabled() then
        RegisterHPTracking()
        ShowHPLabel()
    else
        UnregisterHPTracking()
        HideHPLabel()
    end
end

-- ============================================================================
-- Resource
-- ============================================================================

local PERCENT_POWER_TYPES = {
    [Enum.PowerType.Mana] = true, -- can be millions
}

local function PrepareResourceLabels()
    RBT.Core.powerBar         = PersonalResourceDisplayFrame.PowerBar
    RBT.Core.resourceLabel    = CreateBarLabel(RBT.Core.powerBar, "ResourceLabel")
    RBT.Core.resourcePctLabel = CreateBarLabel(RBT.Core.powerBar, "ResourcePctLabel")
    RBT.Core.RefreshResourceLabelPosition(DB.GetResourceAlignment())
end

local function UpdateResourceLabel()
    local powerType = UnitPowerType("player")
    if PERCENT_POWER_TYPES[powerType] then
        RBT.Core.resourceLabel:SetFormattedText("%.0f",
            UnitPowerPercent("player", powerType, nil, CurveConstants.ScaleTo100))
        RBT.Core.resourcePctLabel:SetText("%")
    else
        RBT.Core.resourceLabel:SetText(UnitPower("player", powerType))
        RBT.Core.resourcePctLabel:SetText("")
    end
end

local resourceFrame = CreateFrame("Frame")
resourceFrame:SetScript("OnEvent", function(self, event)
    UpdateResourceLabel()
end)

local function SetupClassEvents()
    if IsDruid() then
        resourceFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end
end

local function RegisterResourceTracking()
    resourceFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    resourceFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    SetupClassEvents()
end

local function UnregisterResourceTracking()
    resourceFrame:UnregisterAllEvents()
end

local function ShowResourceLabel()
    UpdateResourceLabel()
    RBT.Core.resourceLabel:Show()
    RBT.Core.resourcePctLabel:Show()
end

local function HideResourceLabel()
    RBT.Core.resourceLabel:Hide()
    RBT.Core.resourcePctLabel:Hide()
end

function RBT.Core.RefreshResourceLabelState()
    if IsPersonalResourceEnabled() and DB.IsResourceEnabled() then
        RegisterResourceTracking()
        ShowResourceLabel()
    else
        UnregisterResourceTracking()
        HideResourceLabel()
    end
end

-- ============================================================================
-- Rune
-- ============================================================================

local runeCooldownLabels = {}
local runeTickerHandle

local function PrepareRuneLabels()
    for i = 1, RUNE_COUNT do
        local lbl = CreateBarLabel(prdClassFrame.Runes[i], "RuneCooldownLabel" .. i)
        lbl:SetPoint("CENTER", prdClassFrame.Runes[i], "CENTER", 0, 0)
        runeCooldownLabels[i] = lbl
    end
end

local function UpdateRuneLabels()
    for i = 1, RUNE_COUNT do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady then
            runeCooldownLabels[i]:Hide()
        else
            local remaining = start + duration - GetTime()
            runeCooldownLabels[i]:SetText(math.ceil(remaining))
            runeCooldownLabels[i]:Show()
        end
    end
end

local function AnyRuneOnCooldown()
    for i = 1, RUNE_COUNT do
        if GetRuneCount(i) == 0 then
            return true
        end
    end
    return false
end

local function StopRuneCooldownTicker()
    if runeTickerHandle then
        runeTickerHandle:Cancel()
        runeTickerHandle = nil
    end
end

local function StartRuneCooldownTicker()
    StopRuneCooldownTicker()
    runeTickerHandle = C_Timer.NewTicker(RUNE_TICKER_INTERVAL, function()
        UpdateRuneLabels()
        if not AnyRuneOnCooldown() then
            StopRuneCooldownTicker()
        end
    end)
end

local runeCooldownFrame = CreateFrame("Frame")
runeCooldownFrame:SetScript("OnEvent", function()
    UpdateRuneLabels()
    if AnyRuneOnCooldown() then
        StartRuneCooldownTicker()
    else
        StopRuneCooldownTicker()
    end
end)

local function RegisterRuneTracking()
    runeCooldownFrame:RegisterEvent("RUNE_POWER_UPDATE")
end

local function UnregisterRuneTracking()
    runeCooldownFrame:UnregisterAllEvents()
end

local function ShowRuneLabels()
    UpdateRuneLabels()
    if AnyRuneOnCooldown() then
        StartRuneCooldownTicker()
    end
end

local function HideRuneLabels()
    for i = 1, RUNE_COUNT do
        runeCooldownLabels[i]:Hide()
    end
    StopRuneCooldownTicker()
end

local function PrepareSecondaryResourceLabels()
    if IsDeathKnight() then
        PrepareRuneLabels()
    end
end

function RBT.Core.RefreshSecondaryResourceLabelState()
    if IsDeathKnight() then
        if IsPersonalResourceEnabled() then
            RegisterRuneTracking()
            ShowRuneLabels()
        else
            UnregisterRuneTracking()
            HideRuneLabels()
        end
    end
end

-- ============================================================================
-- CVar tracking
-- ============================================================================

local function NotifyPersonalResourceDisabled()
    print(MSG_DISPLAY_DISABLED)
end

local cvarFrame = CreateFrame("Frame")
cvarFrame:SetScript("OnEvent", function(self, event, cvarName)
    if cvarName == CVAR_PERSONAL_RESOURCE then
        if not IsPersonalResourceEnabled() then
            NotifyPersonalResourceDisabled()
        end
        RBT.Core.RefreshHPLabelState()
        RBT.Core.RefreshResourceLabelState()
        RBT.Core.RefreshSecondaryResourceLabelState()
    end
end)

local function RegisterCVarTracking()
    cvarFrame:RegisterEvent("CVAR_UPDATE")
end

-- ============================================================================
-- Initialization
-- ============================================================================

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event, isInitialLogin, isReloadingUi)
    -- Only create labels once; zone transfers fire this event too but must not recreate FontStrings
    if isInitialLogin or isReloadingUi then
        DB.InitDB()
        RBT.Options.RegisterOptionsPanel()
        PrepareHPLabels()
        PrepareResourceLabels()
        PrepareSecondaryResourceLabels()
        RegisterCVarTracking()
    end
    RBT.Core.RefreshHPLabelState()
    RBT.Core.RefreshResourceLabelState()
    RBT.Core.RefreshSecondaryResourceLabelState()
end)

local specFrame = CreateFrame("Frame")
specFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specFrame:SetScript("OnEvent", function(self, event)
    RBT.Core.RefreshResourceLabelState()
    RBT.Core.RefreshSecondaryResourceLabelState()
end)
