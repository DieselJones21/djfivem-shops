# djfivem-shops

Ped-based shops for **ox_inventory** with a red/black dashboard UI, **cash or bank** checkout (Renewed Banking statements), and **interact** support.

## Shops

| Shop | What it sells | Locations |
| --- | --- | --- |
| 24/7 | `sandwich`, `water`, `ecola` | All vanilla 24/7 clerks |
| LTD Gasoline | `sandwich`, `water`, `ecola` | Grove, Little Seoul, Richman, Mirror Park, Grapeseed |
| Rob's Liquor | `sandwich`, `water`, `ecola` | All Rob's Liquor clerks |
| Ammunation | `WEAPON_APPISTOL`, `WEAPON_ASSAULTRIFLE`, `WEAPON_PUMPSHOTGUN`, `ammo-9`, `ammo-44`, `ammo-rifle`, `ammo-rifle2`, `ammo-shotgun` | All 11 Ammunation clerks |
| YouTool | `lockpick`, `repair_kit` | Davis, Harmony, Paleto |
| Digital Den | `phone`, `radio` | Legion, Mirror Park, Rockford, Little Seoul |
| Pharmacy | Disabled until medical items are added | Pillbox, Vinewood, Sandy, Paleto |
| The Backroom | `robbery_tablet`, `lockpick`, `drill`, `electronickit`, `thermite`, `crowbar` | Hidden peds, no blip |
| Street Chemist | `baggies`, `acetone`, `cups`, `sprite`, `hard_candies` | Hidden peds, no blip |

Every location uses a frozen invincible ped. Legal shops have red-tinted map blips. Illegal shops do not.

Ammunation firearms require a `weapon` license. Ammo does not. Missing licenses are shown in the UI and blocked on the server.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [interact](https://github.com/darktrovx/interact) (preferred) or `ox_target` / `qb-target`
- qbx_core, qb-core, or ESX
- [Renewed-Banking](https://github.com/Renewed-Scripts/Renewed-Banking) for bank statement lines

## Install

1. Drop this resource in your server as `djfivem-shops`.
2. Add to `server.cfg` **after** inventory, banking, and interact:

```cfg
ensure ox_lib
ensure ox_inventory
ensure interact
ensure Renewed-Banking
ensure djfivem-shops
```

3. Stop **qb-shops** (or any other shop script) so you do not get double peds.
4. Clear or comment the default shops in `ox_inventory/data/shops.lua` if you still see ox shop markers.
5. Restart the server.

`config/config.lua` defaults to `Config.Target = 'auto'`, which uses **interact** when it is started.

## Payments

- **Cash** comes from the ox_inventory `money` item by default.
- **Bank** removes player bank money through qbx / qb / ESX, then logs a withdraw on **Renewed-Banking**.
- Robbery and drug shops also accept **dirty money** (`black_money`).

If your cash is on the framework account instead of the `money` item:

```lua
Config.Money.cash = 'framework'
```

## Items

Catalogs live in `config/shops.lua` and use the server item names listed above. Change `price` next to each item as needed.

**Items that are not registered in ox_inventory are hidden automatically.**

Pharmacy is in the config but disabled (`enabled = false`) because no medical items were in the list. Send those names and it can be turned on.

Weapon metadata example:

```lua
I('WEAPON_APPISTOL', 4500, 'pistols', { license = 'weapon', metadata = { registered = true } })
```

Images load from `nui://ox_inventory/web/images/`. Change `Config.ImagePath` if your icons live somewhere else.

## Branding

Drop a logo in `html/logo.png` (or `.svg` / `.jpg`) and set it in `config/config.lua`:

```lua
Config.Branding = {
    logo = 'logo.png',
}
```

You can also send a logo here and it will be wired in.

## Config extras

- Move peds by editing `locations` `vector4(x, y, z, heading)`.
- Disable a shop with `enabled = false`.
- Restrict payment methods with `payments = { 'cash', 'bank' }`.
- Hide a blip with `blip = false`.

## Exports

```lua
-- Client
exports['djfivem-shops']:OpenShop('general', 1)
```
