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

local Rules = {}
local Themes = {}
local ThemesDropdown = {}

local function tvalues(t)
    local r = {}
    for k, v in pairs(t) do
        tinsert(r, v)
    end
    return r
end

local function tcount(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

local orderGen = ns.orderGenerater()

local function getOptionRule(item)
    local k = item[2]
    return ns.Addon.db.profile.rules[k], k
end

local function getOptionTheme(item)
    local k = item[2]
    return ns.Addon.db.profile.themes[k], k
end

local function toggle(name)
    return {type = 'toggle', name = name, order = orderGen()}
end

local function fullToggle(name)
    return {type = 'toggle', name = name, width = 'full', order = orderGen()}
end

local function range(name, min, max, step)
    return {type = 'range', name = name, order = orderGen(), min = min, max = max, step = step}
end

local function fullRange(name, min, max, step)
    return {type = 'range', name = name, width = 'full', order = orderGen(), min = min, max = max, step = step}
end

local function drop(name, values)
    local opts = { --
        type = 'select',
        name = name,
        order = orderGen(),
    }

    if type(values) == 'function' then
        opts.values = values
    else
        opts.values = {}
        opts.sorting = {}

        for i, v in ipairs(values) do
            opts.values[v.value] = v.name
            opts.sorting[i] = v.value
        end
    end
    return opts
end

local function point(name)
    return drop(name, {
        {name = L['TOPLEFT'], value = 'TOPLEFT'}, {name = L['TOP'], value = 'TOP'},
        {name = L['TOPRIGHT'], value = 'TOPRIGHT'}, {name = L['LEFT'], value = 'LEFT'},
        {name = L['CENTER'], value = 'CENTER'}, {name = L['RIGHT'], value = 'RIGHT'},
        {name = L['BOTTOMLEFT'], value = 'BOTTOMLEFT'}, {name = L['BOTTOM'], value = 'BOTTOM'},
        {name = L['BOTTOMRIGHT'], value = 'BOTTOMRIGHT'},
    })
end

local function group(name)
    return function(args)
        return {type = 'group', name = name, order = orderGen(), args = args}
    end
end

local function inline(name)
    return function(args)
        return {type = 'group', name = name, order = orderGen(), inline = true, args = args}
    end
end

local function rgba(name)
    return {type = 'color', name = name, order = orderGen(), hasAlpha = true, width = 'half'}
end

local function style(name)
    return inline(name){scale = range(L['Scale'], 0.5, 3, 0.1), color = rgba(L['Color'])}
end

local function header(name)
    return {type = 'header', name = name, order = orderGen()}
end

local function add(name, set)
    return {type = 'input', name = name, order = orderGen(), set = set}
end

local Options = {
    type = 'group',
    name = L['tdCC Options'],
    childGroups = 'tab',
    args = {
        themes = {type = 'group', name = L['Themes'], order = 1, args = Themes},
        rules = {type = 'group', name = L['Rules'], order = 2, args = Rules},
    },
}

local RulesFixed = { --
    __add__ = add(L['Add rule'], function(_, value)
        return Option:AddRule(value)
    end),
}

local ThemesFixed = { --
    __add__ = add(L['Add theme'], function(_, value)
        return Option:AddTheme(value)
    end),
}

local ThemeOption = {
    type = 'group',
    childGroups = 'tab',
    name = function(item)
        local theme, k = getOptionTheme(item)
        return theme.name or k
    end,
    get = function(item)
        return getOptionTheme(item)[item[#item]]
    end,
    set = function(item, value)
        getOptionTheme(item)[item[#item]] = value
        Option:ApplyThemes()
    end,
    args = {
        enable = toggle(ENABLE),
        delete = {
            type = 'execute',
            name = DELETE,
            order = orderGen(),
            func = function()

            end,
            disabled = function(item)
                return getOptionTheme(item).locked
            end,
        },
        general = group(L['GENERAL']){ --
            hideBlizModel = fullToggle(L['Hide blizz cooldown model']),
            startRemain = fullRange(L['Remaining how long after the start timer'], 0, 600, 1),
        },
        font = group(L['Font & Position']){
            fontFace = {
                type = 'select',
                name = L['Font face'],
                order = orderGen(),
                dialogControl = 'LSM30_Font',
                values = AceGUIWidgetLSMlists.font,
            },
            fontStyle = drop(L['Font style'], {
                {name = L['NONE'], value = ''}, --
                {name = L['OUTLINE'], value = 'OUTLINE'}, --
                {name = L['THINKOUTLINE'], value = 'THINKOUTLINE'}, --
            }),
            fontSize = fullRange(L['Font size'], 7, 40, 1),

            point = point(L['Point']),
            relativePoint = point(L['Relative point']),
            xOffset = fullRange(L['xOffset'], -200, 200, 1),
            yOffset = fullRange(L['yOffset'], -200, 200, 1),
        },
        style = {
            type = 'group',
            name = L['Color & Scale'],
            -- childGroups = 'tree',
            get = function(item)
                local db = getOptionTheme(item).styles[item[4]][item[#item]]
                if item.type == 'color' then
                    return db.r, db.g, db.b, db.a
                else
                    return db
                end
            end,
            set = function(item, ...)
                local db = getOptionTheme(item).styles[item[4]]
                if item.type == 'color' then
                    local color = db[item[#item]]
                    color.r, color.g, color.b, color.a = ...
                else
                    db[item[#item]] = ...
                end
                Option:ApplyThemes()
            end,
            args = {
                SOON = style(L['Soon']),
                SECOND = style(L['Second']),
                MINUTE = style(L['Minute']),
                HOUR = style(L['Hour']),
            },
        },
    },
}

local RuleOption = {
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
        enable = toggle(ENABLE),
        delete = {
            type = 'execute',
            name = DELETE,
            order = orderGen(),
            func = function(item)
                local k = select(2, getOptionRule(item))
                Option:RemoveRule(k)
            end,
            disabled = function(item)
                return getOptionRule(item).locked
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
        theme = { --
            type = 'select',
            name = L['Theme'],
            order = orderGen(),
            width = 'full',
            values = ThemesDropdown,
        },
        rule = { --
            type = 'input',
            name = L['Rule'],
            order = orderGen(),
            width = 'full',
            multiline = true,
            hidden = function(item)
                return getOptionRule(item).locked
            end,
        },
    },
}

function Option:Load()
    Options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(ns.Addon.db)

    local registry = LibStub('AceConfigRegistry-3.0')
    registry:RegisterOptionsTable('tdCC', Options)

    local dialog = LibStub('AceConfigDialog-3.0')
    dialog:AddToBlizOptions('tdCC', 'tdCC')
end

function Option:Update()
    wipe(Rules)
    wipe(Themes)
    wipe(ThemesDropdown)

    for k, v in pairs(RulesFixed) do
        Rules[k] = v
    end

    for k, v in pairs(ThemesFixed) do
        Themes[k] = v
    end

    for k, v in pairs(ns.Addon.db.profile.themes) do
        Themes[k] = ThemeOption
        ThemesDropdown[k] = v.name or k
    end

    for k, v in pairs(ns.Addon.db.profile.rules) do
        Rules[k] = RuleOption
    end

    AceConfigRegistry:NotifyChange('tdCC Options')
end

function Option:SetRulePriority(rule, value)
    if rule.priority == value then
        return
    end

    if rule.priority > value then
        rule.priority = value - 0.5
    else
        rule.priority = value + 0.5
    end

    self:UpdateRulesPriority()
    self:ApplyRules()
end

function Option:UpdateRulesPriority()
    local rules = tvalues(ns.Addon.db.profile.rules)

    sort(rules, function(a, b)
        return a.priority < b.priority
    end)

    for i, v in ipairs(rules) do
        v.priority = i
    end
end

function Option:AddRule(name)
    name = name:trim()

    local rules = ns.Addon.db.profile.rules
    local count = tcount(rules)

    rules[name] = {name = name, theme = 'Default', priority = count + 1}

    self:SetRulePriority(rules[name], count)
    self:Update()
end

function Option:RemoveRule(name)
    ns.Addon.db.profile.rules[name] = nil

    self:UpdateRulesPriority()
    self:Update()
    self:ApplyRules()
end

function Option:ApplyRules()
    ns.Addon:UpdateRules()
end

function Option:ApplyThemes()
    ns.Timer:RefreshAll()
end

function ns.Addon:LoadOptionFrame()
    Option:Load()
    Option:Update()
end
