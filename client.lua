ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_bag:setBag')
AddEventHandler('esx_bag:setBag', function(id)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if skin.bags_1 ~= 82 then
            TriggerEvent('skinchanger:change', "bags_1", 82)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
            end)
        end
    end)
end)

RegisterNetEvent('esx_bag:setdelBag')
AddEventHandler('esx_bag:setdelBag', function(id)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if skin.bags_1 == 82 then
            TriggerEvent('skinchanger:change', "bags_1", 0)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
            end)
        end
    end)
end)