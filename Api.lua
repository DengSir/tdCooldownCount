-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/30/2020, 12:21:34 AM
--
---@type ns
local ns = select(2, ...)

local _G = _G
local type = type
local pairs = pairs
local tinsert = table.insert

local LSM = LibStub('LibSharedMedia-3.0')

local ICONS = {
    ROUND = [[Interface\Cooldown\ping4]],
    BLIZZARD = [[Interface\Cooldown\star4]],
    EXPLOSIVE = [[Interface\Cooldown\starburst]],
}

local SCALES = { --
    ROUND = 4,
    BLIZZARD = 5,
    EXPLOSIVE = 4.5,
    ICON = 4,
}

local DEFAULT_THEME = {
    enable = true,
    hideBlizModel = false,
    minRatio = 0,
    minDuration = 0,
    startRemain = 0,
    shortThreshold = 0,
    expireThreshold = 0,
    checkGCD = false,

    fontFace = LSM:GetDefault('font'),
    fontSize = 20,
    fontStyle = 'OUTLINE',
    point = 'CENTER',
    relativePoint = 'CENTER',
    xOffset = 0,
    yOffset = 0,

    styles = {
        SOON = {color = {r = 1, g = 0.1, b = 0.1}, scale = 1.2},
        SECOND = {color = {r = 0, g = 1, b = 0.5}, scale = 1.1},
        MINUTE = {color = {r = 1, g = 1, b = 0}, scale = 1},
        HOUR = {color = {r = 0.4, g = 0.4, b = 0.4}, scale = 0.8},
    },

    shine = false,
    shineMinDuration = 0,
    shineStyle = 'ICON',
}

ns.THEME_DEFAULT = DEFAULT

function ns.orderGenerater()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end

function ns.deepcopy(src)
    local dest = {}
    for k, v in pairs(src) do
        if type(v) == 'table' then
            dest[k] = ns.deepcopy(v)
        else
            dest[k] = v
        end
    end
    return dest
end

function ns.tmerge(dest, src)
    dest = dest or {}
    for k, v in pairs(src) do
        if type(v) == 'table' then
            dest[k] = ns.tmerge(dest[k], v)
        else
            dest[k] = v
        end
    end
    return dest
end

function ns.tvalues(t)
    local r = {}
    for k, v in pairs(t) do
        tinsert(r, v)
    end
    return r
end

function ns.tcount(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function ns.GetFont(name)
    return LSM:Fetch('font', name)
end

function ns.GetIcon(cooldown, style)
    local icon = ICONS[style]
    if icon then
        return icon, SCALES[style]
    end

    local iconObject = cooldown._tdcc_iconObject
    if not iconObject then
        local parent = cooldown:GetParent()

        iconObject = parent.icon or parent.Icon

        if not iconObject then
            local name = parent:GetName()
            if name then
                iconObject = _G[name .. 'Icon'] or _G[name .. 'IconTexture']
            end
        end

        if not iconObject then
            return
        end

        cooldown._tdcc_iconObject = iconObject
    end
    return iconObject:GetTexture(), SCALES.ICON
end

function ns.CreateThemeData(profile)
    local src = ns.deepcopy(DEFAULT_THEME)
    if not profile then
        return src
    end
    return ns.tmerge(src, profile)
end
