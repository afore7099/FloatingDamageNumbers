FDN = FDN or {}
FDN.Aggregation = {}

-- Active buckets
FDN.Aggregation.buckets = {}

-- How long to aggregate before flushing (ms)
local AGGREGATION_WINDOW_MS = 400

-- ============================================================================
-- Internal: build aggregation key
-- ============================================================================
local function BuildKey(targetUnitId, category)
    return string.format("%s:%s", tostring(targetUnitId), category)
end

-- ============================================================================
-- Add a value to aggregation
-- ============================================================================
function FDN.Aggregation.Add(
    amount,
    result,
    category,
    targetUnitId,
    flushCallback
)
    local now = GetFrameTimeMilliseconds()
    local key = BuildKey(targetUnitId, category)

    local bucket = FDN.Aggregation.buckets[key]

    if not bucket then
        bucket = {
            total = 0,
            lastUpdate = now,
            result = result,
            targetUnitId = targetUnitId,
            category = category,
        }
        FDN.Aggregation.buckets[key] = bucket

        -- Schedule flush
        zo_callLater(function()
            local b = FDN.Aggregation.buckets[key]
            if not b then return end

            FDN.Aggregation.buckets[key] = nil
            flushCallback(
                b.total,
                b.result,
                b.category,
                b.targetUnitId
            )
        end, AGGREGATION_WINDOW_MS)
    end

    bucket.total = bucket.total + amount
    bucket.lastUpdate = now
end
