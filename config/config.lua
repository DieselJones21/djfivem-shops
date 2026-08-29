Config = {}

-- Resource display name used in the UI header when a shop does not override it.
Config.ResourceLabel = 'DJ FiveM Scripts'

-- How players interact with shop peds.
-- 'interact'  = darktrovx/interact (recommended)
-- 'ox_target' = ox_target
-- 'qb-target' = qb-target
-- 'auto'      = use interact if started, otherwise ox_target, then qb-target
Config.Target = 'auto'

-- How far the player can be from the ped when opening / checking out.
Config.InteractDistance = 2.2
Config.MaxShopDistance = 4.0

-- Cash is the ox_inventory `money` item on most qbx/ox servers.
-- Set cash to 'framework' if your cash lives on the player account instead.
Config.Money = {
    cash = 'ox',          -- 'ox' | 'framework'
    cashItem = 'money',   -- ox_inventory item name when cash = 'ox'
    bank = 'framework',   -- player bank account (qb / qbx / esx)
    blackMoneyItem = 'black_money',
    logBankTransactions = true, -- writes a Renewed-Banking statement line
}

-- Image path for catalog icons. `%s` is replaced with the item image file.
Config.ImagePath = 'nui://ox_inventory/web/images/%s'

-- Hide shop items that are not registered in ox_inventory (recommended).
Config.HideMissingItems = true

-- Cart / purchase limits
Config.MaxQuantity = 25
Config.MaxCartItems = 20

-- Blips for legal shops (illegal shops can disable per-shop).
Config.BlipScale = 0.65

-- Key shown in the UI footer (NUI always closes with Escape).
Config.CloseHint = 'ESC (Close Shop)'

Config.Notify = {
    position = 'top-right',
    duration = 5000,
}

Config.Locale = {
    interact = 'Browse Shop',
    no_access = 'You cannot use this shop.',
    too_far = 'You walked away from the shop.',
    empty_cart = 'Your cart is empty.',
    cannot_carry = 'You cannot carry that many items.',
    not_enough_cash = 'You do not have enough cash.',
    not_enough_bank = 'You do not have enough bank balance.',
    not_enough_black = 'You do not have enough dirty money.',
    missing_license = 'You are missing a required license.',
    invalid_item = 'That item is not sold here.',
    purchase_success = 'Purchase complete.',
    purchase_failed = 'Purchase failed.',
    missing_item_def = 'An item in this shop is not set up in ox_inventory.',
}
