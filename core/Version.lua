FDN = FDN or {}
FDN.Version = {}

local function GetAddonIndex()
    for i = 1, GetAddOnManager():GetNumAddOns() do
        local name = GetAddOnManager():GetAddOnInfo(i)
        if name == "FloatingDamageNumbers" then
            return i
        end
    end
end

function FDN.Version.Get()
    local index = GetAddonIndex()
    if not index then
        return "unknown"
    end

    return GetAddOnManager():GetAddOnVersion(index)
end

function FDN.Version.GetFormatted()
    local raw = tonumber(FDN.Version.Get())
    if not raw then return "unknown" end

    local major = math.floor(raw / 100)
    local minor = math.floor((raw % 100) / 10)
    local patch = raw % 10

    return string.format("%d.%d.%d", major, minor, patch)
end

