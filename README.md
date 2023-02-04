# msk_backpack
**FiveM Script - Multiple Backpack Items**

* **Forum:** https://forum.cfx.re/t/release-esx-usable-backpack-item/4805469
* **Discord Support:** https://discord.gg/5hHSBRHvJE
* **Preview 1:** https://streamable.com/iog8fy
* **Preview 2:** https://streamable.com/61a8ur

## Description
* You can use the `bag` Item, then you get `nobag` Item and a Bag will be added to your Ped.
* If you use `nobag` Item then then the Bag will be removed from your Ped an you get the `bag` Item.
* Open own Bag with Command
* Steal Bag from closest Player with Command
* Works with Character Names not FiveM Names

## Commands
Only if `Config.BagInventory = 'secondary'`!
* `/openbag` - Open your own Bag
* `/stealbag` - Open the Bag from Player next to you

## Exports
You can use the exports clientside AND serverside
```lua
-- Returns the itemName saved in database or nil if the player don't has a Bag
local hasBag = exports.msk_backpack:hasBag(player)
```
**Example**
```lua
exports.msk_backpack:hasBag({source = playerId})
exports.msk_backpack:hasBag({identifier = playerIdentifier})
exports.msk_backpack:hasBag({player = xPlayer})
```

## Requirements
* [ESX 1.2 and above](https://github.com/esx-framework/esx_core)
* [esx_skin and skinchanger](https://github.com/esx-framework/esx_core)
* [oxmysql](https://github.com/overextended/oxmysql)
* [msk_core](https://github.com/MSK-Scripts/msk_core)

### Optional
Chezza Inventory only necessary if `Config.BagInventory = 'secondary'`!

* [Chezza Inventory V4](https://forum.cfx.re/t/paid-release-chezzas-inventory-esx/2040417)

## Support for esx_ambulancejob

**This removes the Backpack after death, resets the inventory space and removes all items inside**

<details> 

Go to `/client/main.lua` and search for `function RespawnPed(ped, coords, heading)`.

Replace the function with this code:
```lua
function RespawnPed(ped, coords, heading, isDied)
  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  ClearPedBloodDamage(ped)

  TriggerServerEvent('esx:onPlayerSpawn')
  TriggerEvent('esx:onPlayerSpawn')
  TriggerEvent('playerSpawned')

  if isDied then
		TriggerServerEvent('msk_backpack:setDeathStatus', true)
	end
end
```
Above this you find: `function RemoveItemsAfterRPDeath()`.

Search for: `RespawnPed(PlayerPedId(), RespawnCoords, ClosestHospital.heading)`

Replace it with this: `RespawnPed(PlayerPedId(), RespawnCoords, ClosestHospital.heading, true)`
</details>

## My other Scripts
* [[ESX] Armor Script - Multiple Armor Vests](https://forum.cfx.re/t/release-esx-armor-script-usable-armor-vests-status-will-be-saved-in-database-and-restore-after-relog/4812243)
* [[ESX] Banking - NativeUI](https://forum.cfx.re/t/esx-msk-banking-nativeui/4859560)
* [[ESX] Handcuffs - Realistic Handcuffs](https://forum.cfx.re/t/esx-msk-handcuffs-realistic-handcuffs/4885324)
* [[ESX] Shopsystem - NativeUI & Database Feature](https://forum.cfx.re/t/release-esx-msk-shopsystem-nativeui-database-feature/4853593)
* [[ESX/QBCore] Simcard - Change your phonenumber](https://forum.cfx.re/t/release-esx-qbcore-usable-simcard/4847008)
* [[ESX] Weapon Ammunition with Clips, Components & Tints](https://forum.cfx.re/t/release-esx-weapon-ammunition-with-clips-components-tints/4793783)
