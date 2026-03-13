local _, RBT                 = ...
RBT.Options                  = {}
local DB                     = RBT.DB

-- ============================================================================
-- Constants
-- ============================================================================

local ALIGNMENT_OPTIONS      = { "LEFT", "CENTER", "RIGHT" }
local SLASH_CMD              = "rbt"
local CATEGORY_NAME          = "ResourceBarText |TInterface\\AddOns\\ResourceBarText\\ResourceBarText.blp:16:16|t"

-- ============================================================================
-- Options panel
-- ============================================================================

local optionsPanelRegistered = false
local rbtCategory

local function CreateAlignmentOptions()
    local container = Settings.CreateControlTextContainer()
    for _, value in ipairs(ALIGNMENT_OPTIONS) do
        container:Add(value, value)
    end
    return container:GetData()
end

function RBT.Options.RegisterOptionsPanel()
    if optionsPanelRegistered then
        return
    end
    optionsPanelRegistered = true

    local category = Settings.RegisterVerticalLayoutCategory(CATEGORY_NAME)
    rbtCategory = category

    local hpEnabledSetting = Settings.RegisterAddOnSetting(
        category, "RBT_HPEnabled", DB.GetHPEnabledKey(),
        DB.GetTable(), Settings.VarType.Boolean, "Enable HP Text", true
    )
    hpEnabledSetting:SetValueChangedCallback(function(_, value)
        RBT.Core.RefreshHPLabelState()
    end)
    local hpEnabledInitializer = Settings.CreateCheckbox(category, hpEnabledSetting,
        "Enable or disable the HP text on the health bar.")

    local hpSetting = Settings.RegisterAddOnSetting(
        category, "RBT_HPAlignment", DB.GetHPAlignmentKey(),
        DB.GetTable(), type(DB.GetAlignmentDefault()), "HP Text Alignment", DB.GetAlignmentDefault()
    )
    hpSetting:SetValueChangedCallback(function(_, value)
        RBT.Core.RefreshHPLabelPosition(value)
    end)
    local hpAlignmentInitializer = Settings.CreateDropdown(category, hpSetting, CreateAlignmentOptions,
        "Alignment of HP text on the health bar.")
    hpAlignmentInitializer:SetParentInitializer(hpEnabledInitializer, function()
        return hpEnabledSetting:GetValue()
    end)

    local resourceEnabledSetting = Settings.RegisterAddOnSetting(
        category, "RBT_ResourceEnabled", DB.GetResourceEnabledKey(),
        DB.GetTable(), Settings.VarType.Boolean, "Enable Resource Text", true
    )
    resourceEnabledSetting:SetValueChangedCallback(function(_, value)
        RBT.Core.RefreshResourceLabelState()
    end)
    local resourceEnabledInitializer = Settings.CreateCheckbox(category, resourceEnabledSetting,
        "Enable or disable the resource text on the power bar.")

    local resourceSetting = Settings.RegisterAddOnSetting(
        category, "RBT_ResourceAlignment", DB.GetResourceAlignmentKey(),
        DB.GetTable(), type(DB.GetAlignmentDefault()), "Resource Text Alignment", DB.GetAlignmentDefault()
    )
    resourceSetting:SetValueChangedCallback(function(_, value)
        RBT.Core.RefreshResourceLabelPosition(value)
    end)
    local resourceAlignmentInitializer = Settings.CreateDropdown(category, resourceSetting, CreateAlignmentOptions,
        "Alignment of resource text on the power bar.")
    resourceAlignmentInitializer:SetParentInitializer(resourceEnabledInitializer, function()
        return resourceEnabledSetting:GetValue()
    end)

    Settings.RegisterAddOnCategory(category)
end

-- ============================================================================
-- Slash command
-- ============================================================================

local function OpenOptionsPanel()
    Settings.OpenToCategory(rbtCategory:GetID())
end

function ResourceBarText_OpenOptions()
    OpenOptionsPanel()
end

SLASH_RBT1 = "/" .. SLASH_CMD
SlashCmdList["RBT"] = OpenOptionsPanel
