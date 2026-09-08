if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/stolen_parts_dealer.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/stolen_parts_dealer.lua
--  Stolen Vehicle Parts Fence / Dealer Trading
-- =====================================================

local DEFAULT_PRICES = {
    catalytic_converter = { price = 1200, label = "Catalytic Converter" },
    wheels = { price = 250, label = "Wheels" },
    body_kit = { price = 200, label = "Body Kit" },
    engine = { price = 1800, label = "Engine" },
    brakes = { price = 300, label = "Brakes" },
    transmission = { price = 1200, label = "Transmission" },
    suspension = { price = 400, label = "Suspension" },
    spark_plugs = { price = 80, label = "Spark Plugs" },
    air_filter = { price = 90, label = "Air Filter" },
    traction_battery = { price = 2500, label = "Traction Battery" },
    inverter = { price = 1100, label = "Power Inverter" }
}

Sky.Cb.Register("sky_mechanicjob:stolenPartsDealer:sell", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local itemName = tostring(data and data.item or "")
    if itemName == "" then
        -- Sell any stolen item from player inventory if no specific item specified
        for itName, _ in pairs(DEFAULT_PRICES) do
            if Functions.HasItem(src, itName, 1) then
                itemName = itName
                break
            end
        end
    end

    if itemName == "" or not Functions.HasItem(src, itemName, 1) then
        return { success = false, error = "missing_item" }
    end

    local itemConfig = DEFAULT_PRICES[itemName] or { price = 250, label = itemName }
    local price = itemConfig.price
    local label = itemConfig.label

    if not Functions.RemoveItem(src, itemName, 1) then
        return { success = false, error = "missing_item" }
    end

    -- Payout (cash or black money)
    Functions.AddMoney(src, "cash", price)

    return {
        success = true,
        data = {
            amount = 1,
            item = itemName,
            itemLabel = label,
            price = price,
            priceLabel = string.format("$%d", price)
        }
    }
end)
