-- Option.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 1:48:54 PM

---@type ns
local ns = select(2, ...)

local L = ns.L
local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')

local Option = {}
ns.Option = Option

local order = 0
local function orderGen()
    order = order + 1
    return order
end

local function getOptionRule(item)
    local k = item[2]
    return ns.Addon.db.profile.rules[k], k
end

local Options = {
    type = 'group',
    name = L['tdCC Options'],
    childGroups = 'tab',
    args = {
        themes = {type = 'group', name = L['Themes'], order = 1, args = {}},
        rules = {type = 'group', name = L['Rules'], order = 2, args = {}},
    },
}

local RulesFixed = { --
    add = {type = 'input', name = L['Add rule'], order = orderGen()},
}

local ThemesDropdown = {
    type = 'select',
    name = L['Theme'],
    order = 1,
    values = {},
    get = function(item)
        return ns.Addon.db.profile.rules[item[#item - 1]].theme
    end,
    set = function(item, value)
        ns.Addon.db.profile.rules[item[#item - 1]].theme = value
        Option:ApplyRules()
    end,
}

local RuleOptions = {
    type = 'group',
    name = function(item)
        local rule, k = getOptionRule(item)
        return rule.name or k
    end,
    order = function(item)
        return getOptionRule(item).priority
    end,
    get = function(item)
        return getOptionRule(item)[item[#item]]
    end,
    set = function(item, value)
        getOptionRule(item)[item[#item]] = value
        Option:ApplyRules()
    end,
    args = {
        enable = { --
            type = 'toggle',
            name = ENABLE,
            order = orderGen(),
        },
        delete = {
            type = 'execute',
            name = DELETE,
            order = orderGen(),
            func = function()
                print(222)
            end,
        },
        priority = {
            type = 'range',
            name = 'priority',
            order = orderGen(),
            width = 'full',
            min = 0,
            max = 100,
            step = 1,
            set = function(item, value)
                return Option:SetRulePriority(getOptionRule(item), value)
            end,
        },
        theme = {type = 'select', name = L['Theme'], order = orderGen(), width = 'full', values = {}},
        rule = {type = 'input', name = 'Rule', order = orderGen(), width = 'full', multiline = true},
    },
}

function Option:Load()
    local registry = LibStub('AceConfigRegistry-3.0')
    registry:RegisterOptionsTable('tdCC', Options)

    local dialog = LibStub('AceConfigDialog-3.0')
    dialog:AddToBlizOptions('tdCC', 'tdCC')
end

function Option:Update()

    wipe(Options.args.rules.args)
    wipe(Options.args.themes.args)
    wipe(RuleOptions.args.theme.values)

    for k, v in pairs(ns.Addon.db.profile.themes) do
        -- ThemesOptions[k] = {
        --     type = 'group',
        --     name = v.name or k,
        --     order = orderGen(),
        --     args = {
        --         enable = {type = 'toggle', name = ENABLE},
        --         hideBlizModel = {type = 'toggle', name = L['Hide blizz cooldown model']},
        --     },
        -- }

        RuleOptions.args.theme.values[k] = v.name or k
    end

    for k, v in pairs(RulesFixed) do
        Options.args.rules.args[k] = v
    end

    for k, v in pairs(ns.Addon.db.profile.rules) do
        Options.args.rules.args[k] = RuleOptions
    end

    AceConfigRegistry:NotifyChange('tdCC Options')
end

local function values(t)
    local r = {}
    for k, v in pairs(t) do
        tinsert(r, v)
    end
    return r
end

function Option:SetRulePriority(rule, value)
    rule.priority = value + 0.5

    local rules = values(ns.Addon.db.profile.rules)

    sort(rules, function(a, b)
        return a.priority < b.priority
    end)

    for i, v in ipairs(rules) do
        v.priority = i
    end

    self:ApplyRules()
end

function Option:ApplyRules()
    ns.Addon:InitRules()
end

function ns.Addon:LoadOptionFrame()
    Option:Load()
    Option:Update()
end
