local _, RBT                      = ...
RBT.DB                            = {}
local DB                          = RBT.DB

-- ============================================================================
-- DB constants
-- ============================================================================

local ALIGNMENT_DEFAULT           = "RIGHT"

local DB_KEY_HP_ALIGNMENT         = "hpAlignment"
local DB_KEY_RESOURCE_ALIGNMENT   = "resourceAlignment"

local DB_KEY_HP_ENABLED           = "hpEnabled"
local DB_KEY_RESOURCE_ENABLED     = "resourceEnabled"

function DB.GetHPEnabledKey()         return DB_KEY_HP_ENABLED         end
function DB.GetHPAlignmentKey()       return DB_KEY_HP_ALIGNMENT       end
function DB.GetResourceEnabledKey()   return DB_KEY_RESOURCE_ENABLED   end
function DB.GetResourceAlignmentKey() return DB_KEY_RESOURCE_ALIGNMENT end

-- ============================================================================
-- Saved variables
-- ============================================================================

function DB.InitDB()
    if not ResourceBarTextDB then
        ResourceBarTextDB = {}
    end
    if not ResourceBarTextDB[DB_KEY_HP_ALIGNMENT] then
        ResourceBarTextDB[DB_KEY_HP_ALIGNMENT] = ALIGNMENT_DEFAULT
    end
    if not ResourceBarTextDB[DB_KEY_RESOURCE_ALIGNMENT] then
        ResourceBarTextDB[DB_KEY_RESOURCE_ALIGNMENT] = ALIGNMENT_DEFAULT
    end
    if ResourceBarTextDB[DB_KEY_HP_ENABLED] == nil then
        ResourceBarTextDB[DB_KEY_HP_ENABLED] = true
    end
    if ResourceBarTextDB[DB_KEY_RESOURCE_ENABLED] == nil then
        ResourceBarTextDB[DB_KEY_RESOURCE_ENABLED] = true
    end
end

-- ============================================================================
-- Getters / Setters
-- ============================================================================

function DB.GetTable()
    return ResourceBarTextDB
end

function DB.GetAlignmentDefault()
    return ALIGNMENT_DEFAULT
end

function DB.IsHPEnabled()
    return ResourceBarTextDB[DB_KEY_HP_ENABLED] == true
end

function DB.SetHpEnabled(enabled)
    ResourceBarTextDB[DB_KEY_HP_ENABLED] = enabled
end

function DB.GetHPAlignment()
    return ResourceBarTextDB[DB_KEY_HP_ALIGNMENT]
end

function DB.SetHPAlignment(alignment)
    ResourceBarTextDB[DB_KEY_HP_ALIGNMENT] = alignment
end

function DB.GetResourceAlignment()
    return ResourceBarTextDB[DB_KEY_RESOURCE_ALIGNMENT]
end

function DB.SetResourceAlignment(alignment)
    ResourceBarTextDB[DB_KEY_RESOURCE_ALIGNMENT] = alignment
end

function DB.IsResourceEnabled()
    return ResourceBarTextDB[DB_KEY_RESOURCE_ENABLED] == true
end

function DB.SetResourceEnabled(enabled)
    ResourceBarTextDB[DB_KEY_RESOURCE_ENABLED] = enabled
end
