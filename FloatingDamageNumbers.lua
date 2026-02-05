FloatingDamageNumbers = {}
FloatingDamageNumbers.name = "FloatingDamageNumbers"

-- ============================================================================
-- Early proof that the Lua file itself is executing
-- ============================================================================
d("FloatingDamageNumbers addon initialized")

FloatingDamageNumbers.pool = nil


-- ============================================================================
-- Combat Event Handler
-- ============================================================================
local function OnCombatEvent(
    eventCode,
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
    targetUnitId,
    abilityId
)
    if result ~= ACTION_RESULT_DAMAGE and
       result ~= ACTION_RESULT_CRITICAL_DAMAGE then
        return
    end

    FloatingDamageNumbers.ShowFloatingNumber(hitValue, result)
    d("Combat event fired")
end

-- ============================================================================
-- Initialization Logic (SAFE & RELIABLE)
-- ============================================================================
local function Initialize()
    FloatingDamageNumbers.pool = ZO_ControlPool:New(
        "FloatingDamageNumbersLabelTemplate",
        FloatingDamageNumbersRoot,
        "FloatingLabel"
    )

    EVENT_MANAGER:RegisterForEvent(
        FloatingDamageNumbers.name,
        EVENT_COMBAT_EVENT,
        OnCombatEvent
    )

    EVENT_MANAGER:AddFilterForEvent(
        FloatingDamageNumbers.name,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )

    EVENT_MANAGER:AddFilterForEvent(
        FloatingDamageNumbers.name,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_IS_ERROR,
        false
    )

    d("FloatingDamageNumbers loaded")
end


-- ============================================================================
-- Add-on Load Event
-- ============================================================================
local function OnAddonLoaded(event, addonName)
    if addonName ~= FloatingDamageNumbers.name then return end

    EVENT_MANAGER:UnregisterForEvent(
        FloatingDamageNumbers.name,
        EVENT_ADD_ON_LOADED
    )

    Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    FloatingDamageNumbers.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)

-- ============================================================================
-- Safety Net: Handle cases where EVENT_ADD_ON_LOADED already fired
-- ============================================================================
-- if IsAddOnLoaded(FloatingDamageNumbers.name) then
--     Initialize()
-- end

-- ============================================================================
-- Floating Damage Number Display
-- ============================================================================
function FloatingDamageNumbers.ShowFloatingNumber(amount, result)
    local pool = FloatingDamageNumbers.pool
    if not pool then return end

    local label, key = pool:AcquireObject()

    label:ClearAnchors()
    label:SetAnchor(CENTER, FloatingDamageNumbersRoot, CENTER,
                    math.random(-40, 40), 0)

    label:SetText(tostring(amount))

    if result == ACTION_RESULT_CRITICAL_DAMAGE then
        label:SetColor(1, 0.6, 0, 1) -- crit
        label:SetScale(1.2)
    else
        label:SetColor(1, 0, 0, 1)
        label:SetScale(1.0)
    end

    label:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local move = timeline:InsertAnimation(
        ANIMATION_TRANSLATE,
        label,
        0
    )
    move:SetTranslateOffsets(0, 0, 0, -100)
    move:SetDuration(600)

    local fade = timeline:InsertAnimation(
        ANIMATION_ALPHA,
        label,
        300
    )
    fade:SetAlphaValues(1, 0)
    fade:SetDuration(300)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    timeline:SetHandler("OnStop", function()
        label:SetHidden(true)
        label:SetAlpha(1)
        label:SetScale(1)
        pool:ReleaseObject(key)
    end)

    timeline:PlayFromStart()
end



