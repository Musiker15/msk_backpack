## Chezza Inventory v3
Put `cl_backpack.lua` in `/client/plugins/` folder and `sv_backpack.lua` in `/server/plugins/` folder.

Add the following in the `config.lua` from chezza inventory.
```lua
Config.Bags = {82} -- Set you Bag IDs here
Config.BagWeight = 60 -- Secondary Inventory
-- If Config.BagInventory = 'expand' you cant use the Commands /openbag and /stealbag !!!
-- Expand the Inventory Space of the Player // Secondary Inventory by typing /openbag Command
Config.BagInventory = 'expand' -- 'expand' or 'secondary'
```

## Chezza Inventory v4
Create a new folder in `inventory/plugins/` f.e. `backpack` and put the files `cl_backpack.lua` and `sv_backpack.lua` in the `backpack` folder.

Add the following in the `config.lua` from chezza inventory.
```lua
Config.Bags = {82} -- Set you Bag IDs here
Config.BagWeight = 60 -- Secondary Inventory
-- If Config.BagInventory = 'expand' you cant use the Commands /openbag and /stealbag !!!
-- Expand the Inventory Space of the Player // Secondary Inventory by typing /openbag Command
Config.BagInventory = 'expand' -- 'expand' or 'secondary'
```

### Restart your Server and have fun :)
