
local tdCC = LibStub('AceAddon-3.0'):GetAddon('tdCC')
local L = LibStub('AceLocale-3.0'):GetLocale('tdCC', true)

function tdCC:LoadOptionFrame()
    local order = 0
    local function makeorder()
        order = order + 1
        return order
    end
    
    local function createClassGroup(name, class, isBuff)
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
                        return self.db.profile.types[class].enable
                    end,
                    set = function(_, value)
                        self.db.profile.types[class].enable = value
                    end
                },
                general = {
                    type = 'group',
                    name = GENERAL,
                    order = makeorder(),
                    get = function(item)
                        return self.db.profile.types[class][item[#item]]
                    end,
                    set = function(item, value)
                        self.db.profile.types[class][item[#item]] = value
                    end,
                    disabled = function()
                        return not self.db.profile.types[class].enable
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
                        return not self.db.profile.types[class].enable
                    end,
                    get = function(item)
                        local name = item[#item]
                        local style = name:match('^_(.+)$')
                        if style then
                            return self.db.profile.types[class].styles[style].scale
                        else
                            local tbl = self.db.profile.types[class].styles[name]
                            return tbl.r, tbl.g, tbl.b
                        end
                    end,
                    set = function(item, ...)
                        local name = item[#item]
                        local style = name:match('^_(.+)$')
                        if style then
                            self.db.profile.types[class].styles[style].scale = ...
                        else
                            local tbl = self.db.profile.types[class].styles[name]
                            tbl.r, tbl.g, tbl.b = ...
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
                    disabled = function()
                        return not self.db.profile.types[class].enable
                    end,
                    get = function(item)
                        return self.db.profile.types[class][item[#item]]
                    end,
                    set = function(item, value)
                        self.db.profile.types[class][item[#item]] = value
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
                    return self.db.profile.types[class][item[#item]]
                end,
                set = function(item, value)
                    self.db.profile.types[class][item[#item]] = value
                end,
                disabled = function()
                    return not self.db.profile.types[class].enable
                end,
                args = {
                    shine = {
                        type = 'toggle',
                        name = ENABLE,
                        order = makeorder(),
                        width = 'full',
                    },
                    shineClass = {
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
                    shineAlpha = {
                        type = 'range',
                        name = L['Shine duration'],
                        order = makeorder(),
                        width = 'full',
                        min = 0.2,
                        max = 1,
                        step = 0.1,
                    },
                }
            }
        end

        return info
    end

    local options = {
        type = 'group',
        name = L['tdCC Options'],
        childGroups = 'tab',
        args = {
            action = createClassGroup(L['Action'], 'Action'),
            buff = createClassGroup(L['Buff'], 'Buff', true),
            totem = createClassGroup(L['Totem'], 'Totem', true),
            rune = createClassGroup(L['Rune'], 'Rune', true)
        }
    }

    local profiles = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    
    local registry = LibStub('AceConfigRegistry-3.0')
    registry:RegisterOptionsTable('tdCC Options', options)
    registry:RegisterOptionsTable('tdCC Profiles', profiles)
    
    local dialog = LibStub('AceConfigDialog-3.0')
    dialog:AddToBlizOptions('tdCC Options', 'tdCC')
    dialog:AddToBlizOptions('tdCC Profiles', L['Profiles'], 'tdCC')
end
