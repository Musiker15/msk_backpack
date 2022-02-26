ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    local playerPed = PlayerPedId()
    local xPlayer = ESX.IsPlayerLoaded(playerPed)

    Citizen.Wait(1000) -- Please Do Not Touch!
    
    if xPlayer then
        if Config.BagInventory then
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin.bags_1 == 82 then -- Bag Skin
                    TriggerServerEvent('esx_bag:setMaxWeight')
                end
            end)
        end
    else
        if Config.Debug then
            print('xPlayer not found')
        end
    end
end)

RegisterNetEvent('esx_bag:setBag')
AddEventHandler('esx_bag:setBag', function(id)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        if skin.bags_1 ~= 82 then -- Bag Skin
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
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        if skin.bags_1 ~= 63 then -- Parachute Skin - esx_parachute by me :)
            TriggerEvent('skinchanger:change', "bags_1", 0)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
            end)
        end
    end)
end)

if Config.CarryLongWeapon then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
	        local hash = GetSelectedPedWeapon(playerPed)

            if CheckWeapon(hash) then
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    for k,v in pairs(Config.WeaponBags) do
                        if skin.bags_1 == 0 then
                            SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                            ESX.ShowNotification(_U('noBag'))
                        elseif skin.bags_1 ~= v then
                            SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                            ESX.ShowNotification(_U('otherBag'))
                        else
                            if Config.Debug then
                                print('Has Bag and got weapon')
                            end
                        end
                    end
                end)
            end
        end
    end) 

    function CheckWeapon(hash)
        for k,v in pairs(Config.Weapons) do
            if GetHashKey(v) == hash then
                return true
            end
        end
        return false
    end
end