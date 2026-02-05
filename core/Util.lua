FDN = FDN or {}
FDN.Util = {}

function FDN.Util.IsOnScreen(x, y)
    if not x or not y then return false end
    local w, h = GuiRoot:GetDimensions()
    return x >= 0 and x <= w and y >= 0 and y <= h
end
