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
            if Config.Debug then
                print('playerWeight: ' .. xPlayer.getMaxWeight())
                print('esxWeight: ' .. ESX.GetConfig().MaxWeight)
            end

            xPlayer.setMaxWeight(ESX.GetConfig().MaxWeight + Config.BagWeight)

            if Config.Debug then
                print('playerWeight add bag: ' .. xPlayer.getMaxWeight())
            end
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

    if hasBag == 0 then
        TriggerClientEvent('esx_bag:setdelBag', source)
        xPlayer.removeInventoryItem('nobag', 1)
        xPlayer.addInventoryItem("bag", 1)

        if Config.BagInventory then
            if Config.Debug then
                print('playerWeight: ' .. xPlayer.getMaxWeight())
                print('esxWeight: ' .. ESX.GetConfig().MaxWeight)
            end

            xPlayer.setMaxWeight(ESX.GetConfig().MaxWeight)

            if Config.Debug then
                print('playerWeight remove bag: ' .. xPlayer.getMaxWeight())
            end
        end
        
        TriggerClientEvent('esx:showNotification', source, _U('used_nobag'))
    else
        TriggerClientEvent('esx:showNotification', source, _U('had_bag'))
    end
end)

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