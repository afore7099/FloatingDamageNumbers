FDN = FDN or {}
FDN.Util = {}

function FDN.Util.IsOnScreen(x, y)
    if not x or not y then return false end
    local w, h = GuiRoot:GetDimensions()
    return x >= 0 and x <= w and y >= 0 and y <= h
end

-- Number Formatting
function FDN.Util.FormatNumber(value, precision)
    precision = precision or 1
    local absValue = math.abs(value)

    if absValue >= 1e9 then
        return string.format("%." .. precision .. "fB", value / 1e9)
    elseif absValue >= 1e6 then
        return string.format("%." .. precision .. "fM", value / 1e6)
    elseif absValue >= 1e3 then
        return string.format("%." .. precision .. "fK", value / 1e3)
    else
        return tostring(value)
    end
end
