FDN = FDN or {}
FDN.Settings = {}

local ADDON_NAME = "FloatingDamageNumbers"

-- Defaults
FDN.Settings.defaults = {
    aggregationEnabled = true,
    aggregationWindowMs = 400,
}

-- Saved variables reference
FDN.Settings.sv = nil

-- Initialize Settings + Panel
function FDN.Settings.Initialize()
    FDN.Settings.sv = ZO_SavedVars:NewAccountWide(
        "FDN_SavedVariables",
        1,
        nil,
        FDN.Settings.defaults
    )

    local LAM = LibAddonMenu2
    if not LAM then
        d("[FDN] LibAddonMenu-2.0 not found")
        return
    end

    local panelData = {
        type = "panel",
        name = "Floating Damage Numbers",
        displayName = "Floating Damage Numbers",
        author = "@bluraptor7099",
        version = FDN.Version and FDN.Version.GetFormatted() or "unknown",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("FDN_SettingsPanel", panelData)

    local optionsTable = {
        {
            type = "header",
            name = "Aggregation",
        },
        {
            type = "checkbox",
            name = "Enable Aggregation",
            tooltip = "Merge rapid hits and damage-over-time ticks into a single number.",
            getFunc = function()
                return FDN.Settings.sv.aggregationEnabled
            end,
            setFunc = function(value)
                FDN.Settings.sv.aggregationEnabled = value
            end,
            default = FDN.Settings.defaults.aggregationEnabled,
        },
        {
            type = "slider",
            name = "Aggregation Window (ms)",
            tooltip = "How long damage is accumulated before being shown.",
            min = 100,
            max = 1000,
            step = 50,
            getFunc = function()
                return FDN.Settings.sv.aggregationWindowMs
            end,
            setFunc = function(value)
                FDN.Settings.sv.aggregationWindowMs = value
            end,
            default = FDN.Settings.defaults.aggregationWindowMs,
            disabled = function()
                return not FDN.Settings.sv.aggregationEnabled
            end,
        },
    }

    LAM:RegisterOptionControls("FDN_SettingsPanel", optionsTable)
end
