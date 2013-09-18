
local tdCC = LibStub('AceAddon-3.0'):GetAddon('tdCC')
local Shine = tdCC:NewClass('Shine', 'Frame')

local function animOnFinished(self)
    local parent = self:GetParent()
    if parent:IsShown() then
        parent:Hide()
    end
end

local function scaleOnFinished(self)
    self:GetParent():Finish()
end

function Shine:Constructor(cooldown)
	self:SetParent(cooldown:GetParent())
	self:SetPoint('CENTER')
	self:SetScript('OnHide', self.OnHide)

    local anim = self:CreateAnimationGroup()
    anim:SetLooping('BOUNCE')
    anim:SetScript('OnFinished', animOnFinished)
    
    local grow = self:CreateAnimation('Scale')
    grow:SetOrigin('CENTER', 0, 0)
    grow:SetOrder(0)
    grow:SetScript('OnFinished', scaleOnFinished)
    
    local icon = self:CreateTexture(nil, 'OVERLAY')
    icon:SetBlendMode('ADD')
    icon:SetAllPoints(self)
    
    self.grow = grow
    self.anim = anim
    self.icon = icon
    self.cooldown = cooldown
end

function Shine:OnHide()
    if self.anim:IsPlaying() then
        self.anim:Stop()
    end
    self:Hide()
end
