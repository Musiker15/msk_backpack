local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local currentBag = nil
local setDebug = false

if Config.Debug and Config.BagInventory:match('expand') then
    Citizen.CreateThread(function()
        while true do
            for k,players in pairs(GetPlayers()) do
                local xPlayer = ESX.GetPlayerFromId(players)

                if xPlayer and setDebug then
                    print('DEBUG playerMaxWeight:', players, xPlayer.getMaxWeight())
                end
            end

            Citizen.Wait(5000)
        end
    end)
end

RegisterServerEvent('msk_backpack:setJoinBag')
AddEventHandler('msk_backpack:setJoinBag', function(itemname, weight)
    local xPlayer = ESX.GetPlayerFromId(source)

    debug('itemname', itemname, weight)
    currentBag = itemname
    setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + weight)
end)

RegisterServerEvent('msk_backpack:setDeathStatus')
AddEventHandler('msk_backpack:setDeathStatus', function(isDead)
    local xPlayer = ESX.GetPlayerFromId(source)

    if isDead then
        debug('Player is dead, reset InvSpace and Backpack')
        TriggerClientEvent('msk_backpack:delBackpack', source)

        if Config.BagInventory:match('expand') then
            setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
        elseif Config.BagInventory:match('secondary') then
            MySQL.Sync.execute('UPDATE inventories SET data = @data WHERE type = @type AND identifier = @identifier', { 
                ['@identifier'] = xPlayer.identifier,
                ['@type'] = currentBag,
                ['@data'] = '[]',
            })
        end
        currentBag = nil
    end
end)

for kbag, vbag in pairs(Config.Backpacks) do
    ESX.RegisterUsableItem(kbag, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local hasBag = xPlayer.getInventoryItem('nobag')

        if hasBag.count == 0 then
            xPlayer.removeInventoryItem(kbag, 1)
            xPlayer.addInventoryItem('nobag', 1)

            if Config.BagInventory:match('expand') then
                debug('playerMaxWeight before add bag:', xPlayer.source, xPlayer.getMaxWeight())
                setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight + vbag.weight)
            end

            currentBag = kbag
            TriggerClientEvent('msk_backpack:setBackpack', source, kbag, vbag)
            xPlayer.showNotification(_U('used_bag'))
        else
            xPlayer.showNotification(_U('has_bag'))
        end
    end)
end

-- No Bag
ESX.RegisterUsableItem('nobag', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local hasBag = xPlayer.getInventoryItem(currentBag).count

    if Config.ItemsInBag then
        if Config.BagInventory:match('expand') then
            local playerWeight = xPlayer.getWeight()
            debug('NOBAG playerWeight:', xPlayer.source, playerWeight)

            if playerWeight > ESX.GetConfig().MaxWeight then
                xPlayer.showNotification(_U('itemsInBag'))
            else
                if hasBag == 0 then
                    TriggerClientEvent('msk_backpack:delBackpack', source)
                    xPlayer.removeInventoryItem('nobag', 1)
                    xPlayer.addInventoryItem(currentBag, 1)
            
                    if Config.BagInventory:match('expand') then
                        debug('playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
                        setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
                    end
                    
                    currentBag = nil
                    xPlayer.showNotification(_U('used_nobag'))
                else
                    xPlayer.showNotification(_U('had_bag'))
                end
            end
        else
            if itemsInBag(xPlayer, currentBag) then
                debug('Trigger Event itemsInBag(xPlayer)')
                
                if hasBag == 0 then
                    TriggerClientEvent('msk_backpack:delBackpack', source)
                    xPlayer.removeInventoryItem('nobag', 1)
                    xPlayer.addInventoryItem(currentBag, 1)
                    xPlayer.showNotification(_U('used_nobag'))
                    currentBag = nil
                else
                    xPlayer.showNotification(_U('had_bag'))
                end
            else
                debug('Trigger Notification itemsInBag')
                xPlayer.showNotification(_U('itemsInBag'))
            end
        end
    else
        if hasBag == 0 then
            TriggerClientEvent('msk_backpack:delBackpack', source)
            xPlayer.removeInventoryItem('nobag', 1)
            xPlayer.addInventoryItem(currentBag, 1)
    
            if Config.BagInventory:match('expand') then
                debug('playerMaxWeight before remove bag:', xPlayer.source, xPlayer.getMaxWeight())
                setPlayerBag(xPlayer, ESX.GetConfig().MaxWeight)
            end
            
            currentBag = nil
            xPlayer.showNotification(_U('used_nobag'))
        else
            xPlayer.showNotification(_U('had_bag'))
        end
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

    tPlayer.showNotification(''..xPlayer.getName(source)..' durchsucht deine Tasche')
    xPlayer.showNotification('Du durchsuchst die Tasche von: '..tPlayer.getName(target)..'')
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

	MySQL.query('SELECT skin FROM users WHERE identifier = @identifier', {
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