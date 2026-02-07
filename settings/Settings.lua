FDN = FDN or {}
FDN.Settings = {}

FDN.Settings.defaults = {
    aggregationEnabled  = true,
    aggregationWindowMs = 400,

    fontName       = "ZoFontGameBold",
    fontSize       = 24,
    animationSpeed = 1.0,

    numberFormattingEnabled  = true,
    numberFormattingPrecision = 1,

    incomingHealColor = {0.4, 1, 0.7, 1},
    outgoingHealColor = {0.2, 0.9, 0.4, 1},

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

        { type = "header", name = "Aggregation" },
        {
            type = "checkbox",
            name = "Enable Aggregation",
            getFunc = function() return FDN.Settings.sv.aggregationEnabled end,
            setFunc = function(v) FDN.Settings.sv.aggregationEnabled = v end,
            default = FDN.Settings.defaults.aggregationEnabled,
        },
        {
            type = "slider",
            name = "Aggregation Window (ms)",
            min = 100,
            max = 1000,
            step = 50,
            getFunc = function() return FDN.Settings.sv.aggregationWindowMs end,
            setFunc = function(v) FDN.Settings.sv.aggregationWindowMs = v end,
            default = FDN.Settings.defaults.aggregationWindowMs,
            disabled = function()
                return not FDN.Settings.sv.aggregationEnabled
            end,
        },

        { type = "header", name = "Text Appearance" },
        {
            type = "dropdown",
            name = "Font",
            choices = (function()
                local t = {}
                for label in pairs(FDN.Constants.FONTS) do
                    table.insert(t, label)
                end
                table.sort(t)
                return t
            end)(),
            getFunc = function()
                for label, font in pairs(FDN.Constants.FONTS) do
                    if font == FDN.Settings.sv.fontName then
                        return label
                    end
                end
            end,
            setFunc = function(label)
                FDN.Settings.sv.fontName = FDN.Constants.FONTS[label]
            end,
            default = "Game Bold",
        },
        {
            type = "slider",
            name = "Font Size",
            min = 12,
            max = 64,
            step = 1,
            getFunc = function() return FDN.Settings.sv.fontSize end,
            setFunc = function(v) FDN.Settings.sv.fontSize = v end,
            default = FDN.Settings.defaults.fontSize,
        },
        {
            type = "slider",
            name = "Animation Speed",
            min = 0.5,
            max = 2.5,
            step = 0.1,
            getFunc = function() return FDN.Settings.sv.animationSpeed end,
            setFunc = function(v) FDN.Settings.sv.animationSpeed = v end,
            default = FDN.Settings.defaults.animationSpeed,
        },

        { type = "header", name = "Number Formatting" },
        {
            type = "checkbox",
            name = "Enable Abbreviated Numbers",
            getFunc = function()
                return FDN.Settings.sv.numberFormattingEnabled
            end,
            setFunc = function(v)
                FDN.Settings.sv.numberFormattingEnabled = v
            end,
            default = FDN.Settings.defaults.numberFormattingEnabled,
        },
        {
            type = "slider",
            name = "Decimal Precision",
            min = 0,
            max = 2,
            step = 1,
            getFunc = function()
                return FDN.Settings.sv.numberFormattingPrecision
            end,
            setFunc = function(v)
                FDN.Settings.sv.numberFormattingPrecision = v
            end,
            default = FDN.Settings.defaults.numberFormattingPrecision,
            disabled = function()
                return not FDN.Settings.sv.numberFormattingEnabled
            end,
        },

        { type = "header", name = "Healing Colors" },
        {
            type = "colorpicker",
            name = "Incoming Healing",
            tooltip = "Color used for healing you receive.",
            getFunc = function()
                local c = FDN.Settings.sv.incomingHealColor
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                FDN.Settings.sv.incomingHealColor = { r, g, b, a }
            end,
            default = FDN.Settings.defaults.incomingHealColor,
        },
        {
            type = "colorpicker",
            name = "Outgoing Healing",
            tooltip = "Color used for healing you cast.",
            getFunc = function()
                local c = FDN.Settings.sv.outgoingHealColor
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                FDN.Settings.sv.outgoingHealColor = { r, g, b, a }
            end,
            default = FDN.Settings.defaults.outgoingHealColor,
        },

        { type = "header", name = "Damage Type Colors" },
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
