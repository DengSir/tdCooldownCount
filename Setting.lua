
local SOON, SECOND, SHORT, MINUTE, HOUR, DAY = 10, 60, 600, 3600, 86400

local tdCC = LibStub('AceAddon-3.0'):GetAddon('tdCC')

local Setting = tdCC:NewClass('Setting')

local STYLE_DB_KEYS = {
	SOON 	= 'SOON',
	SECOND 	= 'SECOND',
	SHORT 	= 'MINUTE',
	MINUTE 	= 'MINUTE',
	HOUR	= 'HOUR',
	DAY 	= 'HOUR',
}

local TextHelper = {}
local NextHelper = {}

function Setting:Constructor(timer)
	self.timer = timer
	self.cooldown = timer.cooldown
end

function Setting:Refresh()
	self.style = nil
	self.key = nil
	self.type = tdCC:GetCooldownType(self.cooldown)
end

function Setting:GetNextUpdate()
	return NextHelper[self.key](self:GetRemain())
end

function Setting:IsStyleChanged()
	local style = self:GetStyle()
	if self.style ~= style then
		self.style = style
		self.key = STYLE_DB_KEYS[style]
		return true
	end
end

function Setting:GetStyle()
	local remain = self:GetRemain()
	if remain < SOON then
		return 'SOON'
	elseif remain < SECOND then
		return 'SECOND'
	elseif remain < SHORT then
		return self:GetMMSS() and 'SHORT' or 'MINUTE'
	elseif remain < MINUTE then
		return 'MINUTE'
	elseif remain < HOUR then
		return 'HOUR'
	else
		return 'DAY'
	end
end

function Setting:GetRemain()
	return self.timer:GetRemain()
end

function Setting:GetProfile()
	return tdCC.db.profile.types[self.type]
end

function Setting:GetStyleProfile()
	return self:GetProfile().styles[self.key]
end

function Setting:GetTimeText()
	return TextHelper[self.style](self:GetRemain())
end

function Setting:GetTimeColor()
	local color = self:GetStyleProfile()
	return color.r, color.g, color.b
end

function Setting:GetTimeScale()
	return self:GetStyleProfile().scale
end

function Setting:GetMMSS()
	return self:GetProfile().mmss
end

function Setting:IsHideBlizModel()
	return self:GetProfile().hideBlizModel
end

function Setting:GetPositionArgs()
	local set = self:GetProfile()
	return set.anchor, set.xOffset * self.timer.ratio, set.yOffset * self.timer.ratio
end

function Setting:GetFontArgs()
	local set = self:GetProfile()
	return tdCC:GetFont(set.fontFace), set.fontSize * self.timer.ratio * self:GetTimeScale(), set.fontOutline
end

function Setting:GetMinRatio()
	return self:GetProfile().minRatio
end

function Setting:GetStartRemain()
	return self:GetProfile().startRemain
end

---- TextHelper

function TextHelper.SOON(remain)
	return ('%d'):format(ceil(remain))
end
TextHelper.SECOND = TextHelper.SOON

function TextHelper.SHORT(remain)
	remain= ceil(remain)
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
