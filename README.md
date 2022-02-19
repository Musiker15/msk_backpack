# esx_backpack
FiveM Script - Usable Backpack Item

**Forum:** https://forum.cfx.re/t/release-esx-usable-backpack-item/4805469

**Discord Support:** https://discord.gg/5hHSBRHvJE

## Description
* You can use the `bag` Item, then you get `nobag` Item and a Bag will be added to your Ped.
* If you use `nobag` Item then then the Bag will be removed from your Ped an you get the `bag` Item.

This Script works very well with the `Backpack Plugin` from `Chezza Inventory`

## Config
```lua
Config = {}
---------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
---------------------------------------------------------------
-- Experimental
Config.BagInventory = false -- Set true if you don't want the pocket inventory but want to expand the player inventory
Config.BagWeight = 50 -- Set the Bag Weight if 'Config.BagInventory = true'
```

## Requirements
* ESX 1.2 (https://github.com/esx-framework/es_extended/releases/tag/v1-final)
* Chezza Inventory (https://chezza.tebex.io/package/4770357)

Should work with ESX Legacy too but I didn't test it.

### Plugin Download 
*(for Chezza Inventory)*

Insert `Config.Bags = {82}` in the `config.lua` from chezza inventory

#### Events / Commands
* `/openbag` - Open your own Bag
* `/stealbag` - Open the Bag from Player next to you
* Search Bag *[clientsided]* - `TriggerServerEvent('inventory:updateStealInventoryBag', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))`

## License
**GNU General Public License v3.0**
