ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('openbag', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent('inventory:openInventoryBag', source, xPlayer.getName(source), xPlayer.getIdentifier(source))
end, false)
    
RegisterCommand('stealbag', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerClientEvent('inventory:stealInventoryBag', source)
end, false)
    
RegisterNetEvent('inventory:updateStealInventoryBag')
AddEventHandler('inventory:updateStealInventoryBag', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent('esx:showNotification', target, ''..xPlayer.getName(source)..' durchsucht deine Tasche' )
    TriggerClientEvent('esx:showNotification', source, 'Du durchsuchst die Tasche von: '..tPlayer.getName(target)..'' )
    TriggerClientEvent('inventory:openInventoryBag', source, tPlayer.getName(target), tPlayer.getIdentifier(target))
end)