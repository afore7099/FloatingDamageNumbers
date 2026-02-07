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
    label:ClearAnchors()

    local isOutgoingDamage = category == "OUTGOING"
    local isIncomingDamage = category == "INCOMING"
    local isOutgoingHeal   = category == "OUTGOING_HEAL"
    local isIncomingHeal   = category == "INCOMING_HEAL"
    local isHeal           = isOutgoingHeal or isIncomingHeal

    -- Positioning (your current anchor-point layout)
    if isOutgoingDamage then
        if FDN.Util.IsOnScreen(FDN.Reticle.lastX, FDN.Reticle.lastY) then
            label:SetAnchor(CENTER, GuiRoot, CENTER, FDN.Reticle.lastX, FDN.Reticle.lastY)
        else
            label:SetAnchor(CENTER, GuiRoot, CENTER)
        end
    elseif isIncomingHeal then
        label:SetAnchor(RIGHT, GuiRoot, CENTER, -120, 0)
    elseif isOutgoingHeal then
        label:SetAnchor(CENTER, GuiRoot, CENTER, 0, 80)
    else
        label:SetAnchor(LEFT, GuiRoot, CENTER, 120, 0)
    end

    -- Number formatting (+ for heals)
    local displayText
    if FDN.Settings.sv.numberFormattingEnabled then
        displayText = FDN.Util.FormatNumber(amount, FDN.Settings.sv.numberFormattingPrecision)
    else
        displayText = tostring(amount)
    end
    if isHeal then
        displayText = "+" .. displayText
    end

    label:SetFont(string.format("%s|%d|soft-shadow-thick", FDN.Settings.sv.fontName, FDN.Settings.sv.fontSize))
    label:SetText(displayText)

    --COLORS
    if isIncomingHeal then
        label:SetColor(unpack(FDN.Settings.sv.incomingHealColor))
    elseif isOutgoingHeal then
        label:SetColor(unpack(FDN.Settings.sv.outgoingHealColor))
    elseif isIncomingDamage then
        --user-configurable incoming damage color
        label:SetColor(unpack(FDN.Settings.sv.incomingDamageColor))
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
    local moveY = isIncomingDamage and 60 or -60

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
