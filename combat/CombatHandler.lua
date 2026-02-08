FDN = FDN or {}
FDN.Combat = {}

local CATEGORY = FDN.Constants.CATEGORY

function FDN.Combat.OnCombatEvent(
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
    _,
    targetUnitId
)
    local isDamage =
        result == ACTION_RESULT_DAMAGE or
        result == ACTION_RESULT_CRITICAL_DAMAGE

    local isHeal =
        result == ACTION_RESULT_HEAL or
        result == ACTION_RESULT_CRITICAL_HEAL

    if not isDamage and not isHeal then
        return
    end

    local category

    if isHeal then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            category = CATEGORY.OUTGOING_HEAL
        else
            category = CATEGORY.INCOMING_HEAL
        end
    else
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            category = CATEGORY.OUTGOING_DAMAGE
        else
            category = CATEGORY.INCOMING_DAMAGE
        end
    end

    FDN.Aggregation.Add(
        hitValue,
        result,
        category,
        targetUnitId,
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
