FDN = FDN or {}
FDN.Aggregation = {}

FDN.Aggregation.buckets = {}

local function GetWindow()
    return (FDN.Settings and FDN.Settings.sv and
            FDN.Settings.sv.aggregationWindowMs) or 400
end

local function BuildKey(targetUnitId, category)
    return tostring(targetUnitId) .. ":" .. category
end

function FDN.Aggregation.Add(
    amount,
    result,
    category,
    targetUnitId,
    damageType,
    flushCallback
)
    local now = GetFrameTimeMilliseconds()
    local key = BuildKey(targetUnitId, category)

    local bucket = FDN.Aggregation.buckets[key]

    if not bucket then
        bucket = {
            total = 0,
            result = result,
            category = category,
            targetUnitId = targetUnitId,
            damageType = damageType,
            time = now,
        }

        FDN.Aggregation.buckets[key] = bucket

        zo_callLater(function()
            local b = FDN.Aggregation.buckets[key]
            if not b then return end

            FDN.Aggregation.buckets[key] = nil
            flushCallback(
                b.total,
                b.result,
                b.category,
                b.targetUnitId,
                b.damageType
            )
        end, GetWindow())
    end

    bucket.total = bucket.total + amount
end
