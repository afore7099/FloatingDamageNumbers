FDN = FDN or {}
FDN.Constants = {}

FDN.Constants.POSITION_TTL_MS = 1500

FDN.Constants.COLORS = {
    OUTGOING = {1, 0, 0, 1},
    CRIT     = {1, 0.6, 0, 1},
    INCOMING = {0.7, 0.2, 1, 1},
    HEAL     = {0.2, 1, 0.2, 1},
}

FDN.Constants.MOVE = {
    UP   = -80,
    DOWN = 80,
}

-- Supported ESO damage types
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
