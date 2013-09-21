
local tdCC = LibStub('AceAddon-3.0'):GetAddon('tdCC')

local Setting = tdCC:GetClass('Setting')
local Timer = tdCC:NewClass('Timer', 'Frame')
LibStub('AceTimer-3.0'):Embed(Timer)

tdCC.Timer = Timer

local timers = {}

local function cooldownOnHide(cooldown)
	Timer:StopTimer(cooldown)
end

local function cooldownOnSizeChanged(cooldown, width, height)
	local timer = Timer:GetTimer(cooldown)
    if timer.width ~= width then
        timer:UpdateSize(width, height)
        if timer.start then
            timer:Start(timer.start, timer.duration)
        end
    end
end

function Timer:Constructor(cooldown)
	self:SetParent(cooldown:GetParent())
	self:SetFrameLevel(cooldown:GetFrameLevel() + 5)
	self:SetPoint('CENTER')

	self.text = self:CreateFontString(nil, 'OVERLAY')
	self.cooldown = cooldown
	self.set = Setting:New(self)

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

---- method

function Timer:Start(start, duration)
	self.set:Refresh()

	if not self.ratio or self.ratio == 0 then

	elseif self.ratio < self.set:GetMinRatio() then
		return
	else
		self:UpdateBlizModel()
		self:UpdatePosition()
		self:SetNextUpdate(start - GetTime())
	end

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

function Timer:Update()
	local now = GetTime()
	if self.start > now then
		self:SetNextUpdate(self.start - now)
		return
	end

	local remain, startRemain = self:GetRemain(), self.set:GetStartRemain()
	if startRemain > 0 and startRemain < remain then
		self.text:Hide()
		self:SetNextUpdate(remain - startRemain)
		return
	end

	if remain < 0.2 then
		self:Stop()
		return
	end

	self:UpdateStyle()
	self:UpdateText()
	self:SetNextUpdate(self.set:GetNextUpdate())
end

local function round(x)
	return floor(x + 0.5)
end

function Timer:UpdateSize(width, height)
	self.width = width
	self.ratio = round(width) / 36
	self:SetSize(width, height)
end

function Timer:UpdateBlizModel()
	self.cooldown:SetAlpha(self.set:IsHideBlizModel() and 0 or 1)
end

function Timer:UpdatePosition()
	self.text:SetPoint('CENTER', self, self.set:GetPositionArgs())
end

function Timer:UpdateStyle()
	if self.set:IsStyleChanged() or not self.fontReady then
		self.fontReady = self.text:SetFont(self.set:GetFontArgs())
	end
end

function Timer:UpdateText()
	if not self.fontReady then
		return
	end

	self.text:Show()
	self.text:SetText(self.set:GetTimeText())
	self.text:SetTextColor(self.set:GetTimeColor())
end
