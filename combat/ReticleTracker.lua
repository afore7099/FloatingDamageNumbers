FDN = FDN or {}
FDN.Reticle = {}

FDN.Reticle.lastX = nil
FDN.Reticle.lastY = nil

EVENT_MANAGER:RegisterForEvent(
    "FDN_Reticle",
    EVENT_RETICLE_TARGET_CHANGED,
    function()
        if not DoesUnitExist("reticleover") then return end

        local x, y, z = GetUnitWorldPosition("reticleover")
        if not x then return end

        local guiX, guiY = WorldPositionToGuiRender3DPosition(x, y, z)
        if guiX and guiY then
            FDN.Reticle.lastX = guiX
            FDN.Reticle.lastY = guiY
        end
    end
)
