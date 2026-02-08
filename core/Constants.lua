FDN = FDN or {}
FDN.Constants = {}

FDN.Constants.COLORS = {
    OUTGOING = {1, 0, 0, 1},
    CRIT     = {1, 0.6, 0, 1},
    INCOMING = {0.7, 0.2, 1, 1},
    HEAL     = {0.2, 1, 0.2, 1},          -- fallback heal
    INCOMING_HEAL = {0.4, 1, 0.7, 1},
    OUTGOING_HEAL = {0.2, 0.9, 0.4, 1},
}

FDN.Constants.MOVE = {
    UP   = -80,
    DOWN = 80,
}

FDN.Constants.DAMAGE_TYPES = {
    [DAMAGE_TYPE_PHYSICAL] = "Physical",
    [DAMAGE_TYPE_FIRE]     = "Fire",
    [DAMAGE_TYPE_SHOCK]    = "Shock",
    [DAMAGE_TYPE_OBLIVION] = "Oblivion",
    [DAMAGE_TYPE_COLD]     = "Frost",
    [DAMAGE_TYPE_POISON]   = "Poison",
    [DAMAGE_TYPE_DISEASE]  = "Disease",
    [DAMAGE_TYPE_MAGIC]    = "Magic",
    [DAMAGE_TYPE_BLEED]    = "Bleed",
}

FDN.Constants.FONTS = {
    ["Game Default"] = "ZoFontGame",
    ["Game Bold"]    = "ZoFontGameBold",
    ["Antique"]      = "ZoFontAntique",
    ["Chat"]         = "ZoFontChat",
    ["Alert"]        = "ZoFontAlert",
}

FDN.Constants.CATEGORY = {
    INCOMING_DAMAGE = "INCOMING_DAMAGE",
    OUTGOING_DAMAGE = "OUTGOING_DAMAGE",
    INCOMING_HEAL   = "INCOMING_HEAL",
    OUTGOING_HEAL   = "OUTGOING_HEAL",
}

