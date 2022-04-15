Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- If you use the Plugin for Chezza Inventory, make sure this is the same ID
-- as in Config.Bags = {82} in the config.lua from chezza inventory
Config.Bags = {
    male = {bagID_1 = 82, bagID_2 = 0},
    female = {bagID_1 = 82, bagID_2 = 0}
}
----------------------------------------------------------------
-- If set to true go to server.lua and change the IDs to what you set in esx_parachute
Config.useParachute = true -- Set false if you dont use my esx_parchute Script
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
Config.BagInventory = false -- Set 'true' if you don't want the pocket inventory but want to expand the player inventory
Config.BagWeight = 60 -- Set the Bag Weight if 'Config.BagInventory = true'
Config.ItemsInBag = false -- Set true if you want that players cant use 'nobag' Item if Items in Bag
