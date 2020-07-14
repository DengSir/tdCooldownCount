-- Rules.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/1/2020, 3:49:19 PM

---@type ns
local ns = select(2, ...)

local wipe, sort = table.wipe, table.sort
local tinsert = table.insert
local pairs, loadstring = pairs, loadstring

local Addon = ns.Addon

local THEME_DEFAULT = ns.THEME_DEFAULT

local rules = {}
local cooldownThemes = setmetatable({}, {
    __index = function(t, cooldown)
        for _, rule in ipairs(rules) do
            if rule.rule(cooldown) then
                t[cooldown] = rule.theme
                return rule.theme
            end
        end
        return THEME_DEFAULT
    end,
})

local function AlwaysTrue()
    return true
end

function Addon:UpdateRules()
    local rules = wipe(rules)

    for k, v in pairs(self.db.profile.rules) do
        if v.enable then
            tinsert(rules, {
                name = v.name or k,
                priority = v.priority,
                theme = v.theme,
                rule = ns.BuildRule(v.rule) or AlwaysTrue,
            })
        end
    end

    sort(rules, function(a, b)
        return a.priority < b.priority
    end)

    wipe(cooldownThemes)

    self:RefreshAllTimers()
end

function Addon:GetCooldownTheme(cooldown)
    return cooldownThemes[cooldown]
end
