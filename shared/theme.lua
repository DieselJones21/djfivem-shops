Theme = {}

function Theme.HexToRgb(hex)
    hex = tostring(hex or ''):gsub('#', '')
    if #hex ~= 6 then
        return 232, 232, 232
    end
    return tonumber(hex:sub(1, 2), 16) or 232, tonumber(hex:sub(3, 4), 16) or 232, tonumber(hex:sub(5, 6), 16) or 232
end

function Theme.LinearGradient(angle, colors)
    angle = tonumber(angle) or 90
    if type(colors) ~= 'table' or #colors == 0 then
        colors = { '#e8e8e8' }
    end
    local parts = {}
    local last = math.max(#colors - 1, 1)
    for i = 1, #colors do
        local pct = math.floor(((i - 1) / last) * 100 + 0.5)
        parts[#parts + 1] = ('%s %s%%'):format(colors[i], pct)
    end
    return ('linear-gradient(%sdeg, %s)'):format(angle, table.concat(parts, ', '))
end

function Theme.ResolveGradient(theme)
    theme = theme or Config.Theme
    local grad = theme.gradient or {}
    local name = theme.preset
    if type(name) == 'string' and name ~= '' and theme.Presets and theme.Presets[name] then
        grad = theme.Presets[name]
    end
    local colors = grad.colors or { grad.ember, grad.accent, grad.crimson }
    local cleaned = {}
    for i = 1, #(colors or {}) do
        local color = ShopGuard and ShopGuard.SafeColor(colors[i]) or colors[i]
        if type(color) == 'string' and color ~= '' then
            cleaned[#cleaned + 1] = color
        end
    end
    if #cleaned == 0 then
        cleaned = { '#ffffff', '#8a8a8a', '#3a3a3a' }
    end
    local glow = (ShopGuard and ShopGuard.SafeColor(grad.glow)) or cleaned[math.max(1, math.ceil(#cleaned / 2))]
    local ink = (ShopGuard and ShopGuard.SafeColor(grad.inkOnAccent)) or '#ffffff'
    return {
        angle = tonumber(grad.angle) or 90,
        colors = cleaned,
        inkOnAccent = ink,
        glow = glow,
        preset = (type(name) == 'string' and name ~= '') and name or 'custom',
    }
end

local function paint(value, fallback)
    if ShopGuard then
        return ShopGuard.SafeColor(value) or fallback
    end
    return value or fallback
end

function Theme.Build(theme)
    theme = theme or Config.Theme
    local grad = Theme.ResolveGradient(theme)
    local r, g, b = Theme.HexToRgb(grad.glow)
    local startColor = grad.colors[1]
    local midColor = grad.colors[math.max(1, math.ceil(#grad.colors / 2))]
    local endColor = grad.colors[#grad.colors]
    local preset = (theme.Presets and theme.Presets[grad.preset]) or {}
    local logo = preset.logo or theme.logo or 'img/dj-fivem-scripts.webp'
    if ShopGuard then
        logo = ShopGuard.SafeLogo(logo)
    end
    local label = ShopGuard and ShopGuard.Label or function(v, f) return v or f end
    return {
        appName = label(preset.appName or theme.appName, 'DJ FiveM'),
        appTag = label(preset.appTag or theme.appTag, 'Scripts'),
        logo = logo,
        preset = grad.preset,
        gradientAngle = grad.angle,
        gradientColors = grad.colors,
        onAccent = grad.inkOnAccent,
        glow = grad.glow,
        accent = midColor,
        accentHot = startColor,
        ember = startColor,
        crimson = endColor,
        ink = paint(theme.ink, '#f5f5f5'),
        muted = paint(theme.muted, '#8a8a8a'),
        screen = paint(theme.screen, '#0b0b0b'),
        paper = paint(theme.paper, '#161616'),
        wash = paint(theme.wash, '#101010'),
        panel = paint(theme.panel, '#141414'),
        card = paint(theme.card, '#1a1a1a'),
        card2 = paint(theme.card2, '#202020'),
        line = paint(theme.line, 'rgba(255, 255, 255, 0.08)'),
        bezelTop = paint(theme.bezelTop, '#2a2a2a'),
        bezelMid = paint(theme.bezelMid, '#141414'),
        bezelBottom = paint(theme.bezelBottom, '#0a0a0a'),
        accentRgb = ('%s, %s, %s'):format(r, g, b),
        accentFill = Theme.LinearGradient(grad.angle, grad.colors),
        accentFillV = Theme.LinearGradient(180, grad.colors),
    }
end
