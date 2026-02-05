FDN = FDN or {}

EVENT_MANAGER:RegisterForEvent(
    "FDN_Init",
    EVENT_PLAYER_ACTIVATED,
    function()
        EVENT_MANAGER:UnregisterForEvent("FDN_Init", EVENT_PLAYER_ACTIVATED)

        FDN.Pool.Initialize()

        EVENT_MANAGER:RegisterForEvent(
            "FDN_Combat",
            EVENT_COMBAT_EVENT,
            FDN.Combat.OnCombatEvent
        )

        d("FloatingDamageNumbers v" .. FDN.Version.GetFormatted() .. " by @bluraptor7099 loaded successfully.")

    end
)
