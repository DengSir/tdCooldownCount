
local tdCC = LibStub('AceAddon-3.0'):GetAddon('tdCC')
local L = LibStub('AceLocale-3.0'):GetLocale('tdCC', true)

function tdCC:LoadOptionFrame()
    local order = 0
    local function makeorder()
        order = order + 1
        return order
    end

    local function getTypeValue(type, key)
        return self.db.profile.types[type][key]
    end

    local function setTypeValue(type, key, value)
        self.db.profile.types[type][key] = value
        self.Timer:RefreshAll()
    end

    local function getTypeStyleColor(type, style)
        local color = self.db.profile.types[type].styles[style]
        return color.r, color.g, color.b
    end

    local function setTypeStyleColor(type, style, r, g, b)
        local color = self.db.profile.types[type].styles[style]
        color.r, color.g, color.b = r, g, b
        self.Timer:RefreshAll()
    end

    local function getTypeStyleScale(type, style)
        return self.db.profile.types[type].styles[style].scale
    end

    local function setTypeStyleScale(type, style, value)
        self.db.profile.types[type].styles[style].scale = value
        self.Timer:RefreshAll()
    end

    local function createTypeGroup(name, type, isBuff)
        local info = {
            type = 'group',
            name = name,
            order = makeorder(),
            childGroups = 'tab',
            args = {
                enable = {
                    type = 'toggle',
                    name = ENABLE,
                    order = makeorder(),
                    get = function()
                        return getTypeValue(type, 'enable')
                    end,
                    set = function(_, value)
                        setTypeValue(type, 'enable', value)
                    end
                },
                general = {
                    type = 'group',
                    name = GENERAL,
                    order = makeorder(),
                    get = function(item)
                        return getTypeValue(type, item[#item])
                    end,
                    set = function(item, value)
                        setTypeValue(type, item[#item], value)
                    end,
                    disabled = function()
                        return not getTypeValue(type, 'enable')
                    end,
                    args = {
                        hideBlizModel = {
                            type = 'toggle',
                            name = L['Hide blizz cooldown model'],
                            order = makeorder(),
                            width = 'full',
                        },
                        mmss = {
                            type = 'toggle',
                            name = L['Minimum duration to display text as MM:SS'],
                            order = makeorder(),
                            width = 'full',
                        },
                        hideHaveCharges = {
                            type = 'toggle',
                            name = L['Hide timer when has charges'],
                            order = makeorder(),
                            width = 'full',
                            hidden = isBuff,
                        },
                        startRemain = {
                            type = 'range',
                            name = L['Remaining how long after the start timer'],
                            order = makeorder(),
                            width = 'full',
                            min = 0,
                            max = 600,
                            step = 1,
                        },
                        minDuration = {
                            type = 'range',
                            name = L['Minimum duration to display text'],
                            order = makeorder(),
                            width = 'full',
                            min = 0,
                            max = 10,
                            step = 0.1,
                        },
                        minRatio = {
                            type = 'range',
                            name = L['Minimum size to display text'],
                            order = makeorder(),
                            width = 'full',
                            min = 0,
                            max = 1.5,
                            step = 0.05,
                            isPercent = true,
                        },
                    }
                },
                style = {
                    type = 'group',
                    name = L['Style'],
                    order = makeorder(),
                    disabled = function()
                        return not getTypeValue(type, 'enable')
                    end,
                    get = function(item)
                        local name = item[#item]
                        local style = name:match('^_(.+)$')
                        if style then
                            return getTypeStyleScale(type, style)
                        else
                            return getTypeStyleColor(type, name)
                        end
                    end,
                    set = function(item, ...)
                        local name = item[#item]
                        local style = name:match('^_(.+)$')
                        if style then
                            setTypeStyleScale(type, style, ...)
                        else
                            setTypeStyleColor(type, name, ...)
                        end
                    end,
                    args = {
                        _SOON = {
                            type = 'range',
                            name = L['Soon'],
                            order = makeorder(),
                            width = 'double',
                            min = 0.5,
                            max = 2,
                            step = 0.1,
                        },
                        SOON = {
                            type = 'color',
                            name = L['Soon'],
                            order = makeorder(),
                            width = 'fill',
                        },
                        _SECOND = {
                            type = 'range',
                            name = L['Second'],
                            order = makeorder(),
                            width = 'double',
                            min = 0.5,
                            max = 2,
                            step = 0.1,
                        },
                        SECOND = {
                            type = 'color',
                            name = L['Second'],
                            order = makeorder(),
                        },
                        _MINUTE = {
                            type = 'range',
                            name = L['Minute'],
                            order = makeorder(),
                            width = 'double',
                            min = 0.5,
                            max = 2,
                            step = 0.1,
                        },
                        MINUTE = {
                            type = 'color',
                            name = L['Minute'],
                            order = makeorder(),
                        },
                        _HOUR = {
                            type = 'range',
                            name = L['Hour'],
                            order = makeorder(),
                            width = 'double',
                            min = 0.5,
                            max = 2,
                            step = 0.1,
                        },
                        HOUR = {
                            type = 'color',
                            name = L['Hour'],
                            order = makeorder(),
                        },
                    }
                },
                font = {
                    type = 'group',
                    name = L['Font & Position'],
                    order = makeorder(),
                    get = function(item)
                        return getTypeValue(type, item[#item])
                    end,
                    set = function(item, value)
                        setTypeValue(type, item[#item], value)
                    end,
                    disabled = function()
                        return not getTypeValue(type, 'enable')
                    end,
                    args = {
                        fontFace = {
                            type = 'select',
                            name = L['Font face'],
                            order = makeorder(),
                            dialogControl = 'LSM30_Font',
                            values = AceGUIWidgetLSMlists.font,
                        },
                        fontSize = {
                            type = 'range',
                            name = L['Font size'],
                            order = makeorder(),
                            width = 'full',
                            min = 7,
                            max = 40,
                            step = 1,
                        },
                        anchor = {
                            type = 'select',
                            name = L['Anchor'],
                            order = makeorder(),
                            values = {
                                ['TOPLEFT']       = L['Top Left'],
                                ['TOP']           = L['Top'],
                                ['TOPRIGHT']      = L['Top Right'],
                                ['LEFT']          = L['Left'],
                                ['CENTER']        = L['Center'],
                                ['RIGHT']         = L['Right'],
                                ['BOTTOMLEFT']    = L['Bottom Left'],
                                ['BOTTOM']        = L['Bottom'],
                                ['BOTTOMRIGHT']   = L['Bottom Right'],
                            },
                        },
                        xOffset = {
                            type = 'range',
                            name = L['X offset'],
                            order = makeorder(),
                            width = 'full',
                            min = -40,
                            max = 40,
                            step = 1,
                        },
                        yOffset = {
                            type = 'range',
                            name = L['X offset'],
                            order = makeorder(),
                            width = 'full',
                            min = -40,
                            max = 40,
                            step = 1,
                        },
                    }
                },
            }
        }

        if not isBuff then
            info.args.shine = {
                type = 'group',
                name = L['Shine'],
                order = makeorder(),
                get = function(item)
                    return getTypeValue(type, item[#item])
                end,
                set = function(item, value)
                    setTypeValue(type, item[#item], value)
                end,
                disabled = function()
                    return not getTypeValue(type, 'enable')
                end,
                args = {
                    shine = {
                        type = 'toggle',
                        name = ENABLE,
                        order = makeorder(),
                        width = 'full',
                    },
                    shineType = {
                        type = 'select',
                        name = L['Shine class'],
                        order = makeorder(),
                        values = {
                            ICON = L['Icon'],
                            BLIZZARD = L['Blizzard'],
                            ROUND = L['Round'],
                            EXPLOSIVE = L['Explosive'],
                        }
                    },
                    shineMinDuration = {
                        type = 'range',
                        name = L['Minimum duration to display shine'],
                        order = makeorder(),
                        width = 'full',
                        min = 0,
                        max = 60,
                        step = 1,
                    },
                    shineScale = {
                        type = 'range',
                        name = L['Shine scale'],
                        order = makeorder(),
                        width = 'full',
                        min = 2,
                        max = 10,
                        step = 0.2,
                    },
                    shineDuration =  {
                        type = 'range',
                        name = L['Shine duration'],
                        order = makeorder(),
                        width = 'full',
                        min = 0.5,
                        max = 5,
                        step = 0.1,
                    },
                }
            }
        end

        return info
    end

    local charProfileKey = format('%s - %s', UnitName('player'), GetRealmName())

    local options = {
        type = 'group',
        name = L['tdCC Options'],
        childGroups = 'tab',
        args = {
            profile = {
                type = 'toggle',
                name = L['Character Specific Settings'],
                order = makeorder(),
                set = function(_, checked)
                    self.db:SetProfile(checked and charProfileKey or 'Default')
                end,
                get = function()
                    return self.db:GetCurrentProfile() == charProfileKey
                end,
                width = 'double',
            },
            reset = {
                type = 'execute',
                name = L['Restore default Settings'],
                order = makeorder(),
                confirm = true,
                confirmText = L['Are you sure you want to restore the current Settings?'],
                func = function()
                    self.db:ResetProfile()
                end
            },
            header1 = {
                type = 'header',
                name = '',
                order = makeorder(),
            },
            action = createTypeGroup(L['Action'], 'Action'),
            buff = createTypeGroup(L['Buff'], 'Buff', true),
            totem = createTypeGroup(L['Totem'], 'Totem', true),
            rune = createTypeGroup(L['Rune'], 'Rune', true)
        }
    }

    local registry = LibStub('AceConfigRegistry-3.0')
    registry:RegisterOptionsTable('tdCC Options', options)

    local dialog = LibStub('AceConfigDialog-3.0')
    dialog:AddToBlizOptions('tdCC Options', 'tdCC')
end
