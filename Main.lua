

local tdCC = LibStub('AceAddon-3.0'):NewAddon('tdCC', 'AceEvent-3.0', 'AceHook-3.0', 'LibClass-1.0')

local LibMedia = LibStub('LibSharedMedia-3.0')

function tdCC:OnInitialize()
    local defaults = {
        profile = {
            types = {
                Buff = {
                    enable = true,
                    hideBlizModel = true,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 0,
                    startRemain = 60,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 26,
                    fontOutline = 'OUTLINE',
                    anchor = 'TOPRIGHT',
                    xOffset = 0,
                    yOffset = 0,

                    styles = {
                        SOON   = {r = 1, g = 0.1, b = 0.1, scale = 1},
                        SECOND = {r = 1, g = 1,   b = 1,   scale = 1},
                        MINUTE = {r = 1, g = 1,   b = 1,   scale = 1},
                        HOUR   = {r = 1, g = 1,   b = 1,   scale = 1},
                    },

                    shine = false,
                },
                Action = {
                    enable = true,
                    hideBlizModel = false,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 2.2,
                    startRemain = 0,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 20,
                    fontOutline = 'OUTLINE',
                    anchor = 'CENTER',
                    xOffset = 0,
                    yOffset = 0,

                    styles = {
                        SOON   = {r = 1,   g = 0.1, b = 0.1, scale = 1.2},
                        SECOND = {r = 1,   g = 1,   b = 1,   scale = 1  },
                        MINUTE = {r = 0.8, g = 0.6, b = 0,   scale = 1  },
                        HOUR   = {r = 0.4, g = 0.4, b = 0.4, scale = 1},
                    },

                    shine = true,
                    shineMinDuration = 10,
                    shineType = 'ICON',
                    shineScale = 4,
                    shineDuration =  1,
                },
                Totem = {
                    enable = false,
                    hideBlizModel = false,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 0,
                    startRemain = 0,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 26,
                    fontOutline = 'OUTLINE',
                    anchor = 'CENTER',
                    xOffset = 0,
                    yOffset = 0,

                    styles = {
                        SOON   = {r = 1, g = 1, b = 1, scale = 1},
                        SECOND = {r = 1, g = 1, b = 1, scale = 1},
                        MINUTE = {r = 1, g = 1, b = 1, scale = 1},
                        HOUR   = {r = 1, g = 1, b = 1, scale = 1},
                    },

                    shine = false,
                },
                Rune = {
                    enable = true,
                    hideBlizModel = false,
                    mmss = false,
                    hideHaveCharges = false,
                    minRatio = 0,
                    minDuration = 0,
                    startRemain = 0,

                    fontFace = LibMedia:GetDefault('font'),
                    fontSize = 36,
                    fontOutline = 'OUTLINE',
                    anchor = 'BOTTOM',
                    xOffset = 2,
                    yOffset = 0,

                    styles = {
                        SOON   = {r = 1, g = 1, b = 1, scale = 1},
                        SECOND = {r = 1, g = 1, b = 1, scale = 1},
                        MINUTE = {r = 1, g = 1, b = 1, scale = 1},
                        HOUR   = {r = 1, g = 1, b = 1, scale = 1},
                    },

                    shine = false,
                }
            }
        },
    }

    self.db = LibStub('AceDB-3.0'):New('TDDB_COOLDOWN', defaults, true)

    if self.LoadOptionFrame then
        self:LoadOptionFrame()
    end
end

function tdCC:GetFont(name)
    return LibMedia:Fetch('font', name)
end

function tdCC:OnEnable()
    self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
    self:SecureHook(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', 'SetCooldown')
    self:SecureHook('SetActionUIButton', 'SetActionUIButton')

    for i, button in ipairs(ActionBarButtonEventsFrame.frames) do
        self:SetActionUIButton(button, button.action, button.cooldown)
    end
end

function tdCC:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

local actions = {}
local function cooldownOnShow(cooldown)
    actions[cooldown] = true
end

local function cooldownOnHide(cooldown)
    actions[cooldown] = nil
end

function tdCC:SetActionUIButton(button, action, cooldown)
    if not cooldown.tdaction then
        cooldown:HookScript('OnShow', cooldownOnShow)
        cooldown:HookScript('OnHide', cooldownOnHide)
    end
    cooldown.tdaction = action
end

function tdCC:SetCooldown(cooldown, start, duration, charges, maxCharges)
    if self:ShouldShow(cooldown, start, duration, charges, maxCharges) then
        self.Timer:StartTimer(cooldown, start, duration)
    else
        self.Timer:StopTimer(cooldown)
    end
end

function tdCC:ShouldShow(cooldown, start, duration, charges, maxCharges)
    if cooldown.noCooldownCount then
        return
    end
    if not start or start == 0 then
        return
    end
    if not duration or duration == 0 then
        return
    end
    local set = self:GetCooldownSetting(cooldown)
    if not set or not set.enable then
        return
    end
    if duration < set.minDuration then
        return
    end
    if set.hideHaveCharges and charges and charges > 0 then
        return
    end
    return true
end

function tdCC:ACTIONBAR_UPDATE_COOLDOWN()
    for cooldown in pairs(actions) do
        local start, duration, enable = GetActionCooldown(cooldown.tdaction)
        local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(cooldown.tdaction)
        if enable then
            self:SetCooldown(cooldown, start, duration, charges, maxCharges)
        end
    end
end

function tdCC:GetCooldownSetting(cooldown)
    local type = self:GetCooldownType(cooldown)
    return type and self.db.profile.types[type]
end

local function GetCooldownType(cooldown)
    local name = cooldown:GetName()
    if name then
        if name:find('^TotemFrameTotem') then
            return 'Totem'
        elseif name:find('^RuneButtonIndividual') then
            return 'Rune'
        end
    end
    return cooldown:GetReverse() and 'Buff' or 'Action'
end

local TypeCache = setmetatable({}, {__index = function(o, cooldown)
    o[cooldown] = GetCooldownType(cooldown)
    return o[cooldown]
end})

function tdCC:GetCooldownType(cooldown)
    return TypeCache[cooldown]
end
