FDN = FDN or {}

EVENT_MANAGER:RegisterForEvent(
    "FDN_Init",
    EVENT_PLAYER_ACTIVATED,
    function()
        EVENT_MANAGER:UnregisterForEvent("FDN_Init", EVENT_PLAYER_ACTIVATED)

        -- Initialize systems
        FDN.Pool.Initialize()
        FDN.Settings.Initialize()

        -- IMPORTANT: no source/target filters here
        EVENT_MANAGER:RegisterForEvent(
            "FDN_Combat",
            EVENT_COMBAT_EVENT,
            FDN.Combat.OnCombatEvent
        )

        -- Keep only error filtering
        EVENT_MANAGER:AddFilterForEvent(
            "FDN_Combat",
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_IS_ERROR,
            false
        )

        d("FloatingDamageNumbers v" .. FDN.Version.GetFormatted() .. " by @bluraptor7099 loaded successfully.")
    end
)