Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = false
----------------------------------------------------------------
-- Experimental // Not working at the moment for Chezza Inventory!
Config.BagInventory = false -- Set 'true' if you don't want the pocket inventory but want to expand the player inventory
Config.BagWeight = 60 -- Set the Bag Weight if 'Config.BagInventory = true'
----------------------------------------------------------------
Config.CarryLongWeapon = true -- Set 'true' if you want that Players can only carry a Weapon if they have a Bag
Config.WeaponBags = {82} -- Backpack IDs | Only for 'Config.CarryLongWeapon' function!!
Config.Weapons = {
    'WEAPON_SMG',
    'WEAPON_GUSENBERG',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_ASSAULTRIFLE',
}
----------------------------------------------------------------