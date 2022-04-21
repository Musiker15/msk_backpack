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
Config.ItemsInBag = true -- Set true if you want that players cant use 'nobag' Item if there are Items in the Bag
----------------------------------------------------------------
-- Config.BagInventory = true // Expand the Inventory Space of the Player
-- Config.BagInventory = false // Secondary Inventory by typing /openbag Command
-- If Config.BagInventory = true then change this to the same value in config.lua of Chezza Inventory !!!
Config.BagInventory = true
Config.BagWeight = 60 -- Set the Value what added to the Inventory Space if 'Config.BagInventory = true'
----------------------------------------------------------------
-- If set to true go to client.lua and change the IDs to what you set in esx_parachute
Config.useParachute = false -- Set true if you use my esx_parchute Script
----------------------------------------------------------------
-- Experimental // Can cause performance problems
Config.CarryLongWeapon = false -- Set 'true' if you want that Players can only carry a Weapon if they have a Bag
Config.WeaponBags = {82} -- Backpack IDs // {ID, ID, ID} | Only for 'Config.CarryLongWeapon' function!!
Config.Weapons = {
    'WEAPON_CARBINERIFLE',
    'WEAPON_GUSENBERG',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_ASSAULTRIFLE',
}