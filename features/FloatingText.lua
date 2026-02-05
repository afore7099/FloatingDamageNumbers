FDN = FDN or {}
FDN.FloatingText = {}

FDN.FloatingText.positions = {}

function FDN.FloatingText.Show(amount, result, sourceType, targetType, targetUnitId, category)
    local label, key = FDN.Pool.Acquire()

    local isOutgoing = category == "OUTGOING"
    local isIncoming = category == "INCOMING"
    local isHeal     = category == "HEAL"

    local x = FDN.Reticle.lastX
    local y = FDN.Reticle.lastY

    if isOutgoing and FDN.Util.IsOnScreen(x, y) then
        label:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    else
        label:SetAnchor(CENTER, GuiRoot, CENTER)
    end

    label:SetText(tostring(amount))

    if isHeal then
        label:SetColor(unpack(FDN.Constants.COLORS.HEAL))
    elseif isIncoming then
        label:SetColor(unpack(FDN.Constants.COLORS.INCOMING))
    elseif result == ACTION_RESULT_CRITICAL_DAMAGE then
        label:SetColor(unpack(FDN.Constants.COLORS.CRIT))
        label:SetScale(1.2)
    else
        label:SetColor(unpack(FDN.Constants.COLORS.OUTGOING))
    end

    local moveY = isIncoming and FDN.Constants.MOVE.DOWN or FDN.Constants.MOVE.UP

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local move = timeline:InsertAnimation(ANIMATION_TRANSLATE, label, 0)
    move:SetTranslateOffsets(0, 0, 0, moveY)
    move:SetDuration(600)

    timeline:SetHandler("OnStop", function()
        label:SetHidden(true)
        label:SetScale(1)
        FDN.Pool.Release(key)
    end)

    timeline:PlayFromStart()
end
