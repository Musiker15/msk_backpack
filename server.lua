ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
        local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_backpack (`identifier` varchar(80) NOT NULL, `bag` longtext DEFAULT NULL, PRIMARY KEY (`identifier`));")

		if createTable.warningStatus < 1 then
			print('^2 Successfully ^3 created ^2 table ^3 msk_backpack ^0')
		end
    end
end)

local setDebug = false
if Config.Debug and Config.BagInventory:match('expand') then
    CreateThread(function()
        while true do
            for k,players in pairs(GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(players)

                if xPlayer and setDebug then
                    debug('DEBUG playerMaxWeight:', players, xPlayer.getMaxWeight())
                end
            end

            Wait(5000)
        end
    end)
end

RegisterServerEvent('msk_backpack:setJoinBag')
AddEventHandler('msk_backpack:setJoinBag', function(itemname, weight)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    debug('Item:', itemname, weight)
    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + weight)
end)

RegisterServerEvent('msk_backpack:setDeathStatus')
AddEventHandler('msk_backpack:setDeathStatus', function(isDead)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if isDead then
        debug('Player is dead, reset InvSpace and Backpack')
        if Config.BagInventory:match('expand') then
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
        elseif Config.BagInventory:match('secondary') then
            local currentBag = MySQL.query.await('SELECT * FROM msk_backpack WHERE identifier = @identifier', { 
                ["@identifier"] = xPlayer.identifier
            })

            MySQL.query.await('DELETE FROM msk_backpack WHERE identifier = @identifier', { 
                ['@identifier'] = xPlayer.identifier
            })
            MySQL.update.await('UPDATE inventories SET data = @data WHERE type = @type AND identifier = @identifier', { 
                ['@identifier'] = xPlayer.identifier,
                ['@type'] = currentBag[1].bag,
                ['@data'] = '[]',
            })
        end
        xPlayer.triggerEvent('msk_backpack:delBackpackDeath')
    end
end)

for kbag, vbag in pairs(Config.Backpacks) do
    ESX.RegisterUsableItem(kbag, function(source)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        if Config.BagInventory:match('expand') then
            debug('playerMaxWeight before add bag:', xPlayer.source, xPlayer.getMaxWeight())
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + vbag.weight)
        end

        MySQL.query('SELECT bag FROM msk_backpack WHERE identifier = @identifier', { 
            ["@identifier"] = xPlayer.identifier
        }, function(result)
            if result[1] and result[1].bag then
                xPlayer.showNotification(_U('has_bag'))
                return
            elseif not result[1] then
                debug('Add Bag into Database', xPlayer.identifier, kbag)
                MySQL.query('INSERT INTO msk_backpack (identifier, bag) VALUES (@identifier, @bag)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@bag'] = kbag,
                })
            elseif result[1] and not result[1].bag then
                debug('Add Bag into Database', xPlayer.identifier, kbag)
                MySQL.update("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
                    ["@identifier"] = xPlayer.identifier,
                    ["@bag"] = kbag
                })
            end

            xPlayer.removeInventoryItem(kbag, 1)
            xPlayer.addInventoryItem('nobag', 1)
            TriggerClientEvent('msk_backpack:setBackpack', src, kbag, vbag)
        end)
    end)
end

-- No Bag
ESX.RegisterUsableItem('nobag', function(source)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    local currentBag = MySQL.query.await('SELECT * FROM msk_backpack WHERE identifier = @identifier', { 
        ["@identifier"] = xPlayer.identifier
    })

    if not xPlayer.canCarryItem(currentBag[1].bag, 1) then 
        xPlayer.showNotification(_U('too_heavy'))
        return 
    end

    if Config.ItemsInBag then
        if Config.BagInventory:match('expand') then
            local playerWeight = xPlayer.getWeight()
            debug('NOBAG playerWeight:', xPlayer.source, playerWeight)

            if playerWeight > ESX.GetConfig().MaxWeight then
                xPlayer.showNotification(_U('itemsInBag'))
            else
                TriggerClientEvent('msk_backpack:delBackpack', src)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem(currentBag[1].bag, 1)
            
                if Config.BagInventory:match('expand') then
                    debug('playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
                    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
                end

                MySQL.query.await('DELETE FROM msk_backpack WHERE identifier = @identifier', { 
                    ['@identifier'] = xPlayer.identifier
                })
            end
        else
            if itemsInBag(xPlayer, currentBag[1].bag) then
                debug('Trigger Event itemsInBag(xPlayer)')
                
                TriggerClientEvent('msk_backpack:delBackpack', src)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem(currentBag[1].bag, 1)

                MySQL.query.await('DELETE FROM msk_backpack WHERE identifier = @identifier', { 
                    ['@identifier'] = xPlayer.identifier
                })
            else
                debug('Trigger Notification itemsInBag')
                xPlayer.showNotification(_U('itemsInBag'))
            end
        end
    else
        TriggerClientEvent('msk_backpack:delBackpack', src)
        xPlayer.removeInventoryItem('nobag', 1)
        xPlayer.addInventoryItem(currentBag[1].bag, 1)
    
        if Config.BagInventory:match('expand') then
            debug('playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
        end
        
        MySQL.update("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
            ["@identifier"] = xPlayer.identifier,
            ["@bag"] = NULL
        })
    end
end)

RegisterServerEvent('msk_backpack:save')
AddEventHandler('msk_backpack:save', function(skin)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	MySQL.update('UPDATE users SET skin = @skin WHERE identifier = @identifier', {
		['@skin'] = json.encode(skin),
		['@identifier'] = xPlayer.identifier
	})
end)

ESX.RegisterServerCallback('msk_backpack:getPlayerSkin', function(source, cb, playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	MySQL.query('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user, skin = users[1]

		if user.skin then
			skin = json.decode(user.skin)
		end

		cb(skin)
	end)
end)

function setPlayerBag(xPlayer, weight)
    if xPlayer then
        debug('setPlayerBag:', weight)
        CreateThread(function()
            while true do
                Wait(0)
                xPlayer.setMaxWeight(weight)
            end
        end)
    end
end

function itemsInBag(xPlayer, currentBag)
    local result = MySQL.query.await("SELECT * FROM inventories WHERE identifier = @identifier AND type = @type", { 
        ['@identifier'] = xPlayer.identifier,
        ['@type'] = currentBag
    })

    if result[1] then
        debug('identifier: ' .. result[1].identifier)
        debug('type: ' .. result[1].type)
        debug('data: ' .. result[1].data)

        if result[1].data == '[]' then
            debug('Bag is empty')
            return true
        else
            debug('Items in Bag')
            return false
        end
    else 
        debug('result not found')
        return true
    end
end

---- Chezza Inventory ----
RegisterNetEvent('msk_backpack:updateStealInventoryBag')
AddEventHandler('msk_backpack:updateStealInventoryBag', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

    tPlayer.showNotification(xPlayer.name .. _U('someone_searching'))
    xPlayer.showNotification(_U('you_searching') .. tPlayer.name)
end)

-- Callbacks -- 
ESX.RegisterServerCallback('msk_backpack:getTargetData', function(source, cb, target)
    local tPlayer = ESX.GetPlayerFromId(target)

	cb(tPlayer.name, tPlayer.identifier)
end)

ESX.RegisterServerCallback('msk_backpack:getUserData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.name, xPlayer.identifier)
end)
---- Chezza Inventory ----

function debug(msg, msg2, msg3)
	if Config.Debug then
        if msg3 then
            print(msg, msg2, msg3)
        elseif not msg3 and msg2 then
            print(msg, msg2)
        else
		    print(msg)
        end
	end
end

---- GitHub Updater ----
function GetCurrentVersion()
	return GetResourceMetadata(GetCurrentResourceName(), "version")
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"

if Config.VersionChecker then
	PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/msk_backpack/main/VERSION', function(Error, NewestVersion, Header)
		print("###############################")
    	if CurrentVersion == NewestVersion then
	    	print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
    	elseif CurrentVersion ~= NewestVersion then
        	print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
	    	print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/msk_backpack/releases/tag/v'.. NewestVersion .. '^0')
    	end
		print("###############################")
	end)
else
	print("###############################")
	print(resourceName .. '^2 ✓ Resource loaded^0')
	print("###############################")
end
