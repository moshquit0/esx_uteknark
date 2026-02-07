# Item Definitions (mosh_uteknark)

This script uses these items by default:
- `weed_seed` (Seed)
- `dunger` (Tend / fertilizer)
- `weed_pooch` (Product when harvesting)

## ESX
- File: `items/esx_items.sql`
- Import the appropriate section (weight- or limit-based) into your database.

## QB-Core
- File: `items/qb_items.lua`
- Copy/Paste in `qb-core/shared/items.lua`
- Add icons (e.g. `qb-inventory/html/images/`):
  - `weed_seed.png`
  - `dunger.png`
  - `weed_pooch.png`

## ox_inventory
- File: `items/ox_inventory_items.lua`
- Copy/Paste in `ox_inventory/data/items.lua`
- Add icons (e.g. `ox_inventory/web/images/`):
  - `weed_seed.png`
  - `dunger.png`
  - `weed_pooch.png`
