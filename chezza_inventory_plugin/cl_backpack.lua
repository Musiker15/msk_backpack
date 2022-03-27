ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('inventory:openInventoryBag')
AddEventHandler('inventory:openInventoryBag', function (player, identifier)
    for k,v in pairs(Config.Bags) do
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
            if not IsPlayerDead(PlayerId()) then --This prevent that the player can't open his bag when is died
                if skin.bags_1 == v then
                    OpenInventory({ 
                        type = 'bag', 
                        title = '🎒 '..player, 
                        id = identifier, -- id = identifier .. ':' .. skin.bags_1
                        weight = Config.BagWeight,
                        save = true
                    }) 
                else    
                    --ESX.ShowNotification("Du benötigst eine Tasche dafür!")
                    TriggerEvent('inventory:notify', 'Du benötigst eine Tasche dafür!', 'error') 
                end
            else
                --ESX.ShowNotification("Du bist Tot also wieso öffnest du deine Tasche?")
                TriggerEvent('inventory:notify', 'Du bist Tot also wieso öffnest du deine Tasche?', 'error')
            end
        end)
    end
end)

RegisterNetEvent('inventory:stealInventoryBag')
AddEventHandler('inventory:stealInventoryBag', function()
    local playerPed = PlayerPedId()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        ExecuteCommand('e mechanic') -- This is for do animation (Use Dpemotes)
        TriggerServerEvent('inventory:updateStealInventoryBag', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
        Citizen.Wait(1000)
        ClearPedTasksImmediately(playerPed)
    else
        --ESX.ShowNotification('~r~Es ist kein Spieler in der Nähe')
        TriggerEvent('inventory:notify', 'Es ist kein Spieler in der Nähe', 'error')
    end
end)

RegisterNetEvent('inventory:openOtherInventoryBag')
AddEventHandler('inventory:openOtherInventoryBag', function (player, identifier)
    OpenInventory({ 
        type = 'bag', 
        title = '🎒 '..player, 
        id = identifier, -- id = identifier .. ':' .. skin.bags_1
        weight = Config.BagWeight,
        save = true
    })
end)

RegisterNetEvent('inventory:openBagViaMenu', function ()
    ExecuteCommand('openbag')
end)