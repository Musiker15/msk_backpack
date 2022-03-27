local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_bag:setMaxWeight')
AddEventHandler('esx_bag:setMaxWeight', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.setMaxWeight(ESX.GetConfig().MaxWeight + Config.BagWeight)
    --TriggerClientEvent('inventory:refresh', source)
end)

-- Bag
ESX.RegisterUsableItem('bag', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local hasBag = xPlayer.getInventoryItem('nobag').count
    
    if hasBag == 0 then
        TriggerClientEvent('esx_bag:setBag', source)
        xPlayer.removeInventoryItem('bag', 1)
        xPlayer.addInventoryItem("nobag", 1)

        if Config.BagInventory then
            debug('playerWeight: ' .. xPlayer.getMaxWeight())
            debug('esxWeight: ' .. ESX.GetConfig().MaxWeight)

            xPlayer.setMaxWeight(ESX.GetConfig().MaxWeight + Config.BagWeight)

            debug('playerWeight add bag: ' .. xPlayer.getMaxWeight())
        end

        TriggerClientEvent('esx:showNotification', source, _U('used_bag'))
    else
        TriggerClientEvent('esx:showNotification', source, _U('has_bag'))
    end
end)

-- No Bag
ESX.RegisterUsableItem('nobag', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local hasBag = xPlayer.getInventoryItem('bag').count

    if Config.ItemsInBag then
        if itemsInBag(xPlayer) then
            if hasBag == 0 then
                TriggerClientEvent('esx_bag:setdelBag', source)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem("bag", 1)
        
                if Config.BagInventory then
                    debug('playerWeight: ' .. xPlayer.getMaxWeight())
                    debug('esxWeight: ' .. ESX.GetConfig().MaxWeight)
        
                    xPlayer.setMaxWeight(ESX.GetConfig().MaxWeight)
        
                    debug('playerWeight remove bag: ' .. xPlayer.getMaxWeight())
                end
                
                TriggerClientEvent('esx:showNotification', source, _U('used_nobag'))
            else
                TriggerClientEvent('esx:showNotification', source, _U('had_bag'))
            end
        else
            TriggerClientEvent('esx:showNotification', source, _U('itemsInBag'))
        end
    else
        if hasBag == 0 then
            TriggerClientEvent('esx_bag:setdelBag', source)
            xPlayer.removeInventoryItem('nobag', 1)
            xPlayer.addInventoryItem("bag", 1)
    
            if Config.BagInventory then
                debug('playerWeight: ' .. xPlayer.getMaxWeight())
                debug('esxWeight: ' .. ESX.GetConfig().MaxWeight)
    
                xPlayer.setMaxWeight(ESX.GetConfig().MaxWeight)
    
                debug('playerWeight remove bag: ' .. xPlayer.getMaxWeight())
            end
            
            TriggerClientEvent('esx:showNotification', source, _U('used_nobag'))
        else
            TriggerClientEvent('esx:showNotification', source, _U('had_bag'))
        end
    end
end)

function itemsInBag(xPlayer)
    MySQL.Async.fetchAll("SELECT * FROM inventories WHERE identifier = @identifier AND type = @type", { 
        ['@identifier'] = xPlayer.identifier,
        ['@type'] = 'bag'
        }, function(result)
        if result[1] then
            debug('identifier: ' .. result[1].identifier)
            debug('type: ' .. result[1].type)
            debug('data: ' .. result[1].data)

            if result[1].data ~= '[]' then
                return true
            end
        else 
            debug('result not found')
        end
    end)

    --[[ local result = MySQL.Sync.fetchAll("SELECT * FROM inventories WHERE identifier = @identifier AND type = @type", { 
        ['@identifier'] = xPlayer.identifier,
        ['@type'] = 'bag'
    })
    if result[1] then
        debug('identifier: ' .. result[1].identifier)
        debug('type: ' .. result[1].type)
        debug('data: ' .. result[1].data)
    
        if result[1].data ~= '[]' then
            return true
        end
    else 
        debug('result not found')
    end ]]
    
    return false
end

function debug(msg)
	if Config.Debug then
		print(msg)
	end
end

---- GitHub Updater ----
function GetCurrentVersion()
	return GetResourceMetadata( GetCurrentResourceName(), "version" )
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"

if Config.VersionChecker then
	PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/esx_backpack/main/VERSION', function(Error, NewestVersion, Header)
		print("###############################")
    	if CurrentVersion == NewestVersion then
	    	print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
    	elseif CurrentVersion ~= NewestVersion then
        	print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
	    	print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/esx_backpack/releases/tag/v'.. NewestVersion .. '^0')
    	end
		print("###############################")
	end)
else
	print("###############################")
	print(resourceName .. '^2 ✓ Resource loaded^0')
	print("###############################")
end