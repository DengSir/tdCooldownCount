-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 12:35:06 PM

---@type ns
local ns = select(2, ...)

local LibMedia = LibStub('LibSharedMedia-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale('tdCC')

local Addon = LibStub('AceAddon-3.0'):NewAddon('tdCC', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')
ns.Addon = Addon
ns.L = L

function Addon:OnInitialize()
    local order = 0
    local function orderGen()
        order = order + 1
        return order
    end

    local defaults = {
        profile = {
            themes = {
                aura = {
                    name = L['Aura'],
                    enable = true,
                    hideBlizModel = true,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 0,
                    startRemain = 0,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 26,
                    fontStyle = 'OUTLINE',
                    point = 'CENTER',
                    relativePoint = 'TOPRIGHT',
                    xOffset = 0,
                    yOffset = 0,

                    styles = {
                        SOON = {r = 1, g = 0.1, b = 0.1, scale = 1},
                        SECOND = {r = 1, g = 1, b = 1, scale = 1},
                        MINUTE = {r = 1, g = 1, b = 1, scale = 1},
                        HOUR = {r = 1, g = 1, b = 1, scale = 1},
                    },

                    shine = false,
                },
                action = {
                    name = L['Action'],
                    enable = true,
                    hideBlizModel = false,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 2.2,
                    startRemain = 0,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 20,
                    fontStyle = 'OUTLINE',
                    point = 'CENTER',
                    relativePoint = 'CENTER',
                    xOffset = 0,
                    yOffset = 0,

                    styles = {
                        SOON = {r = 1, g = 0.1, b = 0.1, scale = 1.2},
                        SECOND = {r = 1, g = 1, b = 1, scale = 1},
                        MINUTE = {r = 0.8, g = 0.6, b = 0, scale = 1},
                        HOUR = {r = 0.4, g = 0.4, b = 0.4, scale = 1},
                    },

                    shine = true,
                    shineMinDuration = 0,
                    shineType = 'ICON',
                    shineScale = 4,
                    shineDuration = 0.6,
                },
                BigDebuff = {
                    enable = true,
                    hideBlizModel = false,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 2.2,
                    startRemain = 0,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 20,
                    fontStyle = 'OUTLINE',
                    point = 'CENTER',
                    relativePoint = 'CENTER',
                    xOffset = 0,
                    yOffset = 0,

                    styles = {
                        SOON = {r = 1, g = 0.1, b = 0.1, scale = 1.2},
                        SECOND = {r = 1, g = 1, b = 1, scale = 1},
                        MINUTE = {r = 0.8, g = 0.6, b = 0, scale = 1},
                        HOUR = {r = 0.4, g = 0.4, b = 0.4, scale = 1},
                    },

                    shine = false,
                },
            },
            rules = {
                BigDebuff = {
                    priority = orderGen(),
                    theme = 'BigDebuff',
                    rule = [[
function(cooldown)
    return cooldown:GetName():find('BigDebuff')
end]],
                },
                Aura = {
                    name = L['Aura'],
                    priority = orderGen(),
                    theme = 'aura',
                    rule = [[
function(cooldown)
    return cooldown:GetReverse()
end]],
                },
                Default = {name = DEFAULT, priority = orderGen(), theme = 'action'},
            },
        },
    }

    ---@class Rule
    ---@field name string
    ---@field theme string
    ---@field priority number
    ---@field rule fun(cooldown:Cooldown): boolean

    ---@type Rule[]
    self.rules = {}

    self.cooldownThemes = setmetatable({}, {
        __index = function(t, cooldown)
            for _, rule in ipairs(self.rules) do
                if rule.rule(cooldown) then
                    t[cooldown] = rule.theme
                    return rule.theme
                end
            end
        end,
    })

    self.db = LibStub('AceDB-3.0'):New('TDDB_COOLDOWN', defaults, true)

    self:InitRules()

    self.db:RegisterCallback('OnProfileReset', function()
        ns.Timer:RefreshAll()
    end)

    if self.LoadOptionFrame then
        self:LoadOptionFrame()
    end
end

local function AlwaysTrue()
    return true
end

function Addon:InitRules()
    local rules = wipe(self.rules)

    for k, v in pairs(self.db.profile.rules) do
        tinsert(rules, {
            name = v.name or k,
            priority = v.priority,
            theme = v.theme,
            rule = v.rule and loadstring('return ' .. v.rule)() or AlwaysTrue,
        })
    end

    sort(rules, function(a, b)
        return a.priority < b.priority
    end)

    wipe(self.cooldownThemes)

    ns.Timer:RefreshAll()
end

function Addon:GetFont(name)
    return LibMedia:Fetch('font', name)
end

function Addon:OnEnable()
    self:SecureHook(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', 'SetCooldown')
end

function Addon:SetCooldown(cooldown, start, duration, m)
    local show, keep = self:ShouldShow(cooldown, start, duration)
    if keep then
        return
    end
    if show then
        return ns.Timer:StartTimer(cooldown, start, duration)
    else
        return ns.Timer:StopTimer(cooldown, start, duration)
    end
end

function Addon:ShouldShow(cooldown, start, duration)
    if cooldown.noCooldownCount then
        return
    end
    if cooldown:IsPaused() then
        return
    end
    if not start or start == 0 then
        return
    end
    if not duration or duration == 0 then
        return
    end
    local set = self:GetCooldownProfile(cooldown)
    if not set or not set.enable then
        return
    end
    if duration < set.minDuration then
        return
    end
    if set.hideHaveCharges and cooldown:GetDrawEdge() then
        return
    end
    local gcdStart, gcdDuration = GetSpellCooldown(29515) -- 29515/61304
    if gcdStart == start and gcdDuration == duration then
        local timer = ns.Timer:GetTimer(cooldown)
        if not timer then
            return
        end

        if timer:GetRemain() < gcdDuration + 0.05 then
            return true, true
        end
    end
    return true, false
end

function Addon:GetCooldownProfile(cooldown)
    local theme = self:GetCooldownTheme(cooldown)
    return theme and self.db.profile.themes[theme]
end

function Addon:GetCooldownTheme(cooldown)
    return self.cooldownThemes[cooldown]
end
