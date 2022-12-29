ESX = exports["es_extended"]:getSharedObject()
MSK = exports.msk_core:getCoreObject()

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= 'msk_backpack' then
        print('^1Please rename the Script to ^3msk_backpack^0!')
        print('^1Server will be shutdown^0!')
        os.exit()
    end

    if GetCurrentResourceName() == resource then
        local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_backpack (`identifier` varchar(80) NOT NULL, `bag` longtext DEFAULT NULL, PRIMARY KEY (`identifier`));")

		if createTable.warningStatus == 0 then
			print('^2 Successfully ^3 created ^2 table ^3 msk_backpack ^0')
		end
    end
end)

local setDebug = false
if Config.Debug and Config.BagInventory:match('expand') and setDebug then
    CreateThread(function()
        while true do
            for k, players in pairs(GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(players)

                if xPlayer then
                    logging('debug', 'DEBUG playerMaxWeight:', xPlayer.source, xPlayer.getMaxWeight())
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

    logging('debug', 'Item:', itemname, weight)
    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + weight)
end)

RegisterServerEvent('msk_backpack:setDeathStatus')
AddEventHandler('msk_backpack:setDeathStatus', function(isDead)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if isDead then
        logging('debug', 'Player is dead, reset InvSpace and Backpack')
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
            logging('debug', 'playerMaxWeight before add bag:', xPlayer.source, xPlayer.getMaxWeight())
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + vbag.weight)
        end

        MySQL.query('SELECT bag FROM msk_backpack WHERE identifier = @identifier', { 
            ["@identifier"] = xPlayer.identifier
        }, function(result)
            if result[1] and result[1].bag then
                xPlayer.showNotification(_U('has_bag'))
                return
            elseif not result[1] then
                logging('debug', 'Add Bag into Database', xPlayer.identifier, kbag)
                MySQL.query('INSERT INTO msk_backpack (identifier, bag) VALUES (@identifier, @bag)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@bag'] = kbag,
                })
            elseif result[1] and not result[1].bag then
                logging('debug', 'Add Bag into Database', xPlayer.identifier, kbag)
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
            logging('debug', 'NOBAG playerWeight:', xPlayer.source, playerWeight)

            if playerWeight > ESX.GetConfig().MaxWeight then
                xPlayer.showNotification(_U('itemsInBag'))
            else
                TriggerClientEvent('msk_backpack:delBackpack', src)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem(currentBag[1].bag, 1)
            
                if Config.BagInventory:match('expand') then
                    logging('debug', 'playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
                    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
                end

                MySQL.query.await('DELETE FROM msk_backpack WHERE identifier = @identifier', { 
                    ['@identifier'] = xPlayer.identifier
                })
            end
        else
            if itemsInBag(xPlayer, currentBag[1].bag) then
                logging('debug', 'Trigger Event itemsInBag(xPlayer)')
                
                TriggerClientEvent('msk_backpack:delBackpack', src)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem(currentBag[1].bag, 1)

                MySQL.query.await('DELETE FROM msk_backpack WHERE identifier = @identifier', { 
                    ['@identifier'] = xPlayer.identifier
                })
            else
                logging('debug', 'Trigger Notification itemsInBag')
                xPlayer.showNotification(_U('itemsInBag'))
            end
        end
    else
        TriggerClientEvent('msk_backpack:delBackpack', src)
        xPlayer.removeInventoryItem('nobag', 1)
        xPlayer.addInventoryItem(currentBag[1].bag, 1)
    
        if Config.BagInventory:match('expand') then
            logging('debug', 'playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
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

MSK.RegisterCallback('msk_backpack:getPlayerSkin', function(source, cb, playerId)
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

setPlayerBag = function(xPlayer, weight)
    if xPlayer then
        logging('debug', 'setPlayerBag:', weight)
        CreateThread(function()
            while true do
                Wait(0)
                xPlayer.setMaxWeight(weight)
            end
        end)
    end
end

itemsInBag = function(xPlayer, currentBag)
    local result = MySQL.query.await("SELECT * FROM inventories WHERE identifier = @identifier AND type = @type", { 
        ['@identifier'] = xPlayer.identifier,
        ['@type'] = currentBag
    })

    if result[1] then
        logging('debug', 'identifier: ' .. result[1].identifier)
        logging('debug', 'type: ' .. result[1].type)
        logging('debug', 'data: ' .. result[1].data)

        if result[1].data == '[]' then
            logging('debug', 'Bag is empty')
            return true
        else
            logging('debug', 'Items in Bag')
            return false
        end
    else 
        logging('debug', 'result not found')
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
MSK.RegisterCallback('msk_backpack:getTargetData', function(source, cb, target)
    local tPlayer = ESX.GetPlayerFromId(target)

	cb(tPlayer.name, tPlayer.identifier)
end)

MSK.RegisterCallback('msk_backpack:getUserData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.name, xPlayer.identifier)
end)
---- Chezza Inventory ----

MSK.RegisterCallback('msk_backpack:hasBag', function(source, cb, player)
    cb(hasBag(player))
end)

hasBag = function(player)
    local xPlayer 
    if player.source then
        xPlayer = ESX.GetPlayerFromId(player.source)
    elseif player.identifier then
        xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)
    elseif player.player then 
        xPlayer = player.player
    end

    local data = MySQL.query.await("SELECT * FROM msk_backpack WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier})

    if data and data[1] and data[1].bag then
        return data[1].bag
    end
    return false
end
exports('hasBag', hasBag)


logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
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
                print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here:^9 https://github.com/Musiker15/msk_backpack/releases/tag/v'.. NewestVersion .. '^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0')
        print("###############################")
    end
end
GithubUpdater()