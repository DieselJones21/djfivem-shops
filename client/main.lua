local spawned = {}
local uiOpen = false
local currentShop, currentIndex

local function notify(description, nType)
    lib.notify({
        title = Config.ResourceLabel,
        description = description,
        type = nType or 'inform',
        position = Config.Notify.position,
        duration = Config.Notify.duration,
    })
end

local function targetOrder()
    if Config.Target == 'auto' or Config.Target == 'interact' then
        return { 'interact', 'ox_target', 'qb-target' }
    end
    if Config.Target == 'ox_target' then
        return { 'ox_target', 'interact', 'qb-target' }
    end
    if Config.Target == 'qb-target' then
        return { 'qb-target', 'interact', 'ox_target' }
    end
    return { Config.Target, 'interact', 'ox_target', 'qb-target' }
end

local function resolveTarget(waitMs)
    local order = targetOrder()
    local deadline = GetGameTimer() + (waitMs or 0)
    while true do
        for i = 1, #order do
            if GetResourceState(order[i]) == 'started' then
                return order[i]
            end
        end
        if GetGameTimer() >= deadline then
            return order[1]
        end
        Wait(200)
    end
end

local function closeUi()
    if not uiOpen then return end
    uiOpen = false
    currentShop, currentIndex = nil, nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openShop(shopId, locationIndex)
    if uiOpen then return end

    local shop = Config.Shops[shopId]
    local location = shop and shop.locations[locationIndex]
    if not shop or not location then return end

    local ped = PlayerPedId()
    if #(GetEntityCoords(ped) - vector3(location.coords.x, location.coords.y, location.coords.z)) > Config.MaxShopDistance then
        notify(Config.Locale.too_far, 'error')
        return
    end

    local payload = lib.callback.await('djshops:openShop', false, shopId, locationIndex)
    if not payload then
        notify(Config.Locale.no_access, 'error')
        return
    end

    uiOpen = true
    currentShop, currentIndex = shopId, locationIndex
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data = payload,
    })
end

local function addInteraction(ped, shopId, locationIndex, shop)
    local system = resolveTarget()
    local id = ('djshops:%s:%s'):format(shopId, locationIndex)
    local label = shop.interactLabel or Config.Locale.interact

    if system == 'interact' then
        exports.interact:AddLocalEntityInteraction({
            entity = ped,
            id = id,
            name = id,
            distance = 8.0,
            interactDst = Config.InteractDistance,
            offset = vec3(0.0, 0.0, 0.15),
            options = {
                {
                    label = label,
                    action = function()
                        openShop(shopId, locationIndex)
                    end,
                },
            },
        })
    elseif system == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = id,
                icon = 'fa-solid fa-basket-shopping',
                label = label,
                distance = Config.InteractDistance,
                onSelect = function()
                    openShop(shopId, locationIndex)
                end,
            },
        })
    elseif system == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    num = 1,
                    type = 'client',
                    icon = 'fas fa-shopping-basket',
                    label = label,
                    action = function()
                        openShop(shopId, locationIndex)
                    end,
                },
            },
            distance = Config.InteractDistance,
        })
    end
end

local function removeInteraction(entry)
    local system = resolveTarget()
    if system == 'interact' then
        pcall(function()
            exports.interact:RemoveLocalEntityInteraction(entry.ped, entry.id)
        end)
    elseif system == 'ox_target' then
        pcall(function()
            exports.ox_target:removeLocalEntity(entry.ped, entry.id)
        end)
    elseif system == 'qb-target' then
        pcall(function()
            exports['qb-target']:RemoveTargetEntity(entry.ped)
        end)
    end
end

local function spawnPed(shop, location)
    local model = shop.ped and shop.ped.model or 'mp_m_shopkeep_01'
    local hash = joaat(model)

    if not lib.requestModel(hash, 10000) then
        warn(('[djfivem-shops] failed to load ped model %s'):format(model))
        return
    end

    local c = location.coords
    local ped = CreatePed(0, hash, c.x, c.y, c.z - 1.0, c.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedDiesWhenInjured(ped, false)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedCanBeTargetted(ped, false)
    SetPedDefaultComponentVariation(ped)

    if shop.ped and shop.ped.scenario then
        TaskStartScenarioInPlace(ped, shop.ped.scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(hash)
    return ped
end

local function createBlip(shop, location)
    if not shop.blip then return end
    local c = location.coords
    local blip = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(blip, shop.blip.sprite or 52)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, shop.blip.scale or Config.BlipScale)
    SetBlipColour(blip, shop.blip.color or 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(shop.blip.label or shop.label)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function cleanup()
    closeUi()
    for i = 1, #spawned do
        local entry = spawned[i]
        removeInteraction(entry)
        if entry.blip and DoesBlipExist(entry.blip) then
            RemoveBlip(entry.blip)
        end
        if entry.ped and DoesEntityExist(entry.ped) then
            DeleteEntity(entry.ped)
        end
    end
    spawned = {}
end

local function spawnShops()
    cleanup()

    local system = resolveTarget(15000)
    if GetResourceState(system) ~= 'started' then
        print(('[djfivem-shops] %s is not started; peds spawned without a target system'):format(system))
    end

    for shopId, shop in pairs(Config.Shops) do
        if shop.enabled ~= false then
            for index, location in ipairs(shop.locations) do
                local ped = spawnPed(shop, location)
                if ped and DoesEntityExist(ped) then
                    local id = ('djshops:%s:%s'):format(shopId, index)
                    addInteraction(ped, shopId, index, shop)
                    spawned[#spawned + 1] = {
                        id = id,
                        ped = ped,
                        blip = createBlip(shop, location),
                        shopId = shopId,
                        index = index,
                    }
                end
            end
        end
    end
end

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb({ ok = true })
end)

RegisterNUICallback('checkout', function(data, cb)
    if not uiOpen or not currentShop then
        cb({ ok = false, error = Config.Locale.purchase_failed })
        return
    end

    local result = lib.callback.await('djshops:checkout', false, {
        shopId = currentShop,
        locationIndex = currentIndex,
        method = data and data.method,
        cart = data and data.cart,
    })

    if result and result.ok then
        notify(Config.Locale.purchase_success, 'success')
        SendNUIMessage({
            action = 'purchased',
            data = result,
        })
        cb(result)
        return
    end

    local err = result and result.error or Config.Locale.purchase_failed
    notify(err, 'error')
    cb({ ok = false, error = err })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cleanup()
    end
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(250)
    end
    Wait(1500)
    spawnShops()
end)

exports('OpenShop', openShop)
