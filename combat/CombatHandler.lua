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
    _,
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

    FDN.FloatingText.Show(
        hitValue,
        result,
        sourceType,
        targetType,
        targetUnitId
    )
end
