ESX = exports["es_extended"]:getSharedObject()

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
    local xPlayer = ESX.GetPlayerFromId(source)

    debug('Item:', itemname, weight)
    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + weight)
end)

RegisterServerEvent('msk_backpack:setDeathStatus')
AddEventHandler('msk_backpack:setDeathStatus', function(isDead)
    local xPlayer = ESX.GetPlayerFromId(source)

    if isDead then
        debug('Player is dead, reset InvSpace and Backpack')
        TriggerClientEvent('msk_backpack:delBackpackDeath', source)

        if Config.BagInventory:match('expand') then
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
        elseif Config.BagInventory:match('secondary') then
            local currentBag = MySQL.Sync.fetchAll('SELECT * FROM msk_backpack WHERE identifier = @identifier', { 
                ["@identifier"] = xPlayer.identifier
            })

            MySQL.Sync.execute("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
                ["@identifier"] = xPlayer.identifier,
                ["@bag"] = NULL
            })
            MySQL.Sync.execute('UPDATE inventories SET data = @data WHERE type = @type AND identifier = @identifier', { 
                ['@identifier'] = xPlayer.identifier,
                ['@type'] = currentBag[1].bag,
                ['@data'] = '[]',
            })
        end

    end
end)

for kbag, vbag in pairs(Config.Backpacks) do
    ESX.RegisterUsableItem(kbag, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)

        if Config.BagInventory:match('expand') then
            debug('playerMaxWeight before add bag:', xPlayer.source, xPlayer.getMaxWeight())
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + vbag.weight)
        end

        MySQL.Async.fetchAll('SELECT bag FROM msk_backpack WHERE identifier = @identifier', { 
            ["@identifier"] = xPlayer.identifier
        }, function(result)
            if result[1] and result[1].bag then
                xPlayer.showNotification(_U('has_bag'))
                return
            elseif not result[1] then
                debug('Add Bag into Database', xPlayer.identifier, kbag)
                MySQL.Async.execute('INSERT INTO msk_backpack (identifier, bag) VALUES (@identifier, @bag)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@bag'] = kbag,
                })
            elseif result[1] and not result[1].bag then
                debug('Add Bag into Database', xPlayer.identifier, kbag)
                MySQL.Async.execute("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
                    ["@identifier"] = xPlayer.identifier,
                    ["@bag"] = kbag
                })
            end

            xPlayer.removeInventoryItem(kbag, 1)
            xPlayer.addInventoryItem('nobag', 1)
            TriggerClientEvent('msk_backpack:setBackpack', source, kbag, vbag)
        end)
    end)
end

-- No Bag
ESX.RegisterUsableItem('nobag', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local currentBag = MySQL.Sync.fetchAll('SELECT * FROM msk_backpack WHERE identifier = @identifier', { 
        ["@identifier"] = xPlayer.identifier
    })

    if Config.ItemsInBag then
        if Config.BagInventory:match('expand') then
            local playerWeight = xPlayer.getWeight()
            debug('NOBAG playerWeight:', xPlayer.source, playerWeight)

            if playerWeight > ESX.GetConfig().MaxWeight then
                xPlayer.showNotification(_U('itemsInBag'))
            else
                TriggerClientEvent('msk_backpack:delBackpack', source)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem(currentBag[1].bag, 1)
            
                if Config.BagInventory:match('expand') then
                    debug('playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
                    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
                end

                MySQL.Async.execute("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
                    ["@identifier"] = xPlayer.identifier,
                    ["@bag"] = NULL
                })
            end
        else
            if itemsInBag(xPlayer, currentBag[1].bag) then
                debug('Trigger Event itemsInBag(xPlayer)')
                
                TriggerClientEvent('msk_backpack:delBackpack', source)
                xPlayer.removeInventoryItem('nobag', 1)
                xPlayer.addInventoryItem(currentBag[1].bag, 1)

                MySQL.Async.execute("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
                    ["@identifier"] = xPlayer.identifier,
                    ["@bag"] = NULL
                })
            else
                debug('Trigger Notification itemsInBag')
                xPlayer.showNotification(_U('itemsInBag'))
            end
        end
    else
        TriggerClientEvent('msk_backpack:delBackpack', source)
        xPlayer.removeInventoryItem('nobag', 1)
        xPlayer.addInventoryItem(currentBag[1].bag, 1)
    
        if Config.BagInventory:match('expand') then
            debug('playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
        end
        
        MySQL.Async.execute("UPDATE msk_backpack SET bag = @bag WHERE identifier = @identifier", {
            ["@identifier"] = xPlayer.identifier,
            ["@bag"] = NULL
        })
    end
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
    local result = MySQL.Sync.fetchAll("SELECT * FROM inventories WHERE identifier = @identifier AND type = @type", { 
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
        return false
    end
end

---- Chezza Inventory ----
RegisterNetEvent('msk_backpack:updateStealInventoryBag')
AddEventHandler('msk_backpack:updateStealInventoryBag', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

    tPlayer.showNotification(xPlayer.getName(source) .. _U('someone_searching'))
    xPlayer.showNotification(_U('you_searching') .. tPlayer.getName(target))
end)

-- Callbacks -- 
ESX.RegisterServerCallback('msk_backpack:getTargetData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tPlayer = ESX.GetPlayerFromId(target)

	cb(tPlayer.getName(target), tPlayer.getIdentifier(target))
end)

ESX.RegisterServerCallback('msk_backpack:getUserData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.getName(), xPlayer.getIdentifier())
end)

ESX.RegisterServerCallback('msk_backpack:getPlayerSkin', function(source, cb, player)
	local xPlayer = ESX.GetPlayerFromId(player)

	MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(users)
		local user, skin = users[1]

		local jobSkin = {
			skin_male   = xPlayer.job.skin_male,
			skin_female = xPlayer.job.skin_female
		}

		if user.skin then
			skin = json.decode(user.skin)
		end

		cb(skin, jobSkin)
	end)
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
