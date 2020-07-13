-- Timer.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 12:37:45 PM
---@type ns
local ns = select(2, ...)

local next, pairs = next, pairs
local format = string.format
local floor, ceil = math.floor, math.ceil

local GetTime = GetTime

local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local Addon = ns.Addon

local SOON, SECOND, MINUTE, HOUR, DAY = 10, 60, 3600, 86400

local TextHelper = {}
local NextHelper = {}

---@type tdCCTimer
local Timer = Addon:NewClass('Timer', 'Frame')
LibStub('AceTimer-3.0'):Embed(Timer)

ns.Timer = Timer

Timer.cooldownTimers = {}
Timer.pool = {}

function Timer:Constructor()
    self.text = self:CreateFontString(nil, 'OVERLAY')
    self.text:SetFont(STANDARD_TEXT_FONT, 14)
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

function Timer:IterateTimers()
    return pairs(self.cooldownTimers)
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

function Timer:Start(start, duration)
    self.profile = Addon:GetCooldownProfile(self.cooldown)

    if not self.ratio or self.ratio == 0 then

    elseif self.ratio < self.profile.minRatio then
        return
    else
        self.cooldown:SetAlpha(self.profile.hideBlizModel and 0 or 1)

        self.text:ClearAllPoints()
        self.text:SetPoint(self.profile.point, self, self.profile.relativePoint, self.profile.xOffset,
                           self.profile.yOffset)

        -- self:SetNextUpdate(start - GetTime())
    end

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

function Timer:CheckStyle(remain)
    if remain < self.profile.expireThreshold then
        return remain < SOON and 'SOON' or 'SECOND', 'EXPIRE'
    elseif remain < SOON then
        return 'SOON', 'SOON'
    elseif remain < SECOND then
        return 'SECOND', 'SECOND'
    elseif remain < self.profile.shortThreshold then
        return 'MINUTE', 'SHORT'
    elseif remain < MINUTE then
        return 'MINUTE', 'MINUTE'
    elseif remain < HOUR then
        return 'HOUR', 'HOUR'
    else
        return 'HOUR', 'DAY'
    end
end

function Timer:Update()
    if not self.ratio then
        return self:SetNextUpdate(0)
    end

    local now = GetTime()
    local remain = self.start + self.duration - now
    local startRemain = self.profile.startRemain

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

    local style, style2 = self:CheckStyle(remain)
    local styleChanged = style ~= self.style

    if styleChanged then
        self.style = style
        self.styleProfile = self.profile.styles[style]
    end

    if styleChanged or not self.fontReady then
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
        self.text:SetText(TextHelper[style2](remain))
        self.text:Show()

        self:SetNextUpdate(NextHelper[style2](remain))
    else
        self:SetNextUpdate(0)
    end
end

function Timer:UpdateSize(width, height)
    if width > 0 then
        local ratio = floor(width + 0.5) / 36
        if not self.ratio or self.ratio ~= ratio then
            self.ratio = ratio
            self.fontReady = nil
        end
    end
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

function TextHelper.EXPIRE(remain)
    return format('%0.1f', remain)
end

function TextHelper.SECOND(remain)
    return format('%d', ceil(remain))
end

function TextHelper.SHORT(remain)
    remain = ceil(remain)
    return format('%d:%02d', floor(remain / SECOND), ceil(remain % SECOND))
end

function TextHelper.MINUTE(remain)
    return format('%dm', ceil(remain / SECOND))
end

function TextHelper.HOUR(remain)
    return format('%dh', ceil(remain / MINUTE))
end

function TextHelper.DAY(remain)
    return format('%dd', ceil(remain / HOUR))
end

TextHelper.SOON = TextHelper.SECOND

---- NextHelper

function NextHelper.EXPIRE(remain)
    return NextHelper.SECOND(remain * 10) / 10
end

function NextHelper.SECOND(remain)
    return remain - floor(remain)
end

function NextHelper.MINUTE(remain)
    return remain % SECOND
end

function NextHelper.HOUR(remain)
    return remain % MINUTE
end

function NextHelper.DAY(remain)
    return remain % HOUR
end

NextHelper.SOON = NextHelper.SECOND
NextHelper.SHORT = NextHelper.SECOND
