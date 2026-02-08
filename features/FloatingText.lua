FDN = FDN or {}
FDN.FloatingText = {}

local CATEGORY = FDN.Constants.CATEGORY

-- ============================================================
-- COLUMN POOLS
-- ============================================================
FDN.FloatingText.pools = {
    [CATEGORY.OUTGOING_DAMAGE] = ZO_ControlPool:New(
        "FDN_LabelTemplate",
        FDN_Column_OutgoingDamage,
        "OutgoingDamage"
    ),

    [CATEGORY.INCOMING_DAMAGE] = ZO_ControlPool:New(
        "FDN_LabelTemplate",
        FDN_Column_IncomingDamage,
        "IncomingDamage"
    ),

    [CATEGORY.INCOMING_HEAL] = ZO_ControlPool:New(
        "FDN_LabelTemplate",
        FDN_Column_Healing,
        "IncomingHeal"
    ),

    [CATEGORY.OUTGOING_HEAL] = ZO_ControlPool:New(
        "FDN_LabelTemplate",
        FDN_Column_Healing,
        "OutgoingHeal"
    ),
}

-- ============================================================
-- SHOW FLOATING TEXT
-- ============================================================
function FDN.FloatingText.Show(
    amount,
    result,
    sourceType,
    targetType,
    targetUnitId,
    category,
    damageType
)
    local pool = FDN.FloatingText.pools[category]
    if not pool then return end

    local label, key = pool:AcquireObject()
    label:ClearAnchors()
    label:SetAnchor(CENTER, nil, CENTER)

    -- ============================================================
    -- CATEGORY FLAGS
    -- ============================================================
    local isIncomingDamage = category == CATEGORY.INCOMING_DAMAGE
    local isOutgoingDamage = category == CATEGORY.OUTGOING_DAMAGE
    local isIncomingHeal   = category == CATEGORY.INCOMING_HEAL
    local isOutgoingHeal   = category == CATEGORY.OUTGOING_HEAL
    local isHeal           = isIncomingHeal or isOutgoingHeal

    -- ============================================================
    -- NUMBER FORMATTING
    -- ============================================================
    local displayText
    if FDN.Settings.sv.numberFormattingEnabled then
        displayText = FDN.Util.FormatNumber(
            amount,
            FDN.Settings.sv.numberFormattingPrecision
        )
    else
        displayText = tostring(amount)
    end

    if isHeal then
        displayText = "+" .. displayText
    end

    label:SetFont(string.format(
        "%s|%d|soft-shadow-thick",
        FDN.Settings.sv.fontName,
        FDN.Settings.sv.fontSize
    ))
    label:SetText(displayText)

    -- ============================================================
    -- COLORS
    -- ============================================================
    if isIncomingHeal then
        label:SetColor(unpack(FDN.Settings.sv.incomingHealColor))
    elseif isOutgoingHeal then
        label:SetColor(unpack(FDN.Settings.sv.outgoingHealColor))
    elseif isIncomingDamage then
        label:SetColor(unpack(FDN.Settings.sv.incomingDamageColor))
    elseif FDN.Settings.sv.damageTypeColors[damageType] then
        label:SetColor(unpack(FDN.Settings.sv.damageTypeColors[damageType]))
    elseif result == ACTION_RESULT_CRITICAL_DAMAGE then
        label:SetColor(unpack(FDN.Constants.COLORS.CRIT))
        label:SetScale(1.2)
    else
        label:SetColor(unpack(FDN.Constants.COLORS.OUTGOING))
    end

    label:SetHidden(false)

    -- ============================================================
    -- ANIMATION
    -- ============================================================
    local baseDuration = 600
    local speed = FDN.Settings.sv.animationSpeed or 1.0

    -- Incoming damage floats DOWN, everything else floats UP
    local moveY = isIncomingDamage and 80 or -80

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local move = timeline:InsertAnimation(ANIMATION_TRANSLATE, label, 0)
    move:SetTranslateOffsets(0, 0, 0, moveY)
    move:SetDuration(baseDuration / speed)

    timeline:SetHandler("OnStop", function()
        label:SetHidden(true)
        label:SetScale(1)
        pool:ReleaseObject(key)
    end)

    timeline:PlayFromStart()
end
