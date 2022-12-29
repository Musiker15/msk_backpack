ESX = exports["es_extended"]:getSharedObject()
MSK = exports.msk_core:getCoreObject()

local currentBag, currentBagWeight = nil, nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    Wait(1000) -- Please Do Not Touch!
    
    if ESX.IsPlayerLoaded() then
        logging('debug', 'Player loaded')
        local hasBag = hasBag({source = GetPlayerServerId(PlayerId())})
        if not hasBag then return end

        local skin = MSK.TriggerCallback('msk_backpack:getPlayerSkin', GetPlayerServerId(PlayerId()))
        if skin.sex == 0 then -- Male
            if skin.bags_1 == Config.Backpacks[hasBag].skin.male.skin1 then
                logging('debug', skin.bags_1, Config.Backpacks[hasBag].skin.male.skin1, Config.Backpacks[hasBag].weight)
                currentBag = hasBag
                currentBagWeight = Config.Backpacks[hasBag].weight
                setJoinBag(hasBag, Config.Backpacks[hasBag].weight)
            else
                if Config.FiveMAppearance then
                    SetPedComponentVariation(PlayerPedId(), 5, Config.Backpacks[hasBag].skin.male.skin1, Config.Backpacks[hasBag].skin.male.skin2)
                else
                    TriggerEvent('skinchanger:change', "bags_1", Config.Backpacks[hasBag].skin.male.skin1)
                    TriggerEvent('skinchanger:change', "bags_2", Config.Backpacks[hasBag].skin.male.skin2)
                    TriggerEvent('skinchanger:getSkin', function(skin)
                        TriggerServerEvent('msk_backpack:save', skin)
                    end)
                end
                setJoinBag(hasBag, Config.Backpacks[hasBag].weight)
            end
        else
            if skin.bags_1 == Config.Backpacks[hasBag].skin.female.skin1 then
                logging('debug', skin.bags_1, Config.Backpacks[hasBag].skin.female.skin1, Config.Backpacks[hasBag].weight)
                currentBag = hasBag
                currentBagWeight = Config.Backpacks[hasBag].weight
                setJoinBag(hasBag, Config.Backpacks[hasBag].weight)
            else
                if Config.FiveMAppearance then
                    SetPedComponentVariation(PlayerPedId(), 5, Config.Backpacks[hasBag].skin.female.skin1, Config.Backpacks[hasBag].skin.female.skin2)
                else
                    TriggerEvent('skinchanger:change', "bags_1", Config.Backpacks[hasBag].skin.female.skin1)
                    TriggerEvent('skinchanger:change', "bags_2", Config.Backpacks[hasBag].skin.female.skin2)
                    TriggerEvent('skinchanger:getSkin', function(skin)
                        TriggerServerEvent('msk_backpack:save', skin)
                    end)
                end
                setJoinBag(hasBag, Config.Backpacks[hasBag].weight)
            end
        end
    else
        logging('debug', 'xPlayer not found on Event: playerLoaded')
    end
end)

RegisterNetEvent('msk_backpack:setBackpack')
AddEventHandler('msk_backpack:setBackpack', function(itemname, item)
    logging('debug', 'itemname:', itemname)
    local playerPed = PlayerPedId()
    currentBag = itemname
    currentBagWeight = item.weight

    doAnimation(playerPed)

    local skin = MSK.TriggerCallback('msk_backpack:getPlayerSkin', GetPlayerServerId(PlayerId()))
    if skin.sex == 0 then -- Male
        if Config.FiveMAppearance then
            SetPedComponentVariation(playerPed, 5, item.skin.male.skin1, item.skin.male.skin2)
        else
            TriggerEvent('skinchanger:change', "bags_1", item.skin.male.skin1)
            TriggerEvent('skinchanger:change', "bags_2", item.skin.male.skin2)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('msk_backpack:save', skin)
            end)
        end
    else -- Female
        if Config.FiveMAppearance then
            SetPedComponentVariation(playerPed, 5, item.skin.female.skin1, item.skin.female.skin2)
        else
            TriggerEvent('skinchanger:change', "bags_1", item.skin.female.skin1)
            TriggerEvent('skinchanger:change', "bags_2", item.skin.female.skin2)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('msk_backpack:save', skin)
            end)
        end
    end

    ESX.ShowNotification(_U('used_bag'))
end)

RegisterNetEvent('msk_backpack:delBackpack')
AddEventHandler('msk_backpack:delBackpack', function()
    logging('debug', 'Trigger Event delBackpack')
    local playerPed = PlayerPedId()
    currentBag = nil
    currentBagWeight = nil

    doAnimation(playerPed)

    local skin = MSK.TriggerCallback('msk_backpack:getPlayerSkin', GetPlayerServerId(PlayerId()))
    if Config.useParachute then
        if skin.bags_1 ~= 63 then -- Parachute Skin - esx_parachute by me :)
            if Config.FiveMAppearance then
                SetPedComponentVariation(playerPed, 5, 0, 0)
            else
                TriggerEvent('skinchanger:change', "bags_1", 0)
                TriggerEvent('skinchanger:change', "bags_2", 0)
                TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerServerEvent('msk_backpack:save', skin)
                end)
            end
            logging('debug', 'Set Backpack to 0')
        end
    else
        if Config.FiveMAppearance then
            SetPedComponentVariation(playerPed, 5, 0, 0)
        else
            TriggerEvent('skinchanger:change', "bags_1", 0)
            TriggerEvent('skinchanger:change', "bags_2", 0)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('msk_backpack:save', skin)
            end)
        end
        logging('debug', 'Set Backpack to 0')
    end

    ESX.ShowNotification(_U('used_nobag'))
end)

RegisterNetEvent('msk_backpack:delBackpackDeath')
AddEventHandler('msk_backpack:delBackpackDeath', function()
    logging('debug', 'Trigger Event delBackpack after Death')
    local playerPed = PlayerPedId()
    currentBag = nil
    currentBagWeight = nil

    if Config.FiveMAppearance then
        SetPedComponentVariation(playerPed, 5, 0, 0)
    else
        TriggerEvent('skinchanger:change', "bags_1", 0)
        TriggerEvent('skinchanger:change', "bags_2", 0)
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerServerEvent('msk_backpack:save', skin)
        end)
    end
    logging('debug', 'Set Backpack to 0')
    TriggerEvent("inventory:refresh")
end)

if Config.BagInventory:match('secondary') then
    RegisterCommand('openbag', function()
        local hasBackpack = false

        local skin = MSK.TriggerCallback('msk_backpack:getPlayerSkin', GetPlayerServerId(PlayerId()))
        if not IsPlayerDead(PlayerId()) then
            for k, v in pairs(Config.Backpacks) do
                if skin.sex == 0 then -- Male
                    if skin.bags_1 == v.skin.male.skin1 then -- Bag Skin
                        hasBackpack = true
                    end
                else -- Female
                    if skin.bags_1 == v.skin.female.skin1 then -- Bag Skin
                        hasBackpack = true
                    end
                end
            end

            if hasBackpack then
                local name, identifier = MSK.TriggerCallback('msk_backpack:getUserData')
                TriggerEvent('inventory:openInventory', {
                    type = currentBag,
                    id = identifier,
                    title = '🎒 '.. name,
                    weight = currentBagWeight,
                    delay = 150,
                    save = true
                })
            else
                ESX.ShowNotification(_U('noBag'))
            end
        else
            ESX.ShowNotification(_U('youre_dead'))
        end
    end)

    RegisterCommand('stealbag', function()
        local player, playerDistance = ESX.Game.GetClosestPlayer()
    
        if player ~= -1 and playerDistance <= 3.0 then
            local playerPed = PlayerPedId()
            local targetPed = GetPlayerPed(player)
            local hasBackpack = false
                    
            if DoesEntityExist(targetPed) then
                local skin = MSK.TriggerCallback('msk_backpack:getPlayerSkin', GetPlayerServerId(player))

                for k, v in pairs(Config.Backpacks) do
                    if skin.sex == 0 then -- Male
                        if skin.bags_1 == v.skin.male.skin1 then -- Bag Skin
                            hasBackpack = true
                        end
                    else -- Female
                        if skin.bags_1 == v.skin.female.skin1 then -- Bag Skin
                            hasBackpack = true
                        end
                    end
                end

                if hasBackpack then
                    local name, identifier = MSK.TriggerCallback('msk_backpack:getTargetData', GetPlayerServerId(player))

                    if IsEntityDead(targetPed) then
                        if Config.StealBagIfDead then
                            TriggerServerEvent('msk_backpack:updateStealInventoryBag', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
                                
                            TriggerEvent('inventory:openInventory', {
                                type = currentBag,
                                id = identifier,
                                title = '🎒 '.. name,
                                weight = currentBagWeight,
                                delay = 150,
                            })
            
                            LoadAnimDict("random@mugging5", function()
                                TaskPlayAnim(playerPed, "random@mugging5", "ig_1_guy_handoff", 8.0, 8.0, -1, 50, 0, false, false, false)
                                Wait(2000)
                                ClearPedTasks(playerPed)
                            end) 
                        else
                            ESX.ShowNotification(_U('entity_dead'))
                        end
                    else 
                        if IsEntityPlayingAnim(targetPed, "missminuteman_1ig_2", "handsup_enter", 3) then
                            TriggerServerEvent('msk_backpack:updateStealInventoryBag', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
                                
                            TriggerEvent('inventory:openInventory', {
                                type = currentBag,
                                id = identifier,
                                title = '🎒 '.. name,
                                weight = currentBagWeight,
                                delay = 150,
                            })
        
                            LoadAnimDict("random@mugging5", function()
                                TaskPlayAnim(playerPed, "random@mugging5", "ig_1_guy_handoff", 8.0, 8.0, -1, 50, 0, false, false, false)
                                Wait(2000)
                                ClearPedTasks(playerPed)
                            end) 
                        else 
                            ESX.ShowNotification(_U('not_handsup'))
                        end 
                    end
                else
                    ESX.ShowNotification(_U('player_noBag'))
                end
    
                while true do 
                    Wait(1)
                    player, playerDistance = ESX.Game.GetClosestPlayer()
    
                    if playerDistance > 3.0 then 
                        TriggerEvent('inventory:close')
                        break
                    end
                end
            end
        else 
            ESX.ShowNotification(_U('no_player_nearby'))
        end
    end)
end

doAnimation = function(playerPed)
    ESX.Streaming.RequestAnimDict(Config.Animations.dict, function()
		TaskPlayAnim(playerPed, Config.Animations.dict, Config.Animations.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
		RemoveAnimDict(Config.Animations.dict)
	end)
	Wait(Config.Animations.time * 1000)
	ClearPedTasks(playerPed)
end

setJoinBag = function(item, weight)
    if Config.BagInventory:match('expand') then
        TriggerServerEvent('msk_backpack:setJoinBag', item, weight)
    end
end

hasBag = function(player)
    local hasBag = MSK.TriggerCallback('msk_backpack:hasBag', player)
    return hasBag
end
exports('hasBag', hasBag)

logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end