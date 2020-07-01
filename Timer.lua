-- Timer.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 12:37:45 PM

---@type ns
local ns = select(2, ...)

local Addon = ns.Addon

---@type tdCCTimer
local Timer = Addon:NewClass('Timer', 'Frame')
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

Timer.cooldownTimers = {}
Timer.pool = {}

local function cooldownOnHide(cooldown)
    return Timer:StopTimer(cooldown)
end

local function cooldownOnSizeChanged(cooldown)
    return Timer:GetTimer(cooldown):RefreshConfig()
end

function Timer:Constructor()
    self.text = self:CreateFontString(nil, 'OVERLAY')
    self.text:SetFont(STANDARD_TEXT_FONT, 14)
    -- cooldown:HookScript('OnSizeChanged', cooldownOnSizeChanged)
    -- cooldown:HookScript('OnHide', cooldownOnHide)

    self:SetScript('OnSizeChanged', self.UpdateSize)
end

---- static

function Timer:Acquire()
    local timer = next(self.pool)
    if not timer then
        timer = self:New()
    else
        self.pool[timer] = nil
    end
    return timer
end

function Timer:StartTimer(cooldown, start, duration)
    local timer = self:GetTimer(cooldown)
    if not timer then
        timer = self:Acquire()
        timer:SetupCooldown(cooldown)
    end
    timer:Start(start, duration)
end

function Timer:StopTimer(cooldown)
    local timer = self:GetTimer(cooldown)
    if timer then
        timer:Stop()
    end
end

function Timer:GetTimer(cooldown)
    return self.cooldownTimers[cooldown]
end

function Timer:RefreshAll()
    for cooldown, timer in pairs(self.cooldownTimers) do
        timer:RefreshConfig()
    end
end

---- method

function Timer:SetupCooldown(cooldown)
    self:ClearAllPoints()
    self:SetParent(cooldown:GetParent())
    self:SetAllPoints(cooldown)
    self:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    self:UpdateSize(cooldown:GetSize())

    self.cooldown = cooldown
    self.cooldownTimers[cooldown] = self
end

function Timer:RefreshConfig()
    if self.start then
        Addon:SetCooldown(self.cooldown, self.start, self.duration)
    end
end

function Timer:Start(start, duration)
    self.profile = Addon:GetCooldownProfile(self.cooldown)

    if not self.ratio or self.ratio == 0 then
        print('no ratio')
    elseif self.ratio < self.profile.minRatio then
        return
    else
        self.cooldown:SetAlpha(self.profile.hideBlizModel and 0 or 1)

        self.text:ClearAllPoints()
        self.text:SetPoint(self.profile.point, self, self.profile.relativePoint, self.profile.xOffset,
                           self.profile.yOffset)

        -- self:SetNextUpdate(start - GetTime())
    end

    print(self, self.cooldown, start, duration)

    self.style = nil
    self.styleProfile = nil
    self.fontReady = nil
    self.start = start
    self.duration = duration

    self:Show()
    self:Update()
end

function Timer:Stop()
    self:CancelAllTimers()

    if self.fontReady then
        self.text:SetText('')
    end
    self.cooldown:SetAlpha(1)

    print(self, self.cooldown, 'stop')

    self.cooldownTimers[self.cooldown] = nil
    self.pool[self] = true

    self.start = nil
    self.duration = nil
    self.fontReady = nil
    self.cooldown = nil

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
        self:Shine()
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
end

function Timer:Shine()
    if not self.profile.shine then
        return
    end
    if self.duration <= self.profile.shineMinDuration then
        return
    end

    ns.Shine:StartShine(self.cooldown, self.profile.shineStyle)
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

function Addon:RefreshAllTimers()
    return Timer:RefreshAll()
end
