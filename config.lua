Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = false
----------------------------------------------------------------
-- If you use the Plugin for Chezza Inventory, make sure this is the same ID
-- as in Config.Bags = {82} in the config.lua from chezza inventory
Config.Bags = {
    male = {bagID_1 = 82, bagID_2 = 0},
    female = {bagID_1 = 82, bagID_2 = 0}
}
----------------------------------------------------------------
-- If you want to expand the Player Inventory and dont want the secondary Inventory by typing the /openbag Command
-- If Config.BagInventory = true you cant use the Commands /openbag and /stealbag !!!
Config.BagInventory = false -- Set true if you want to expand the player inventory
Config.BagWeight = 60 -- Set the Bag Weight if 'Config.BagInventory = true'
----------------------------------------------------------------
-- If set to true go to client.lua and change the IDs to what you set in esx_parachute
Config.useParachute = false -- Set true if you use my esx_parchute Script
----------------------------------------------------------------
Config.CarryLongWeapon = true -- Set 'true' if you want that Players can only carry a Weapon if they have a Bag
Config.WeaponBags = {82} -- Backpack IDs // {ID, ID, ID} | Only for 'Config.CarryLongWeapon' function!!
Config.Weapons = {
    'WEAPON_CARBINERIFLE',
    'WEAPON_GUSENBERG',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_ASSAULTRIFLE',
}
----------------------------------------------------------------
-- Experimental // Not working at the moment!
Config.ItemsInBag = false -- Set true if you want that players cant use 'nobag' Item if Items in Bag