FDN = FDN or {}
FDN.Combat = {}

local PLAYER_NAME = nil

local function NormalizeName(name)
    if not name or name == "" then return nil end
    -- Removes ESO name formatting like ^Mx / ^Fx etc.
    return zo_strformat("<<1>>", name)
end

-- Cache player name once UI is ready
EVENT_MANAGER:RegisterForEvent(
    "FDN_PlayerNameInit",
    EVENT_PLAYER_ACTIVATED,
    function()
        EVENT_MANAGER:UnregisterForEvent("FDN_PlayerNameInit", EVENT_PLAYER_ACTIVATED)
        PLAYER_NAME = NormalizeName(GetUnitName("player"))
    end
)

function FDN.Combat.OnCombatEvent(
    _,
    result,
    _,
    abilityName,
    _,
    _,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    _,
    damageType,
    _,
    _,
    targetUnitId
)
    if not PLAYER_NAME then
        return
    end

    local isDamage =
        result == ACTION_RESULT_DAMAGE or
        result == ACTION_RESULT_CRITICAL_DAMAGE

    local isHeal =
        result == ACTION_RESULT_HEAL or
        result == ACTION_RESULT_CRITICAL_HEAL

    if not isDamage and not isHeal then
        return
    end

    local nSource = NormalizeName(sourceName)
    local nTarget = NormalizeName(targetName)

    local isOutgoing = (sourceType == COMBAT_UNIT_TYPE_PLAYER) or (nSource == PLAYER_NAME)
    local isIncoming = (targetType == COMBAT_UNIT_TYPE_PLAYER) or (nTarget == PLAYER_NAME)

    local category

    if isHeal then
        if isOutgoing then
            category = "OUTGOING_HEAL"
        elseif isIncoming then
            category = "INCOMING_HEAL"
        else
            return
        end
    else
        -- Damage classification (name fallback helps in cases where types are stripped)
        if isOutgoing then
            category = "OUTGOING"
        elseif isIncoming then
            category = "INCOMING"
        else
            return
        end
    end

    -- Note: for outgoing heals, targetUnitId is still fine as a bucket key (per target).
    -- For incoming heals (heals on you), targetUnitId is your bucket key.
    FDN.Aggregation.Add(
        hitValue,
        result,
        category,
        targetUnitId,
        damageType,
        function(total, finalResult, finalCategory, unitId, finalDamageType)
            -- For now, keep passing sourceType/targetType through (used by animation direction, etc.)
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
