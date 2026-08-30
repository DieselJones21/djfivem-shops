ShopGuard = {}

local ITEM_NAME = '^[%w_%-]+$'
local SHOP_ID = '^[%w_]+$'
local LOGO_PATH = '^img/[%w._-]+%.[Ww][Ee][Bb][Pp]$'
local HEX = '^#%x%x%x%x%x%x$'
local HEX_SHORT = '^#%x%x%x$'
local RGB = '^rgba?%([%d%s.,%%]+%)$'

function ShopGuard.ShopId(shopId)
    return type(shopId) == 'string' and shopId:match(SHOP_ID) ~= nil and #shopId <= 64
end

function ShopGuard.ItemName(name)
    return type(name) == 'string' and name:match(ITEM_NAME) ~= nil and #name >= 1 and #name <= 64
end

function ShopGuard.LocationIndex(index, maxIndex)
    local n = math.floor(tonumber(index) or 0)
    maxIndex = math.floor(tonumber(maxIndex) or 0)
    if n < 1 or maxIndex < 1 or n > maxIndex then
        return nil
    end
    return n
end

function ShopGuard.Price(value)
    local n = tonumber(value)
    if not n or n ~= n or n < 1 or n > 10000000 or n ~= math.floor(n) then
        return nil
    end
    return n
end

function ShopGuard.Quantity(value, maxQuantity)
    local n = math.floor(tonumber(value) or 0)
    maxQuantity = math.floor(tonumber(maxQuantity) or 0)
    if n < 1 or maxQuantity < 1 or n > maxQuantity then
        return nil
    end
    return n
end

function ShopGuard.Method(method, allowed)
    if type(method) ~= 'string' then
        return nil
    end
    if method ~= 'cash' and method ~= 'bank' and method ~= 'black_money' then
        return nil
    end
    if type(allowed) ~= 'table' then
        allowed = { 'cash', 'bank' }
    end
    for i = 1, #allowed do
        if allowed[i] == method then
            return method
        end
    end
    return nil
end

function ShopGuard.SafeColor(value)
    value = tostring(value or ''):gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    if value:match(HEX) or value:match(HEX_SHORT) or value:match(RGB) then
        return value
    end
end

function ShopGuard.SafeLogo(path)
    path = tostring(path or '')
    if path:match(LOGO_PATH) and not path:find('..', 1, true) then
        return path
    end
    return 'img/dj-fivem-scripts.webp'
end

function ShopGuard.Label(text, fallback)
    text = tostring(text or ''):gsub('%c', ''):sub(1, 64)
    if text == '' then
        return fallback or 'Shop'
    end
    return text
end

--- Merge a client cart into unique catalog lines. Prices always come from `catalog`.
function ShopGuard.BuildOrder(cart, catalog, maxQuantity, maxCartItems)
    if type(cart) ~= 'table' or type(catalog) ~= 'table' then
        return nil, 'empty_cart'
    end

    maxQuantity = math.floor(tonumber(maxQuantity) or 0)
    maxCartItems = math.floor(tonumber(maxCartItems) or 0)
    if maxQuantity < 1 or maxCartItems < 1 then
        return nil, 'purchase_failed'
    end

    if #cart == 0 or #cart > maxCartItems then
        return nil, #cart == 0 and 'empty_cart' or 'purchase_failed'
    end

    local names = {}
    local counts = {}

    for i = 1, #cart do
        local entry = cart[i]
        if type(entry) ~= 'table' or not ShopGuard.ItemName(entry.name) then
            return nil, 'invalid_item'
        end

        local count = ShopGuard.Quantity(entry.count, maxQuantity)
        if not count then
            return nil, 'purchase_failed'
        end

        if counts[entry.name] then
            local combined = counts[entry.name] + count
            if combined > maxQuantity then
                return nil, 'purchase_failed'
            end
            counts[entry.name] = combined
        else
            names[#names + 1] = entry.name
            counts[entry.name] = count
        end
    end

    if #names == 0 then
        return nil, 'empty_cart'
    end

    local order = {}
    local total = 0

    for i = 1, #names do
        local name = names[i]
        local product = catalog[name]
        if not product or product.name ~= name then
            return nil, 'invalid_item'
        end

        local price = ShopGuard.Price(product.price)
        if not price then
            return nil, 'purchase_failed'
        end

        local count = counts[name]
        total = total + (price * count)
        order[#order + 1] = {
            name = product.name,
            count = count,
            metadata = type(product.metadata) == 'table' and product.metadata or nil,
            price = price,
            license = product.license,
        }
    end

    if total < 1 or total ~= math.floor(total) or total > 100000000 then
        return nil, 'purchase_failed'
    end

    return {
        order = order,
        total = total,
    }
end
