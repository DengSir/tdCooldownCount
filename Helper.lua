-- Helper.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/13/2020, 2:40:52 PM
---@type ns
local ns = select(2, ...)

local format = string.format
local floor, ceil = math.floor, math.ceil

local TextHelper = {}
local NextHelper = {}

local SOON, SECOND, MINUTE, HOUR, DAY = 10, 60, 3600, 86400

ns.TextHelper = TextHelper
ns.NextHelper = NextHelper

local TimerHelper = {}
ns.TimerHelper = TimerHelper

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

---@param timer tdCCTimer
local function checkText(timer)
    local remain = timer.remain
    print(remain, timer.profile.expireThreshold)
    if remain < timer.profile.expireThreshold then
        return TextHelper.EXPIRE
    elseif remain < SECOND then
        return TextHelper.SECOND
    elseif remain < timer.profile.shortThreshold then
        return TextHelper.SHORT
    elseif remain < MINUTE then
        return TextHelper.MINUTE
    elseif remain < HOUR then
        return TextHelper.HOUR
    else
        return TextHelper.DAY
    end
end

setmetatable(TextHelper, {__call = function(self, timer)
    return checkText(timer)(timer.remain)
end})


---@param timer tdCCTimer
local function checkNext(timer)
    local remain = timer.remain
    if remain < timer.profile.expireThreshold then
        return NextHelper.EXPIRE
    elseif remain < SECOND then
        return NextHelper.SECOND
    elseif remain < timer.profile.shortThreshold then
        return NextHelper.SECOND
    elseif remain < MINUTE then
        return NextHelper.MINUTE
    elseif remain < HOUR then
        return NextHelper.HOUR
    else
        return NextHelper.DAY
    end
end

setmetatable(NextHelper, {__call = function(self, timer)
    return checkNext(timer)(timer.remain)
end})

---@param timer tdCCTimer
local function checkStyle(timer)
    local remain = timer.remain

    if remain < SOON then
        return 'SOON'
    elseif remain < SECOND then
        return 'SECOND'
    elseif remain < MINUTE then
        return 'MINUTE'
    else
        return 'HOUR'
    end
end

---@param timer tdCCTimer
function TimerHelper:Update(timer)
    local style = checkStyle(timer)

    if style ~= timer.style then
        timer.style = style
        timer.styleProfile = timer.profile.styles[style]
        return true
    end
end
