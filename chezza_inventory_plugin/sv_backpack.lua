ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    
RegisterNetEvent('inventory:updateStealInventoryBag')
AddEventHandler('inventory:updateStealInventoryBag', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent('esx:showNotification', target, ''..xPlayer.getName(source)..' durchsucht deine Tasche' )
    TriggerClientEvent('esx:showNotification', source, 'Du durchsuchst die Tasche von: '..tPlayer.getName(target)..'' )
end)

-- Callbacks -- 
ESX.RegisterServerCallback('inventory:getTargetData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

	cb(tPlayer.getName(target), tPlayer.getIdentifier(target))
end)

ESX.RegisterServerCallback('inventory:getUserData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getName(), xPlayer.getIdentifier())
end)