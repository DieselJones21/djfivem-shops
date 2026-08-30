dofile('shared/validate.lua')

local function fail(msg)
    io.stderr:write('FAIL: ' .. msg .. '\n')
    os.exit(1)
end

if ShopGuard.ShopId('general') ~= true then fail('shop id') end
if ShopGuard.ShopId('../evil') then fail('shop id traversal') end
if ShopGuard.ShopId('ammunation; drop') then fail('shop id junk') end

if ShopGuard.ItemName('WEAPON_APPISTOL') ~= true then fail('weapon name') end
if ShopGuard.ItemName('ammo-9') ~= true then fail('ammo name') end
if ShopGuard.ItemName('sandwich; all') then fail('item junk') end
if ShopGuard.ItemName('../money') then fail('item traversal') end

if ShopGuard.LocationIndex('2', 9) ~= 2 then fail('location') end
if ShopGuard.LocationIndex(0, 3) then fail('location zero') end
if ShopGuard.LocationIndex(4, 3) then fail('location over') end

if ShopGuard.Price(4) ~= 4 then fail('price') end
if ShopGuard.Price(0) then fail('price zero') end
if ShopGuard.Price(-10) then fail('price negative') end
if ShopGuard.Price(4.5) then fail('price float') end

if ShopGuard.Method('cash', { 'cash', 'bank' }) ~= 'cash' then fail('method cash') end
if ShopGuard.Method('black_money', { 'cash', 'bank' }) then fail('method not sold') end
if ShopGuard.Method('bitcoin', { 'cash', 'bank' }) then fail('method unknown') end

if ShopGuard.SafeLogo('img/the-305.webp') ~= 'img/the-305.webp' then fail('logo 305') end
if ShopGuard.SafeLogo('img/../config.lua') ~= 'img/dj-fivem-scripts.webp' then fail('logo traversal') end
if ShopGuard.SafeLogo('https://example.com/x.webp') ~= 'img/dj-fivem-scripts.webp' then fail('logo remote') end

local catalog = {
    sandwich = { name = 'sandwich', price = 4 },
    water = { name = 'water', price = 2 },
}

local ok = ShopGuard.BuildOrder({
    { name = 'sandwich', count = 2 },
    { name = 'water', count = 1 },
}, catalog, 25, 20)
if not ok or ok.total ~= 10 or #ok.order ~= 2 then
    fail('order total ' .. tostring(ok and ok.total))
end

local stacked = ShopGuard.BuildOrder({
    { name = 'sandwich', count = 10 },
    { name = 'sandwich', count = 10 },
}, catalog, 25, 20)
if not stacked or stacked.order[1].count ~= 20 or stacked.total ~= 80 then
    fail('merged stack')
end

local overflow, overflowErr = ShopGuard.BuildOrder({
    { name = 'sandwich', count = 20 },
    { name = 'sandwich', count = 10 },
}, catalog, 25, 20)
if overflow or overflowErr ~= 'purchase_failed' then
    fail('stack cap')
end

local ghost, ghostErr = ShopGuard.BuildOrder({
    { name = 'sandwich', count = 1, price = 1 },
}, catalog, 25, 20)
if not ghost or ghost.total ~= 4 then
    fail('client price ignored')
end

local missing, missingErr = ShopGuard.BuildOrder({
    { name = 'lockpick', count = 1 },
}, catalog, 25, 20)
if missing or missingErr ~= 'invalid_item' then
    fail('unknown item')
end

local tooMany = {}
for i = 1, 21 do
    tooMany[i] = { name = 'sandwich', count = 1 }
end
local flooded, floodErr = ShopGuard.BuildOrder(tooMany, catalog, 25, 20)
if flooded or floodErr ~= 'purchase_failed' then
    fail('cart flood')
end

print('ok')
