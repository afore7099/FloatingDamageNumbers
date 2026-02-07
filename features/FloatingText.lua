FDN = FDN or {}
FDN.FloatingText = {}

function FDN.FloatingText.Show(
    amount,
    result,
    sourceType,
    targetType,
    targetUnitId,
    category,
    damageType
)
    local label, key = FDN.Pool.Acquire()

    local isOutgoing      = category == "OUTGOING" or category == "OUTGOING_HEAL"
    local isIncoming      = category == "INCOMING" or category == "INCOMING_HEAL"
    local isOutgoingHeal  = category == "OUTGOING_HEAL"
    local isIncomingHeal  = category == "INCOMING_HEAL"
    local isHeal          = isOutgoingHeal or isIncomingHeal

    local x = FDN.Reticle.lastX
    local y = FDN.Reticle.lastY

    -- Positioning
    if isOutgoing and FDN.Util.IsOnScreen(x, y) then
        label:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    else
        label:SetAnchor(CENTER, GuiRoot, CENTER)
    end

    -- Number formatting
    local displayText
    if FDN.Settings.sv.numberFormattingEnabled then
        displayText = FDN.Util.FormatNumber(
            amount,
            FDN.Settings.sv.numberFormattingPrecision
        )
    else
        displayText = tostring(amount)
    end

    local font = string.format(
        "%s|%d|soft-shadow-thick",
        FDN.Settings.sv.fontName,
        FDN.Settings.sv.fontSize
    )

    label:SetFont(font)
    label:SetText(displayText)

    -- COLOR SELECTION
    if isIncomingHeal then
        label:SetColor(unpack(FDN.Settings.sv.incomingHealColor))
    elseif isOutgoingHeal then
        label:SetColor(unpack(FDN.Settings.sv.outgoingHealColor))
    elseif isIncoming then
        label:SetColor(unpack(FDN.Constants.COLORS.INCOMING))
    elseif FDN.Settings.sv.damageTypeColors[damageType] then
        label:SetColor(unpack(FDN.Settings.sv.damageTypeColors[damageType]))
    elseif result == ACTION_RESULT_CRITICAL_DAMAGE then
        label:SetColor(unpack(FDN.Constants.COLORS.CRIT))
        label:SetScale(1.2)
    else
        label:SetColor(unpack(FDN.Constants.COLORS.OUTGOING))
    end

    -- Animation
    local baseDuration = 600
    local speed = FDN.Settings.sv.animationSpeed or 1.0
    local moveY = isIncoming and
        FDN.Constants.MOVE.DOWN or
        FDN.Constants.MOVE.UP

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local move = timeline:InsertAnimation(ANIMATION_TRANSLATE, label, 0)
    move:SetTranslateOffsets(0, 0, 0, moveY)
    move:SetDuration(baseDuration / speed)

    timeline:SetHandler("OnStop", function()
        label:SetHidden(true)
        label:SetScale(1)
        FDN.Pool.Release(key)
    end)

    timeline:PlayFromStart()
end
