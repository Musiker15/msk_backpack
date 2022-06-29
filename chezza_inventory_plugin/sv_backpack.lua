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

ESX.RegisterServerCallback('inventory:getPlayerSkin', function(source, cb, player)
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