Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
Config.ItemsInBag = true -- Set true if you want that players can't use 'nobag' Item if there are Items in the Bag
Config.StealBagIfDead = true -- Set false if you dont want to steal a players bag if he is dead

-- Expand the Inventory Space of the Player // Opens a Secondary Inventory by typing /openbag Command
Config.BagInventory = 'expand' -- 'expand' or 'secondary'

-- If set to true go to client.lua and change the IDs to what you set in msk_parchute
Config.useParachute = true -- Set true if you use my msk_parchute Script

Config.restoreBackpack = true -- Restore Backpack after Player Connect
Config.saveSkin = true -- Set false if you have Skin problems on playerConnect

Config.Animations = {
    dict = 'clothingtie',
    anim = 'try_tie_neutral_a',
    time = 2 -- in seconds (default: 2 seconds)
}
----------------------------------------------------------------
Config.Backpacks = {
    ['bag'] = { -- Item // Add this to your database
        skin = {
            male = {skin1 = 82, skin2 = 0},
            female = {skin1 = 82, skin2 = 0}
        },
        weight = 60,
    },
    ['bag2'] = { -- Item // Add this to your database
        skin = {
            male = {skin1 = 81, skin2 = 0},
            female = {skin1 = 81, skin2 = 0}
        },
        weight = 40,
    },
}