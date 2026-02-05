FloatingDamageNumbers = {}
FloatingDamageNumbers.name = "FloatingDamageNumbers"

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, 
    hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Only proceed for damage events
    if result ~= ACTION_RESULT_DAMAGE and result ~= ACTION_RESULT_CRITICAL_DAMAGE then
        return
    end
    -- Only show for player dealing damage
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    FloatingDamageNumbers.ShowFloatingNumber(targetUnitId, hitValue, result)
end

local function OnAddonLoaded(event, addOnName)
    if addonName ~= FloatingDamageNumbers.name then return end

    EVENT_MANAGER:RegisterForEvent(
        DamageNumbers.name,
        EVENT_COMBAT_EVENT,
        OnCombatEvent
    )

    -- Filter only outgoing damage
    EVENT_MANAGER:AddFilterForEvent(
        DamageNumbers.name,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )

    d("FloatingDamageNumbers loaded")
end

EVENT_MANAGER:RegisterForEvent(
    FloatingDamageNumbers.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)

function FloatingDamageNumbers.ShowDamage(amount, result)
    local label = FloatingDamageNumbersLabel
    label:SetText(tostring(amount))

    if result == ACTION_RESULT_CRITICAL_DAMAGE then
        label:SetColor(1, 0.6, 0, 1) -- orange crit
    else
        label:SetColor(1, 0, 0, 1) -- red normal
    end

    label:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local anim = timeline:InsertAnimation(
        ANIMATION_TRANSLATE,
        label,
        0
    )

    anim:SetTranslateOffsets(0, 0, 0, -80)
    anim:SetDuration(600)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    timeline:PlayFromStart()

    zo_callLater(function()
        label:SetHidden(true)
    end, 700)
end

EVENT_MANAGER:AddFilterForEvent(
    FloatingDamageNumbers.name,
    EVENT_COMBAT_EVENT,
    REGISTER_FILTER_IS_ERROR,
    false
)

