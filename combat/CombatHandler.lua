FDN = FDN or {}
FDN.Combat = {}

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

    if not isDamage and not isHeal then return end

    local isOutgoing = sourceType == COMBAT_UNIT_TYPE_PLAYER
    local isIncoming = targetType == COMBAT_UNIT_TYPE_PLAYER

    local category
    if isHeal then
        category = "HEAL"
    elseif isOutgoing then
        category = "OUTGOING"
    elseif isIncoming then
        category = "INCOMING"
    else
        return
    end

    if FDN.Settings.sv.aggregationEnabled then
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
    else
        FDN.FloatingText.Show(
            hitValue,
            result,
            sourceType,
            targetType,
            targetUnitId,
            category,
            damageType
        )
    end
end
