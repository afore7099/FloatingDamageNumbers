FDN = FDN or {}
FDN.Settings = {}

local ADDON_NAME = "FloatingDamageNumbers"

FDN.Settings.defaults = {
    aggregationEnabled = true,
    aggregationWindowMs = 400,

    damageTypeColors = {
        [DAMAGE_TYPE_PHYSICAL] = {1, 1, 1, 1},
        [DAMAGE_TYPE_FIRE]     = {1, 0.3, 0.1, 1},
        [DAMAGE_TYPE_SHOCK]    = {0.6, 0.6, 1, 1},
        [DAMAGE_TYPE_OBLIVION] = {0.7, 0.2, 0.9, 1},
        [DAMAGE_TYPE_COLD]     = {0.4, 0.8, 1, 1},
        [DAMAGE_TYPE_POISON]   = {0.3, 0.8, 0.3, 1},
        [DAMAGE_TYPE_DISEASE]  = {0.6, 0.5, 0.2, 1},
        [DAMAGE_TYPE_MAGIC]    = {0.9, 0.9, 0.6, 1},
        [DAMAGE_TYPE_BLEED]    = {0.8, 0.1, 0.1, 1},
    },
}

FDN.Settings.sv = nil

function FDN.Settings.Initialize()
    FDN.Settings.sv = ZO_SavedVars:NewAccountWide(
        "FDN_SavedVariables",
        1,
        nil,
        FDN.Settings.defaults
    )

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Floating Damage Numbers",
        displayName = "Floating Damage Numbers",
        author = "@bluraptor7099",
        version = FDN.Version.GetFormatted(),
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
        {
            type = "header",
            name = "Damage Type Colors",
        },
    }

    for damageType, name in pairs(FDN.Constants.DAMAGE_TYPES) do
        table.insert(optionsTable, {
            type = "colorpicker",
            name = name .. " Damage",
            getFunc = function()
                local c = FDN.Settings.sv.damageTypeColors[damageType]
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                FDN.Settings.sv.damageTypeColors[damageType] = { r, g, b, a }
            end,
            default = FDN.Settings.defaults.damageTypeColors[damageType],
        })
    end

    LAM:RegisterOptionControls("FDN_SettingsPanel", optionsTable)
end
