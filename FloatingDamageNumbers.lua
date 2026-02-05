FloatingDamageNumbers = {}
FloatingDamageNumbers.name = "FloatingDamageNumbers"
FloatingDamageNumbers.pool = nil

-- Per-enemy position cache
FloatingDamageNumbers.unitPositions = {}

-- Last known reticle screen position
FloatingDamageNumbers.lastReticleX = nil
FloatingDamageNumbers.lastReticleY = nil

-- How long a cached position is valid (ms)
local POSITION_TTL_MS = 1500

d("=== FloatingDamageNumbers IOH TEST LOADED ===")

-- ============================================================================
-- Helpers
-- ============================================================================
local function IsOnScreen(x, y)
    if not x or not y then return false end
    local w, h = GuiRoot:GetDimensions()
    return x >= 0 and x <= w and y >= 0 and y <= h
end

-- ============================================================================
-- Reticle tracking (cache last valid screen-space position)
-- ============================================================================
EVENT_MANAGER:RegisterForEvent(
    FloatingDamageNumbers.name .. "_Reticle",
    EVENT_RETICLE_TARGET_CHANGED,
    function()
        if not DoesUnitExist("reticleover") then return end

        local x, y, z = GetUnitWorldPosition("reticleover")
        if not x then return end

        local guiX, guiY = WorldPositionToGuiRender3DPosition(x, y, z)
        if guiX and guiY then
            FloatingDamageNumbers.lastReticleX = guiX
            FloatingDamageNumbers.lastReticleY = guiY
        end
    end
)

-- ============================================================================
-- Combat Event Handler
-- ============================================================================
local function OnCombatEvent(
    eventCode,
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
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

    local isOutgoing = sourceType == COMBAT_UNIT_TYPE_PLAYER
    local isIncoming = targetType == COMBAT_UNIT_TYPE_PLAYER

    -- Seed per-enemy position for outgoing damage
    if isOutgoing and FloatingDamageNumbers.lastReticleX and FloatingDamageNumbers.lastReticleY then
        FloatingDamageNumbers.unitPositions[targetUnitId] = {
            x = FloatingDamageNumbers.lastReticleX,
            y = FloatingDamageNumbers.lastReticleY,
            t = GetFrameTimeMilliseconds()
        }
    end

    FloatingDamageNumbers.ShowFloatingNumber(
        hitValue,
        result,
        targetUnitId,
        isOutgoing,
        isIncoming,
        isHeal
    )
end

-- ============================================================================
-- SAFE INITIALIZATION
-- ============================================================================
local function TryInitialize()
    if not FloatingDamageNumbersRoot then
        zo_callLater(TryInitialize, 50)
        return
    end

    if FloatingDamageNumbers.pool then
        return
    end

    FloatingDamageNumbers.pool = ZO_ControlPool:New(
        "FloatingDamageNumbersLabelTemplate",
        FloatingDamageNumbersRoot,
        "FloatingLabel"
    )

    EVENT_MANAGER:RegisterForEvent(
        FloatingDamageNumbers.name,
        EVENT_COMBAT_EVENT,
        OnCombatEvent
    )

    d("=== FloatingDamageNumbers INITIALIZED ===")
end

EVENT_MANAGER:RegisterForEvent(
    FloatingDamageNumbers.name,
    EVENT_PLAYER_ACTIVATED,
    function()
        EVENT_MANAGER:UnregisterForEvent(
            FloatingDamageNumbers.name,
            EVENT_PLAYER_ACTIVATED
        )
        TryInitialize()
    end
)

-- ============================================================================
-- FLOATING NUMBER DISPLAY (IOH)
-- ============================================================================
function FloatingDamageNumbers.ShowFloatingNumber(
    amount,
    result,
    targetUnitId,
    isOutgoing,
    isIncoming,
    isHeal
)
    local pool = FloatingDamageNumbers.pool
    if not pool then return end

    local label, key = pool:AcquireObject()

    -- FULL RESET
    label:SetHidden(false)
    label:SetAlpha(1)
    label:SetScale(1)
    label:SetDimensions(200, 50)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLevel(200)
    label:ClearAnchors()

    -- Determine position
    local pos = FloatingDamageNumbers.unitPositions[targetUnitId]
    if pos and (GetFrameTimeMilliseconds() - pos.t) > POSITION_TTL_MS then
        pos = nil
    end

    if isOutgoing and pos and IsOnScreen(pos.x, pos.y) then
        label:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            pos.x + math.random(-20, 20),
            pos.y
        )
    else
        label:SetAnchor(CENTER, GuiRoot, CENTER)
    end

    -- Text
    label:SetFont("ZoFontGameBold")
    label:SetText(tostring(amount))

    -- Styling
    local moveOffsetY = -80

    if isHeal then
        label:SetColor(0.2, 1, 0.2, 1)
        moveOffsetY = -80
    elseif isIncoming then
        label:SetColor(0.7, 0.2, 1, 1)
        moveOffsetY = 80
    elseif result == ACTION_RESULT_CRITICAL_DAMAGE then
        label:SetColor(1, 0.6, 0, 1)
        label:SetScale(1.2)
    else
        label:SetColor(1, 0, 0, 1)
    end

    -- Animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local move = timeline:InsertAnimation(
        ANIMATION_TRANSLATE,
        label,
        0
    )
    move:SetTranslateOffsets(0, 0, 0, moveOffsetY)
    move:SetDuration(600)

    timeline:SetHandler("OnStop", function()
        label:SetHidden(true)
        label:SetScale(1)
        pool:ReleaseObject(key)
    end)

    timeline:PlayFromStart()
end
