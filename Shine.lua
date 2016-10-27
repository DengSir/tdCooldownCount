
local tdCC = LibStub('AceAddon-3.0'):GetAddon('tdCC')
local Shine = tdCC:NewClass('Shine', 'Frame')

tdCC.Shine = Shine

local shines = {}

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

    local grow = anim:CreateAnimation('Scale')
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

    shines[cooldown] = self
end

function Shine:OnHide()
    if self.anim:IsPlaying() then
        self.anim:Stop()
    end
    self:Hide()
end

---- global

function Shine:GetShine(cooldown)
    return shines[cooldown]
end

function Shine:StartShine(cooldown, set)
    local shine = self:GetShine(cooldown) or self:New(cooldown)

    shine.set = set
    shine:Start()
end

function Shine:Start()
    if self.anim:IsPlaying() then
        self.anim:Stop()
    end

    self.icon:SetTexture(self:GetIcon())

    local width, height = self.cooldown:GetSize()
    local scale = self.set:GetShineScale()
    self:SetSize(width * scale, height * scale)

    self.grow:SetScale(1 / scale, 1 / scale)
    self.grow:SetDuration(self.set:GetShineDuration())

    self:Show()
    self.anim:Play()
end

local ICONS = {
    ROUND     = [[Interface\Cooldown\ping4]],
    BLIZZARD  = [[Interface\Cooldown\star4]],
    EXPLOSIVE = [[Interface\Cooldown\starburst]],
}

function Shine:GetIcon()
    local icon = ICONS[self.set:GetShineType()]
    if icon then
        return icon
    end

    local frame = self:GetParent()
    if frame then
        local iconObject = self.iconObject
        if iconObject then
            return iconObject:GetTexture()
        end

        local name = frame:GetName()
        if name then
            local iconObject = _G[name .. 'Icon'] or _G[name .. 'IconTexture']
            if iconObject then
                self.iconObject = iconObject
                return iconObject:GetTexture()
            end
        end
    end
end
