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

--[[
    Shop look. Values are pushed into CSS variables when the UI opens.

    `preset` picks a named multi-stop gradient from Config.Theme.Presets.
    Same presets as djfivem-scriptmanager: chrome | lava | vice | gold | ice | sunset
    Leave preset = '' and fill `gradient` yourself for a fully custom blend.
    `inkOnAccent` is the text/icon color sitting on gradient fills
    (use a dark color on chrome/gold, white on neon).
]]
Config.Theme = {
    appName = 'DJ FiveM',
    appTag = 'Scripts',
    logo = 'img/dj-fivem-scripts.webp',
    preset = 'chrome', -- chrome | lava | vice | gold | ice | sunset | ''

    gradient = {
        angle = 125,
        colors = { '#f8f8f8', '#c9c9c9', '#8d8d8d', '#ffffff', '#4c4c4c' },
        inkOnAccent = '#111111',
        glow = '#d8d8d8',
    },

    Presets = {
        chrome = {
            angle = 125,
            colors = { '#ffffff', '#d4d4d4', '#8a8a8a', '#f4f4f4', '#3a3a3a' },
            inkOnAccent = '#111111',
            glow = '#e8e8e8',
        },
        lava = {
            angle = 90,
            colors = { '#ffb347', '#e10600', '#7a00c8' },
            inkOnAccent = '#ffffff',
            glow = '#e10600',
        },
        vice = {
            angle = 110,
            colors = { '#ff2bd6', '#7a5cff', '#00e5ff' },
            inkOnAccent = '#ffffff',
            glow = '#7a5cff',
        },
        gold = {
            angle = 120,
            colors = { '#fff3c4', '#f5c542', '#c4841d', '#7a4a00' },
            inkOnAccent = '#1a1204',
            glow = '#f5c542',
        },
        ice = {
            angle = 100,
            colors = { '#d9fbff', '#5ad0ff', '#2563eb', '#0b1b4a' },
            inkOnAccent = '#ffffff',
            glow = '#5ad0ff',
        },
        sunset = {
            angle = 95,
            colors = { '#ffe08a', '#ff6a2b', '#e10600', '#6b0030' },
            inkOnAccent = '#ffffff',
            glow = '#ff6a2b',
        },
    },

    ink = '#f5f5f5',
    muted = '#8a8a8a',
    screen = '#0b0b0b',
    paper = '#161616',
    wash = '#101010',
    panel = '#141414',
    card = '#1a1a1a',
    card2 = '#202020',
    line = 'rgba(255, 255, 255, 0.08)',
    bezelTop = '#2a2a2a',
    bezelMid = '#141414',
    bezelBottom = '#0a0a0a',
}

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
