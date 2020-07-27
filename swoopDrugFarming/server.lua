local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| PLANT PLANTS

-- || Stage 0 -> not seeded
-- || Stage 1 -> seeded
-- || Stage 2 -> growing (prop_weed_02)
-- || Stage 3 -> Almost finish (prop_weed_01)
-- || Stage 4 -> Finished

-- || Stage timers
local plantTimers = { stage1 = 10, stage2 = 90, stage3 = 300 }

-- || Current planted plants
local plants = {}

RegisterServerEvent('addPlant')
AddEventHandler('addPlant', function(spot)
    if spot ~= nil then
        local spotAlreadyExists = false
        for key,value in pairs(plants) do
            if value.id == spot then
                spotAlreadyExists = true
            end
        end
        if not spotAlreadyExists then
            table.insert(plants, { id = spot, stage = 1, timeLeft = plantTimers.stage1 })
            TriggerClientEvent('acceptPlantAdding', source, spot)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for key,value in pairs(plants) do
            --print("SPOT: " .. value.id .. " | " .. value.timeLeft .. " -> " .. value.stage)
            if value.timeLeft > 0 then -- || If timer ain't finished -> substract 1 from timer
                value.timeLeft = value.timeLeft - 1
            elseif value.timeLeft <= 0 then
                if value.stage == 1 then
                    value.stage = 2 -- || Change stage to stage 2
                    value.timeLeft = plantTimers.stage2 -- || Change timer to stage 2 timer
                    --TriggerClientEvent('placePlant', -1, value.id, "prop_weed_02") -- || Place plant prop_weed_02 in world
                elseif value.stage == 2 then
                    value.stage = 3 -- || Change stage to stage 3
                    value.timeLeft = plantTimers.stage3 -- || Change timer to stage 3 timer
                    --TriggerClientEvent('replacePlant', -1, value.id, "prop_weed_02", "prop_weed_01") -- || Replace prop_weed_02 with prop_weed_01 in world
                elseif value.stage == 3 then
                    value.stage = 4 -- || Change stage to stage 4
                    TriggerClientEvent('getFinishedPlantInformation', -1, value.id) -- || Return finished plant to clients 
                end
            end
            TriggerClientEvent('getPlantInformation', -1, value.id, value.stage, value.timeLeft) -- || Return finished plant to clients 
        end
    end
end)

RegisterServerEvent('takeFinishedPlant')
AddEventHandler('takeFinishedPlant', function(spot)
    if spot ~= nil then
        for key,value in pairs(plants) do
            if value.id == spot then
                if value.stage == 4 then
                    TriggerClientEvent('getPlantInformation', -1, value.id, 0, 0) -- || Return finished plant to clients 
                    TriggerClientEvent('removePlant', -1, value.id, "prop_weed_01") -- || Send remove data to clients
                    TriggerClientEvent('acceptPlantRemoval', source)
                    table.remove(plants, key) -- || Remove in plants table
                end
            end
        end
    end
end)


RegisterServerEvent('checkAmountOfSeedsInPlayerInventory')
AddEventHandler('checkAmountOfSeedsInPlayerInventory', function(item)
    local userID = vRP.getUserId({source})
    local itemAmount = vRP.getInventoryItemAmount({userID, item})
    TriggerClientEvent('getAmountOfSeedsInPlayerInventory', source, itemAmount)
end)

-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| TRIM PLANT

RegisterServerEvent('checkAmountOfPlantsInPlayerInventory')
AddEventHandler('checkAmountOfPlantsInPlayerInventory', function(item)
    local userID = vRP.getUserId({source})
    local itemAmount = vRP.getInventoryItemAmount({userID, item})
    TriggerClientEvent('getAmountOfPlantsInPlayerInventory', source, itemAmount)
end)


-- ||||||||||||||||||| BOTH

RegisterServerEvent('giveItemToPlayer')
AddEventHandler('giveItemToPlayer', function(item, amount)
    local userID = vRP.getUserId({source})
    vRP.giveInventoryItem({userID, item, amount, true})
end)

RegisterServerEvent('takeItemFromInventory')
AddEventHandler('takeItemFromInventory', function(item, amount)
    local userID = vRP.getUserId({source})
    vRP.tryGetInventoryItem({userID, item, amount, true})
end)