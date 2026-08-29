local function getFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    end
    if GetResourceState('qb-core') == 'started' then
        return 'qb', exports['qb-core']:GetCoreObject()
    end
    if GetResourceState('es_extended') == 'started' then
        return 'esx', exports['es_extended']:getSharedObject()
    end
end

local function getPlayer(source)
    local name, core = getFramework()
    if name == 'qbx' then
        return exports.qbx_core:GetPlayer(source), name
    elseif name == 'qb' then
        return core.Functions.GetPlayer(source), name
    elseif name == 'esx' then
        return core.GetPlayerFromId(source), name
    end
end

local function playerName(player, fw)
    if not player then
        return 'Customer'
    end
    if fw == 'esx' then
        return player.getName() or 'Customer'
    end
    local info = player.PlayerData and player.PlayerData.charinfo
    if info then
        return ('%s %s'):format(info.firstname or '', info.lastname or ''):gsub('%s+$', '')
    end
    return GetPlayerName(player.PlayerData and player.PlayerData.source or 0) or 'Customer'
end

local function citizenId(player, fw, source)
    if not player then
        return GetPlayerIdentifierByType(source, 'license')
    end
    if fw == 'esx' then
        return player.getIdentifier()
    end
    return player.PlayerData.citizenid
end

local function hasLicense(player, fw, license)
    if not license then
        return true
    end
    if not player then
        return false
    end
    if fw == 'esx' then
        if player.getInventoryItem then
            local item = player.getInventoryItem(license)
            if item and (item.count or item.amount or 0) > 0 then
                return true
            end
        end
        return false
    end
    local meta = player.PlayerData.metadata or {}
    local licences = meta.licences or meta.licenses or {}
    return licences[license] == true
end

local function getCash(source)
    if Config.Money.cash == 'framework' then
        local player, fw = getPlayer(source)
        if not player then return 0 end
        if fw == 'esx' then
            return player.getAccount and player.getAccount('money') and player.getAccount('money').money or player.getMoney()
        end
        return player.Functions.GetMoney('cash')
    end
    return exports.ox_inventory:GetItemCount(source, Config.Money.cashItem) or 0
end

local function getBank(source)
    local player, fw = getPlayer(source)
    if not player then return 0 end
    if fw == 'esx' then
        local account = player.getAccount('bank')
        return account and account.money or 0
    end
    return player.Functions.GetMoney('bank')
end

local function getBlackMoney(source)
    return exports.ox_inventory:GetItemCount(source, Config.Money.blackMoneyItem) or 0
end

local function removeCash(source, amount)
    if Config.Money.cash == 'framework' then
        local player, fw = getPlayer(source)
        if not player then return false end
        if fw == 'esx' then
            if getCash(source) < amount then return false end
            player.removeMoney(amount)
            return true
        end
        return player.Functions.RemoveMoney('cash', amount, 'djshops-purchase')
    end
    return exports.ox_inventory:RemoveItem(source, Config.Money.cashItem, amount)
end

local function addCash(source, amount)
    if Config.Money.cash == 'framework' then
        local player, fw = getPlayer(source)
        if not player then return end
        if fw == 'esx' then
            player.addMoney(amount)
            return
        end
        player.Functions.AddMoney('cash', amount, 'djshops-refund')
        return
    end
    exports.ox_inventory:AddItem(source, Config.Money.cashItem, amount)
end

local function removeBank(source, amount, shopLabel)
    local player, fw = getPlayer(source)
    if not player then return false end

    local ok
    if fw == 'esx' then
        if getBank(source) < amount then return false end
        player.removeAccountMoney('bank', amount)
        ok = true
    else
        ok = player.Functions.RemoveMoney('bank', amount, 'djshops-purchase')
    end

    if ok and Config.Money.logBankTransactions and GetResourceState('Renewed-Banking') == 'started' then
        local cid = citizenId(player, fw, source)
        local name = playerName(player, fw)
        pcall(function()
            exports['Renewed-Banking']:handleTransaction(
                cid,
                ('Personal Account / %s'):format(cid),
                amount,
                ('Purchase at %s'):format(shopLabel or 'Shop'),
                shopLabel or 'Shop',
                name,
                'withdraw'
            )
        end)
    end

    return ok and true or false
end

local function addBank(source, amount, shopLabel)
    local player, fw = getPlayer(source)
    if not player then return end
    if fw == 'esx' then
        player.addAccountMoney('bank', amount)
    else
        player.Functions.AddMoney('bank', amount, 'djshops-refund')
    end

    if Config.Money.logBankTransactions and GetResourceState('Renewed-Banking') == 'started' then
        local cid = citizenId(player, fw, source)
        local name = playerName(player, fw)
        pcall(function()
            exports['Renewed-Banking']:handleTransaction(
                cid,
                ('Personal Account / %s'):format(cid),
                amount,
                ('Refund from %s'):format(shopLabel or 'Shop'),
                shopLabel or 'Shop',
                name,
                'deposit'
            )
        end)
    end
end

local function removeBlack(source, amount)
    return exports.ox_inventory:RemoveItem(source, Config.Money.blackMoneyItem, amount)
end

local function addBlack(source, amount)
    exports.ox_inventory:AddItem(source, Config.Money.blackMoneyItem, amount)
end

local function isNearShop(source, shop, locationIndex)
    local location = shop.locations[locationIndex]
    if not location then return false end
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local coords = GetEntityCoords(ped)
    local c = location.coords
    return #(coords - vector3(c.x, c.y, c.z)) <= Config.MaxShopDistance + 1.5
end

local function shopItemMap(shop)
    local map = {}
    for i = 1, #shop.items do
        local item = shop.items[i]
        map[item.name] = item
    end
    return map
end

local function oxItem(name)
    local items = exports.ox_inventory:Items()
    if not items then return end
    return items[name] or items[name:lower()] or items[name:upper()]
end

local function imageFile(name, data)
    if data and data.client and data.client.image then
        return data.client.image
    end
    return ('%s.png'):format(name:lower())
end

local function buildCatalog(shop, player, fw)
    local categories = {}
    local used = {}

    for i = 1, #shop.categories do
        local category = shop.categories[i]
        categories[#categories + 1] = {
            id = category.id,
            label = category.label,
        }
        used[category.id] = true
    end

    local items = {}
    for i = 1, #shop.items do
        local product = shop.items[i]
        local data = oxItem(product.name)
        if data or not Config.HideMissingItems then
            if not used[product.category] then
                categories[#categories + 1] = { id = product.category, label = product.category }
                used[product.category] = true
            end
            items[#items + 1] = {
                name = product.name,
                label = data and data.label or product.name,
                price = product.price,
                category = product.category,
                image = Config.ImagePath:format(imageFile(product.name, data)),
                license = product.license,
                locked = product.license and not hasLicense(player, fw, product.license) or false,
            }
        end
    end

    return categories, items
end

lib.callback.register('djshops:openShop', function(source, shopId, locationIndex)
    local shop = Config.Shops[shopId]
    if not shop or shop.enabled == false then return end
    if not isNearShop(source, shop, locationIndex) then return end

    local player, fw = getPlayer(source)
    local location = shop.locations[locationIndex]
    local categories, items = buildCatalog(shop, player, fw)

    return {
        shopId = shopId,
        locationIndex = locationIndex,
        shop = {
            label = shop.label,
            subtitle = shop.subtitle or location.label,
            location = location.label,
            illegal = shop.illegal or false,
        },
        payments = shop.payments or { 'cash', 'bank' },
        player = {
            name = playerName(player, fw),
            cash = getCash(source),
            bank = getBank(source),
            black = getBlackMoney(source),
        },
        categories = categories,
        items = items,
        maxQuantity = Config.MaxQuantity,
        closeHint = Config.CloseHint,
        resourceLabel = Config.ResourceLabel,
        theme = Theme.Build(Config.Theme),
    }
end)

local lastCheckout = {}

lib.callback.register('djshops:checkout', function(source, payload)
    if type(payload) ~= 'table' then
        return { ok = false, error = Config.Locale.purchase_failed }
    end

    local now = GetGameTimer()
    if lastCheckout[source] and now - lastCheckout[source] < 750 then
        return { ok = false, error = Config.Locale.purchase_failed }
    end
    lastCheckout[source] = now

    local shop = Config.Shops[payload.shopId]
    if not shop or shop.enabled == false then
        return { ok = false, error = Config.Locale.purchase_failed }
    end

    if not isNearShop(source, shop, payload.locationIndex) then
        return { ok = false, error = Config.Locale.too_far }
    end

    local method = payload.method
    local allowed = shop.payments or { 'cash', 'bank' }
    local methodOk = false
    for i = 1, #allowed do
        if allowed[i] == method then
            methodOk = true
            break
        end
    end
    if not methodOk then
        return { ok = false, error = Config.Locale.purchase_failed }
    end

    local cart = payload.cart
    if type(cart) ~= 'table' or #cart == 0 then
        return { ok = false, error = Config.Locale.empty_cart }
    end
    if #cart > Config.MaxCartItems then
        return { ok = false, error = Config.Locale.purchase_failed }
    end

    local catalog = shopItemMap(shop)
    local player, fw = getPlayer(source)
    local total = 0
    local order = {}

    for i = 1, #cart do
        local entry = cart[i]
        if type(entry) ~= 'table' or type(entry.name) ~= 'string' then
            return { ok = false, error = Config.Locale.invalid_item }
        end

        local count = math.floor(tonumber(entry.count) or 0)
        if count < 1 or count > Config.MaxQuantity then
            return { ok = false, error = Config.Locale.purchase_failed }
        end

        local product = catalog[entry.name]
        if not product then
            return { ok = false, error = Config.Locale.invalid_item }
        end

        local data = oxItem(product.name)
        if not data then
            return { ok = false, error = Config.Locale.missing_item_def }
        end

        if product.license and not hasLicense(player, fw, product.license) then
            return { ok = false, error = Config.Locale.missing_license }
        end

        if not exports.ox_inventory:CanCarryItem(source, product.name, count, product.metadata) then
            return { ok = false, error = Config.Locale.cannot_carry }
        end

        total = total + (product.price * count)
        order[#order + 1] = {
            name = product.name,
            count = count,
            metadata = product.metadata,
        }
    end

    if total <= 0 then
        return { ok = false, error = Config.Locale.purchase_failed }
    end

    if method == 'cash' then
        if getCash(source) < total then
            return { ok = false, error = Config.Locale.not_enough_cash }
        end
        if not removeCash(source, total) then
            return { ok = false, error = Config.Locale.not_enough_cash }
        end
    elseif method == 'bank' then
        if getBank(source) < total then
            return { ok = false, error = Config.Locale.not_enough_bank }
        end
        if not removeBank(source, total, shop.label) then
            return { ok = false, error = Config.Locale.not_enough_bank }
        end
    elseif method == 'black_money' then
        if getBlackMoney(source) < total then
            return { ok = false, error = Config.Locale.not_enough_black }
        end
        if not removeBlack(source, total) then
            return { ok = false, error = Config.Locale.not_enough_black }
        end
    else
        return { ok = false, error = Config.Locale.purchase_failed }
    end

    local given = {}
    for i = 1, #order do
        local line = order[i]
        local success = exports.ox_inventory:AddItem(source, line.name, line.count, line.metadata)
        if not success then
            for g = 1, #given do
                exports.ox_inventory:RemoveItem(source, given[g].name, given[g].count, given[g].metadata)
            end
            if method == 'cash' then
                addCash(source, total)
            elseif method == 'bank' then
                addBank(source, total, shop.label)
            else
                addBlack(source, total)
            end
            return { ok = false, error = Config.Locale.cannot_carry }
        end
        given[#given + 1] = line
    end

    return {
        ok = true,
        total = total,
        method = method,
        player = {
            name = playerName(player, fw),
            cash = getCash(source),
            bank = getBank(source),
            black = getBlackMoney(source),
        },
    }
end)

AddEventHandler('playerDropped', function()
    lastCheckout[source] = nil
end)
