-- Addon.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 12:35:06 PM
---@type ns
local ns = select(2, ...)

local L = LibStub('AceLocale-3.0'):GetLocale('tdCC')

---@type Addon
local Addon = LibStub('AceAddon-3.0'):NewAddon('tdCC', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-2.0')
ns.Addon = Addon
ns.L = L

function Addon:OnInitialize()
    local defaults = {
        profile = { --
            first = true,
            themes = {
                [ns.THEME_DEFAULT] = ns.CreateThemeData {
                    locked = true,
                    shortThreshold = 600,
                    checkGCD = true,
                    shine = true,
                },
            },
            rules = {},
        },
    }

    self.db = LibStub('AceDB-3.0'):New('TDDB_COOLDOWN', defaults, true)

    self.db:RegisterCallback('OnProfileReset', function()
        self:SetupDefault()
        self:FixThemes()
        self:UpdateRules()
        self:UpdateOptionFrame()
        self:RefreshAllTimers()
    end)

    self:SetupDefault()
    self:FixThemes()
    self:LoadOptionFrame()
end

function Addon:OnEnable()
    self:UpdateRules()
    self:SetupHooks()
end

function Addon:FixThemes()
    for k, v in pairs(self.db.profile.themes) do
        self.db.profile.themes[k] = ns.CreateThemeData(v)
    end
end

function Addon:SetupDefault()
    if not self.db.profile.first then
        return
    end

    self.db.profile.first = false

    local THEME_LARGE_AURA = L['Large aura']
    local THEME_SMALL_AURA = L['Aura']
    local RULE_LARGE_AURA = L['Large aura']
    local RULE_SMALL_AURA = L['Aura']

    self.db.profile.themes[THEME_LARGE_AURA] = ns.CreateThemeData { --
        shine = false,
    }
    self.db.profile.themes[THEME_SMALL_AURA] = ns.CreateThemeData {
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

    self.db.profile.rules[RULE_LARGE_AURA] = {
        enable = true,
        priority = 1,
        theme = THEME_LARGE_AURA,
        rule = 'function(cooldown)\n    return cooldown:GetReverse() and cooldown:GetWidth() > 30\nend',
    }
    self.db.profile.rules[RULE_SMALL_AURA] = {
        enable = true,
        priority = 2,
        theme = THEME_SMALL_AURA,
        rule = 'function(cooldown)\n    return cooldown:GetReverse()\nend',
    }
end
