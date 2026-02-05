FDN = FDN or {}
FDN.Pool = {}

FDN.Pool.pool = nil

function FDN.Pool.Initialize()
    if FDN.Pool.pool then return end

    FDN.Pool.pool = ZO_ControlPool:New(
        "FloatingDamageNumbersLabelTemplate",
        FloatingDamageNumbersRoot,
        "FloatingLabel"
    )
end

function FDN.Pool.Acquire()
    local label, key = FDN.Pool.pool:AcquireObject()

    label:SetHidden(false)
    label:SetAlpha(1)
    label:SetScale(1)
    label:SetDimensions(200, 50)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLevel(200)
    label:ClearAnchors()

    return label, key
end

function FDN.Pool.Release(key)
    FDN.Pool.pool:ReleaseObject(key)
end
