Config = {
    Theme = {
        preset = 'lava',
        appName = 'DJ FiveM',
        appTag = 'Scripts',
        logo = 'img/dj-fivem-scripts.webp',
        gradient = { angle = 10, colors = { '#111111' } },
        Presets = {
            lava = {
                angle = 90,
                colors = { '#ffb347', '#e10600', '#7a00c8' },
                inkOnAccent = '#ffffff',
                glow = '#e10600',
            },
        },
        ink = '#fff',
    },
}

dofile('shared/theme.lua')

local function fail(msg)
    io.stderr:write('FAIL: ' .. msg .. '\n')
    os.exit(1)
end

local css = Theme.LinearGradient(90, { '#ffb347', '#e10600', '#7a00c8' })
if css ~= 'linear-gradient(90deg, #ffb347 0%, #e10600 50%, #7a00c8 100%)' then
    fail('linear = ' .. css)
end

local built = Theme.Build(Config.Theme)
if built.preset ~= 'lava' then fail('preset ' .. tostring(built.preset)) end
if built.accentFill:find('#7a00c8', 1, true) == nil then fail('missing purple stop') end
if built.onAccent ~= '#ffffff' then fail('ink') end
if built.logo ~= 'img/dj-fivem-scripts.webp' then fail('logo') end

Config.Theme.preset = ''
local custom = Theme.Build(Config.Theme)
if custom.preset ~= 'custom' then fail('custom preset') end
if custom.accentFill:find('#111111', 1, true) == nil then fail('custom color') end

print('ok')
