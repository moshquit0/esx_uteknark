-- QB-Core item definitions for mosh_uteknark
-- Add these entries into: qb-core/shared/items.lua
--
-- Note:
-- - 'useable' must be true so the script can register the usable item callback.
-- - Put the referenced images into your inventory UI images folder (commonly qb-inventory/html/images/).

['weed_seed'] = {
    name = 'weed_seed',
    label = 'Weedseed',
    weight = 1,
    type = 'item',
    image = 'weed_seed.png',
    unique = false,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'Seed for planting.'
},

['weed_pooch'] = {
    name = 'weed_pooch',
    label = 'Weed packet',
    weight = 50,
    type = 'item',
    image = 'weed_pooch.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Packaged Weed.'
},

['dunger'] = {
    name = 'dunger',
    label = 'Fertilizer',
    weight = 200,
    type = 'item',
    image = 'dunger.png',
    unique = false,
    useable = false,
    shouldClose = true,
    combinable = nil,
    description = 'Used for plant care.'
},
