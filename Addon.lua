-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 12:35:06 PM

---@type ns
local ns = select(2, ...)

local L = LibStub('AceLocale-3.0'):GetLocale('tdCC')

local Addon = LibStub('AceAddon-3.0'):NewAddon('tdCC', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')
ns.Addon = Addon
ns.L = L

function Addon:OnInitialize()
    local defaults = {
        profile = { --
            first = true,
            themes = {
                Default = ns.CreateThemeData{ --
                    locked = true,
                    minDuration = 2.2,
                    shortLimit = 600,
                },
            },
            rules = {},
        },
    }

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
            return 'Default'
        end,
    })

    self.db = LibStub('AceDB-3.0'):New('TDDB_COOLDOWN', defaults, true)

    self.db:RegisterCallback('OnProfileReset', function()
        self:SetupDefault()
        self:UpdateRules()
        ns.Option:Update()
        ns.Timer:RefreshAll()
    end)

    self:SetupDefault()

    if self.LoadOptionFrame then
        self:LoadOptionFrame()
    end
end

function Addon:OnEnable()
    self:UpdateRules()

    self:SecureHook(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', 'SetCooldown')
end

function Addon:SetupDefault()
    if not self.db.profile.first then
        return
    end

    self.db.profile.first = false

    local BIG_AURA = L['Big aura']
    local AURA = L['Aura']

    self.db.profile.themes[BIG_AURA] = ns.CreateThemeData{ --
        shine = false,
    }
    self.db.profile.themes[AURA] = ns.CreateThemeData{
        fontSize = 22,
        relativePoint = 'TOPRIGHT',
        shine = false,
        styles = {
            SOON = {color = {r = 1, g = 0.1, b = 0.1}, scale = 1},
            SECOND = {color = {r = 1, g = 1, b = 1}, scale = 1},
            MINUTE = {color = {r = 1, g = 1, b = 1}, scale = 1},
            HOUR = {color = {r = 1, g = 1, b = 1}, scale = 1},
        },
    }

    self.db.profile.rules[BIG_AURA] = {
        priority = 1,
        theme = BIG_AURA,
        rule = 'function(cooldown)\n    return cooldown:GetReverse() and cooldown:GetWidth() > 30\nend',
    }
    self.db.profile.rules[AURA] = {
        priority = 2,
        theme = AURA,
        rule = 'function(cooldown)\n    return cooldown:GetReverse()\nend',
    }
end

local function AlwaysTrue()
    return true
end

function Addon:UpdateRules()
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
    local profile = self:GetCooldownProfile(cooldown)
    if not profile or not profile.enable then
        return
    end
    if duration < profile.minDuration then
        return
    end
    -- if profile.hideHaveCharges and cooldown:GetDrawEdge() then
    --     return
    -- end
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
    return theme and self.db.profile.themes[theme] or self.db.profile.themes.Default
end

function Addon:GetCooldownTheme(cooldown)
    return self.cooldownThemes[cooldown]
end
