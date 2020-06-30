-- Timer.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 12:37:45 PM

---@type ns
local ns = select(2, ...)

---@type Timer
local Timer = ns.Addon:NewClass('Timer', 'Frame')
LibStub('AceTimer-3.0'):Embed(Timer)

ns.Timer = Timer

local SOON, SECOND, SHORT, MINUTE, HOUR, DAY = 10, 60, 600, 3600, 86400

local STYLE_DB_KEYS = {
    SOON = 'SOON',
    SECOND = 'SECOND',
    SHORT = 'MINUTE',
    MINUTE = 'MINUTE',
    HOUR = 'HOUR',
    DAY = 'HOUR',
}

local TextHelper = {}
local NextHelper = {}

local timers = {}

local function cooldownOnHide(cooldown)
    return Timer:StopTimer(cooldown)
end

local function cooldownOnSizeChanged(cooldown)
    return Timer:GetTimer(cooldown):RefreshConfig()
end

function Timer:Constructor(cooldown)
    self:SetParent(cooldown:GetParent())
    self:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    self:SetPoint('CENTER')

    self.text = self:CreateFontString(nil, 'OVERLAY')
    self.text:SetFont(STANDARD_TEXT_FONT, 14)

    self.cooldown = cooldown

    self:UpdateSize(cooldown:GetSize())

    timers[cooldown] = self

    cooldown:HookScript('OnSizeChanged', cooldownOnSizeChanged)
    cooldown:HookScript('OnHide', cooldownOnHide)
end

function Timer:StartTimer(cooldown, start, duration)
    local timer = self:GetTimer(cooldown) or self:New(cooldown)
    timer:Start(start, duration)
end

function Timer:StopTimer(cooldown)
    local timer = self:GetTimer(cooldown)
    if timer then
        timer:Stop()
    end
end

function Timer:GetTimer(cooldown)
    return timers[cooldown]
end

function Timer:RefreshAll()
    for cooldown, timer in pairs(timers) do
        timer:RefreshConfig()
    end
end

function Timer:RefreshConfig()
    self:UpdateSize(self.cooldown:GetSize())

    if self.start then
        self:Start(self.start, self.duration)
    end
end

---- method

function Timer:Start(start, duration)
    self.profile = ns.Addon:GetCooldownProfile(self.cooldown)

    if not self.ratio or self.ratio == 0 then

    elseif self.ratio < self.profile.minRatio then
        return
    else
        self.cooldown:SetAlpha(self.profile.hideBlizModel and 0 or 1)

        self.text:ClearAllPoints()
        self.text:SetPoint(self.profile.point, self, self.profile.relativePoint, self.profile.xOffset,
                           self.profile.yOffset)

        self:SetNextUpdate(start - GetTime())
    end

    self.style = nil
    self.styleProfile = nil
    self.fontReady = nil
    self.start = start
    self.duration = duration

    self:Show()
end

function Timer:Stop()
    self:CancelAllTimers()

    if self.fontReady then
        self.text:SetText('')
    end

    self.start = nil
    self.duration = nil
    self.fontReady = nil

    self.cooldown:SetAlpha(1)

    self:Hide()
end

function Timer:GetRemain()
    if not self.start then
        return 0
    end
    return self.start + self.duration - GetTime()
end

function Timer:SetNextUpdate(nextUpdate)
    self:CancelAllTimers()
    self:ScheduleTimer('Update', nextUpdate)
end

function Timer:GetStyle()
    local remain = self.remain
    if remain < SOON then
        return 'SOON'
    elseif remain < SECOND then
        return 'SECOND'
    elseif remain < self.profile.shortLimit then
        return 'SHORT'
    elseif remain < MINUTE then
        return 'MINUTE'
    elseif remain < HOUR then
        return 'HOUR'
    else
        return 'DAY'
    end
end

function Timer:UpdateStyle()
    local style = self:GetStyle()
    if style ~= self.style then
        self.style = style
        self.styleProfile = self.profile.styles[STYLE_DB_KEYS[style]]
        return true
    end
end

function Timer:Update()
    local now = GetTime()
    local remain = self.start + self.duration - now
    local startRemain = self.profile.startRemain

    self.remain = remain

    if self.start > now then
        self:SetNextUpdate(self.start - now)
        return
    end

    if startRemain > 0 and startRemain < remain then
        self.text:Hide()
        self:SetNextUpdate(remain - startRemain)
        return
    end

    if remain < 0.2 then
        -- self:Shine()
        self:Stop()
        return
    end

    if self:UpdateStyle() or not self.fontReady then
        local fontFace = ns.GetFont(self.profile.fontFace)
        local fontStyle = self.profile.fontStyle
        local fontSize = self.profile.fontSize * self.ratio * self.styleProfile.scale

        self.fontReady = self.text:SetFont(fontFace, fontSize, fontStyle)

        if not self.fontReady then
            self.fontReady = self.text:SetFont(STANDARD_TEXT_FONT, fontSize, fontStyle)
        end
    end

    if self.fontReady then
        local color = self.styleProfile.color
        self.text:SetTextColor(color.r, color.g, color.b, color.a)
        self.text:SetText(TextHelper[self.style](remain))
        self.text:Show()

        self:SetNextUpdate(NextHelper[self.style](remain))
    else
        self:SetNextUpdate(0.1)
    end
end

function Timer:UpdateSize(width, height)
    self.width = width
    self.ratio = floor(width + 0.5) / 36
    self:SetSize(width, height)
end

function Timer:Shine()
    if not self.set:IsShineEnabled() then
        return
    end
    if self.set:GetShineMinDuration() >= self.duration then
        return
    end
    ns.Addon.Shine:StartShine(self.cooldown, self.set)
end

---- TextHelper

function TextHelper.SOON(remain)
    return ('%d'):format(ceil(remain))
end
TextHelper.SECOND = TextHelper.SOON

function TextHelper.SHORT(remain)
    remain = ceil(remain)
    return ('%d:%02d'):format(floor(remain / SECOND), ceil(remain % SECOND))
end

function TextHelper.MINUTE(remain)
    return ('%dm'):format(ceil(remain / SECOND))
end

function TextHelper.HOUR(remain)
    return ('%dh'):format(ceil(remain / MINUTE))
end

function TextHelper.DAY(remain)
    return ('%dd'):format(ceil(remain / HOUR))
end

---- NextHelper

function NextHelper.SOON(remain)
    return remain - floor(remain)
end
NextHelper.SECOND = NextHelper.SOON
NextHelper.SHORT = NextHelper.SOON

function NextHelper.MINUTE(remain)
    return remain % SECOND
end

function NextHelper.HOUR(remain)
    return remain % MINUTE
end

function NextHelper.DAY(remain)
    return remain % HOUR
end
