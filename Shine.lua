-- Shine.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/1/2020, 1:47:45 PM
---@type ns
local ns = select(2, ...)

local DURATION = 0.8

local Shine = ns.Addon:NewClass('Shine', 'Frame')
ns.Shine = Shine

Shine.shines = {}
Shine.pool = {}

local function animOnFinished(self)
    local parent = self:GetParent()
    if parent:IsShown() then
        parent:Stop()
    end
end

function Shine:Constructor()
    local icon = self:CreateTexture(nil, 'OVERLAY')
    icon:SetBlendMode('ADD')
    icon:SetAllPoints(self)

    local anim = self:CreateAnimationGroup()
    anim:SetLooping('NONE')
    anim:SetScript('OnFinished', animOnFinished)

    local scale = anim:CreateAnimation('Scale')
    scale:SetOrigin('CENTER', 0, 0)
    scale:SetDuration(DURATION)
    scale:SetToScale(1, 1)
    scale:SetOrder(1)
    scale:SetTarget(icon)

    local rotation = anim:CreateAnimation('Rotation')
    rotation:SetDegrees(360)
    rotation:SetDuration(DURATION * 3 / 5)
    rotation:SetStartDelay(DURATION * 2 / 5)
    rotation:SetOrder(1)
    rotation:SetTarget(icon)

    self.anim = anim
    self.icon = icon
    self.scale = scale
    self.rotation = rotation

    self:SetScript('OnHide', self.OnHide)
end

---- static

function Shine:GetShine(cooldown)
    return self.shines[cooldown]
end

function Shine:Acquire()
    local shine = next(self.pool)
    if not shine then
        shine = self:New()
    else
        self.pool[shine] = nil
    end
    return shine
end

function Shine:StartShine(cooldown, profile)
    local shine = self:GetShine(cooldown)
    if not shine then
        shine = Shine:Acquire()
        shine:SetupCooldown(cooldown)
    end
    shine.profile = profile
    shine:Start()
end

---- method

function Shine:SetupCooldown(cooldown)
    self:SetParent(cooldown:GetParent())
    self:SetFrameStrata('HIGH')
    self:SetFrameLevel(cooldown:GetParent():GetFrameLevel() + 5)
    self:SetPoint('CENTER', cooldown, 'CENTER')

    self.cooldown = cooldown
    self.shines[cooldown] = self
end

function Shine:OnHide()
    if self.anim:IsPlaying() then
        self.anim:Stop()
    end
    self:Stop()
end

function Shine:Start()
    if self.anim:IsPlaying() then
        self.anim:Stop()
    end

    local icon, scale = ns.GetIcon(self.cooldown, self.profile.shineStyle)

    self.icon:SetTexture(icon)
    self.scale:SetFromScale(scale, scale)
    self:SetSize(self.cooldown:GetSize())
    self:Show()
    self.anim:Play()
end

function Shine:Stop()
    if not self.cooldown then
        return
    end

    self.shines[self.cooldown] = nil
    self.pool[self] = true

    self.cooldown = nil
    self:Hide()
end
