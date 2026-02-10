FDN = FDN or {}
FDN.Combat = {}

local CATEGORY = FDN.Constants.CATEGORY

-- ============================================================
-- Shared processing
-- ============================================================
local function ProcessCombatEvent(
    direction,   -- "OUTGOING" or "INCOMING"
    result,
    sourceType,
    targetType,
    hitValue,
    damageType,
    sourceUnitId,
    targetUnitId
)
    local isDamage =
        result == ACTION_RESULT_DAMAGE or
        result == ACTION_RESULT_CRITICAL_DAMAGE or
        result == ACTION_RESULT_DOT_TICK or
        result == ACTION_RESULT_DOT_TICK_CRITICAL

    local isHeal =
        result == ACTION_RESULT_HEAL or
        result == ACTION_RESULT_CRITICAL_HEAL

    if not isDamage and not isHeal then
        return
    end

    if type(hitValue) ~= "number" or hitValue <= 0 then
        return
    end

    local category
    if isHeal then
        category = (direction == "OUTGOING") and CATEGORY.OUTGOING_HEAL or CATEGORY.INCOMING_HEAL
    else
        category = (direction == "OUTGOING") and CATEGORY.OUTGOING_DAMAGE or CATEGORY.INCOMING_DAMAGE
    end

    -- For outgoing we want per-target aggregation (use targetUnitId).
    -- For incoming, targetUnitId should be the player (from the TARGET filter), so it aggregates cleanly.
    local aggUnitId = targetUnitId or 0

    FDN.Aggregation.Add(
        hitValue,
        result,
        category,
        aggUnitId,
        damageType,
        function(total, finalResult, finalCategory, unitId, finalDamageType)
            FDN.FloatingText.Show(
                total,
                finalResult,
                sourceType,
                targetType,
                unitId,
                finalCategory,
                finalDamageType
            )
        end
    )
end

-- ============================================================
-- OUTGOING wrapper (SOURCE == PLAYER filter already applied)
-- ============================================================
function FDN.Combat.OnCombatEventOutgoing(
    _,
    result,
    _,
    _,
    _,
    _,
    _,
    sourceType,
    _,
    targetType,
    hitValue,
    _,
    damageType,
    _,
    sourceUnitId,
    targetUnitId
)
    ProcessCombatEvent(
        "OUTGOING",
        result,
        sourceType,
        targetType,
        hitValue,
        damageType,
        sourceUnitId,
        targetUnitId
    )
end

-- ============================================================
-- INCOMING wrapper (TARGET == PLAYER filter already applied)
-- ============================================================
function FDN.Combat.OnCombatEventIncoming(
    _,
    result,
    _,
    _,
    _,
    _,
    _,
    sourceType,
    _,
    targetType,
    hitValue,
    _,
    damageType,
    _,
    sourceUnitId,
    targetUnitId
)
    ProcessCombatEvent(
        "INCOMING",
        result,
        sourceType,
        targetType,
        hitValue,
        damageType,
        sourceUnitId,
        targetUnitId
    )
end
