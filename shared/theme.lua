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
        if type(colors[i]) == 'string' and colors[i] ~= '' then
            cleaned[#cleaned + 1] = colors[i]
        end
    end
    if #cleaned == 0 then
        cleaned = { '#ffffff', '#8a8a8a', '#3a3a3a' }
    end
    local glow = grad.glow or cleaned[math.max(1, math.ceil(#cleaned / 2))]
    return {
        angle = grad.angle or 90,
        colors = cleaned,
        inkOnAccent = grad.inkOnAccent or '#ffffff',
        glow = glow,
        preset = (type(name) == 'string' and name ~= '') and name or 'custom',
    }
end

function Theme.Build(theme)
    theme = theme or Config.Theme
    local grad = Theme.ResolveGradient(theme)
    local r, g, b = Theme.HexToRgb(grad.glow)
    local startColor = grad.colors[1]
    local midColor = grad.colors[math.max(1, math.ceil(#grad.colors / 2))]
    local endColor = grad.colors[#grad.colors]
    local preset = (theme.Presets and theme.Presets[grad.preset]) or {}
    return {
        appName = preset.appName or theme.appName or 'DJ FiveM',
        appTag = preset.appTag or theme.appTag or 'Scripts',
        logo = preset.logo or theme.logo or 'img/dj-fivem-scripts.webp',
        preset = grad.preset,
        gradientAngle = grad.angle,
        gradientColors = grad.colors,
        onAccent = grad.inkOnAccent,
        glow = grad.glow,
        accent = midColor,
        accentHot = startColor,
        ember = startColor,
        crimson = endColor,
        ink = theme.ink,
        muted = theme.muted,
        screen = theme.screen,
        paper = theme.paper,
        wash = theme.wash,
        panel = theme.panel,
        card = theme.card,
        card2 = theme.card2,
        line = theme.line,
        bezelTop = theme.bezelTop,
        bezelMid = theme.bezelMid,
        bezelBottom = theme.bezelBottom,
        accentRgb = ('%s, %s, %s'):format(r, g, b),
        accentFill = Theme.LinearGradient(grad.angle, grad.colors),
        accentFillV = Theme.LinearGradient(180, grad.colors),
        presets = theme.Presets,
    }
end
