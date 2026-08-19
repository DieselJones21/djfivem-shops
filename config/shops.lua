--[[
    Shop catalogs use the server item names from the provided list.
    Prices can be changed here without touching anything else.
    Missing ox_inventory items are hidden automatically.
]]

local function I(name, price, category, extra)
    local item = extra or {}
    item.name = name
    item.price = price
    item.category = category
    return item
end

local generalItems = {
    I('sandwich', 4, 'food'),
    I('water', 2, 'drinks'),
    I('ecola', 3, 'drinks'),
}

local youtoolItems = {
    I('lockpick', 150, 'tools'),
    I('repair_kit', 250, 'tools'),
}

local digitalItems = {
    I('phone', 850, 'phones'),
    I('radio', 250, 'comms'),
}

local ammunationItems = {
    I('WEAPON_APPISTOL', 4500, 'pistols', { license = 'weapon', metadata = { registered = true } }),
    I('WEAPON_ASSAULTRIFLE', 8500, 'rifles', { license = 'weapon', metadata = { registered = true } }),
    I('WEAPON_PUMPSHOTGUN', 3500, 'shotguns', { license = 'weapon', metadata = { registered = true } }),
    I('ammo-9', 5, 'ammo'),
    I('ammo-44', 8, 'ammo'),
    I('ammo-rifle', 10, 'ammo'),
    I('ammo-rifle2', 12, 'ammo'),
    I('ammo-shotgun', 8, 'ammo'),
}

local robberyItems = {
    I('robbery_tablet', 3500, 'electronics'),
    I('lockpick', 250, 'tools'),
    I('drill', 3500, 'tools'),
    I('electronickit', 2500, 'electronics'),
    I('thermite', 4000, 'breaching'),
    I('crowbar', 200, 'tools'),
}

local drugItems = {
    I('baggies', 5, 'packaging'),
    I('acetone', 25, 'supplies'),
    I('cups', 3, 'packaging'),
    I('sprite', 4, 'supplies'),
    I('hard_candies', 3, 'supplies'),
}

Config.Shops = {
    general = {
        label = '24/7',
        subtitle = 'Supermarket',
        interactLabel = 'Open 24/7',
        enabled = true,
        payments = { 'cash', 'bank' },
        blip = { sprite = 52, color = 1, label = '24/7' },
        ped = { model = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        categories = {
            { id = 'food', label = 'Food' },
            { id = 'drinks', label = 'Drinks' },
        },
        items = generalItems,
        locations = {
            { label = 'Innocence Blvd', coords = vector4(24.47, -1346.62, 29.50, 271.66) },
            { label = 'Ineseno Road', coords = vector4(-3039.54, 584.38, 7.91, 17.27) },
            { label = 'Barbareno Road', coords = vector4(-3242.97, 1000.01, 12.83, 357.57) },
            { label = 'Paleto Bay', coords = vector4(1728.07, 6415.63, 35.04, 242.95) },
            { label = 'Sandy Shores', coords = vector4(1959.82, 3740.48, 32.34, 301.57) },
            { label = 'Harmony', coords = vector4(549.13, 2670.85, 42.16, 99.39) },
            { label = 'Senora Fwy', coords = vector4(2677.47, 3279.76, 55.24, 335.08) },
            { label = 'Palomino Fwy', coords = vector4(2556.66, 380.84, 108.62, 356.67) },
            { label = 'Clinton Ave', coords = vector4(372.66, 326.98, 103.57, 253.73) },
        },
    },

    ltd = {
        label = 'LTD Gasoline',
        subtitle = 'Convenience',
        interactLabel = 'Open LTD',
        enabled = true,
        payments = { 'cash', 'bank' },
        blip = { sprite = 52, color = 1, label = 'LTD Gasoline' },
        ped = { model = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        categories = {
            { id = 'food', label = 'Food' },
            { id = 'drinks', label = 'Drinks' },
        },
        items = generalItems,
        locations = {
            { label = 'Grove Street', coords = vector4(-47.02, -1758.23, 29.42, 45.05) },
            { label = 'Little Seoul', coords = vector4(-706.06, -913.97, 19.22, 88.04) },
            { label = 'Richman Glen', coords = vector4(-1820.02, 794.03, 138.09, 135.45) },
            { label = 'Mirror Park', coords = vector4(1164.71, -322.94, 69.21, 101.72) },
            { label = 'Grapeseed', coords = vector4(1697.87, 4922.96, 42.06, 324.71) },
        },
    },

    liquor = {
        label = 'Rob\'s Liquor',
        subtitle = 'Off Licence',
        interactLabel = 'Open Liquor Store',
        enabled = true,
        payments = { 'cash', 'bank' },
        blip = { sprite = 93, color = 1, label = 'Rob\'s Liquor' },
        ped = { model = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        categories = {
            { id = 'food', label = 'Food' },
            { id = 'drinks', label = 'Drinks' },
        },
        items = generalItems,
        locations = {
            { label = 'San Andreas Ave', coords = vector4(-1221.58, -908.15, 12.33, 35.49) },
            { label = 'Prosperity St', coords = vector4(-1486.59, -377.68, 40.16, 139.51) },
            { label = 'Great Ocean Hwy', coords = vector4(-2966.39, 391.42, 15.04, 87.48) },
            { label = 'Route 68', coords = vector4(1165.17, 2710.88, 38.16, 179.43) },
            { label = 'El Rancho Blvd', coords = vector4(1134.2, -982.91, 46.42, 277.24) },
        },
    },

    ammunation = {
        label = 'Ammunation',
        subtitle = 'Firearms',
        interactLabel = 'Open Ammunation',
        enabled = true,
        payments = { 'cash', 'bank' },
        blip = { sprite = 110, color = 1, label = 'Ammunation' },
        ped = { model = 's_m_y_ammucity_01', scenario = 'WORLD_HUMAN_COP_IDLES' },
        categories = {
            { id = 'pistols', label = 'Pistols' },
            { id = 'rifles', label = 'Rifles' },
            { id = 'shotguns', label = 'Shotguns' },
            { id = 'ammo', label = 'Ammo' },
        },
        items = ammunationItems,
        locations = {
            { label = 'Popular Street', coords = vector4(-661.96, -933.53, 21.83, 177.05) },
            { label = 'Vespucci Blvd', coords = vector4(809.68, -2159.13, 29.62, 1.43) },
            { label = 'Sandy Shores', coords = vector4(1692.67, 3761.38, 34.71, 227.65) },
            { label = 'Paleto Bay', coords = vector4(-331.23, 6085.37, 31.45, 228.02) },
            { label = 'Hawick Ave', coords = vector4(253.63, -51.02, 69.94, 72.91) },
            { label = 'La Mesa', coords = vector4(23.0, -1105.67, 29.8, 162.91) },
            { label = 'Palomino Fwy', coords = vector4(2567.48, 292.59, 108.73, 349.68) },
            { label = 'Route 68', coords = vector4(-1118.59, 2700.05, 18.55, 221.89) },
            { label = 'Popular St East', coords = vector4(841.92, -1035.32, 28.19, 1.56) },
            { label = 'Morningwood', coords = vector4(-1304.19, -395.12, 36.7, 75.03) },
            { label = 'Chumash', coords = vector4(-3173.31, 1088.85, 20.84, 244.18) },
        },
    },

    youtool = {
        label = 'YouTool',
        subtitle = 'Hardware',
        interactLabel = 'Open YouTool',
        enabled = true,
        payments = { 'cash', 'bank' },
        blip = { sprite = 402, color = 1, label = 'YouTool' },
        ped = { model = 'mp_m_waremech_01', scenario = 'WORLD_HUMAN_CLIPBOARD' },
        categories = {
            { id = 'tools', label = 'Tools' },
        },
        items = youtoolItems,
        locations = {
            { label = 'Davis', coords = vector4(45.68, -1749.04, 29.61, 53.13) },
            { label = 'Harmony', coords = vector4(2747.71, 3472.85, 55.67, 255.08) },
            { label = 'Paleto Bay', coords = vector4(-421.83, 6136.13, 31.88, 228.2) },
        },
    },

    digitalden = {
        label = 'Digital Den',
        subtitle = 'Electronics',
        interactLabel = 'Open Digital Den',
        enabled = true,
        payments = { 'cash', 'bank' },
        blip = { sprite = 521, color = 1, label = 'Digital Den' },
        ped = { model = 'a_m_y_hipster_02', scenario = 'WORLD_HUMAN_STAND_MOBILE' },
        categories = {
            { id = 'phones', label = 'Phones' },
            { id = 'comms', label = 'Comms' },
        },
        items = digitalItems,
        locations = {
            { label = 'Legion Square', coords = vector4(392.52, -831.73, 29.29, 223.15) },
            { label = 'Mirror Park', coords = vector4(1137.44, -470.88, 66.66, 254.72) },
            { label = 'Rockford Hills', coords = vector4(-509.48, 278.63, 83.32, 173.0) },
            { label = 'Little Seoul', coords = vector4(-656.79, -854.76, 24.51, 0.0) },
        },
    },

    pharmacy = {
        label = 'Pharmacy',
        subtitle = 'Medical',
        interactLabel = 'Open Pharmacy',
        enabled = false, -- no pharmacy items were in the item list yet
        payments = { 'cash', 'bank' },
        blip = { sprite = 51, color = 1, label = 'Pharmacy' },
        ped = { model = 's_m_m_doctor_01', scenario = 'WORLD_HUMAN_CLIPBOARD' },
        categories = {
            { id = 'firstaid', label = 'First Aid' },
        },
        items = {},
        locations = {
            { label = 'Pillbox Hill', coords = vector4(318.91, -1078.65, 29.47, 339.20) },
            { label = 'Downtown Vinewood', coords = vector4(114.45, -4.85, 67.82, 163.0) },
            { label = 'Sandy Shores', coords = vector4(1839.99, 3672.86, 34.28, 208.0) },
            { label = 'Paleto Bay', coords = vector4(-176.58, 6383.42, 31.50, 223.0) },
        },
    },

    robbery = {
        label = 'The Backroom',
        subtitle = 'Robbery Supplies',
        interactLabel = 'Talk to Dealer',
        enabled = true,
        illegal = true,
        payments = { 'cash', 'black_money' },
        blip = false,
        ped = { model = 'g_m_y_lost_01', scenario = 'WORLD_HUMAN_AA_SMOKE' },
        categories = {
            { id = 'tools', label = 'Tools' },
            { id = 'electronics', label = 'Electronics' },
            { id = 'breaching', label = 'Breaching' },
        },
        items = robberyItems,
        locations = {
            { label = 'Rogers Scrap Yard', coords = vector4(-594.70, -1616.36, 33.01, 170.68) },
            { label = 'Elysian Island', coords = vector4(153.87, -3211.73, 5.91, 270.0) },
        },
    },

    drugs = {
        label = 'Street Chemist',
        subtitle = 'Drug Supplies',
        interactLabel = 'Talk to Chemist',
        enabled = true,
        illegal = true,
        payments = { 'cash', 'black_money' },
        blip = false,
        ped = { model = 'g_m_y_mexgoon_01', scenario = 'WORLD_HUMAN_DRUG_DEALER' },
        categories = {
            { id = 'packaging', label = 'Packaging' },
            { id = 'supplies', label = 'Supplies' },
        },
        items = drugItems,
        locations = {
            { label = 'Cypress Flats', coords = vector4(970.15, -1810.88, 31.24, 85.0) },
            { label = 'Forum Drive', coords = vector4(-32.18, -1432.76, 31.70, 270.0) },
            { label = 'Stab City', coords = vector4(68.98, 3693.22, 40.66, 60.0) },
        },
    },
}
