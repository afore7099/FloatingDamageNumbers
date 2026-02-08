FDN = FDN or {}

EVENT_MANAGER:RegisterForEvent(
    "FDN_Init",
    EVENT_PLAYER_ACTIVATED,
    function()
        EVENT_MANAGER:UnregisterForEvent("FDN_Init", EVENT_PLAYER_ACTIVATED)

        -- Initialize systems
        FDN.Pool.Initialize()
        FDN.Settings.Initialize()

        -- ============================================================
        -- OUTGOING: player is the SOURCE
        -- ============================================================
        EVENT_MANAGER:RegisterForEvent(
            "FDN_Combat_Out",
            EVENT_COMBAT_EVENT,
            FDN.Combat.OnCombatEventOutgoing
        )

        EVENT_MANAGER:AddFilterForEvent(
            "FDN_Combat_Out",
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )

        EVENT_MANAGER:AddFilterForEvent(
            "FDN_Combat_Out",
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_IS_ERROR,
            false
        )

        -- ============================================================
        -- INCOMING: player is the TARGET
        -- ============================================================
        EVENT_MANAGER:RegisterForEvent(
            "FDN_Combat_In",
            EVENT_COMBAT_EVENT,
            FDN.Combat.OnCombatEventIncoming
        )

        EVENT_MANAGER:AddFilterForEvent(
            "FDN_Combat_In",
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER
        )

        EVENT_MANAGER:AddFilterForEvent(
            "FDN_Combat_In",
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_IS_ERROR,
            false
        )

        d("FloatingDamageNumbers v" .. FDN.Version.GetFormatted() .. " by @bluraptor7099 loaded successfully.")
    end
)