-- Cooldown.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/1/2020, 3:50:26 PM

---@type ns
local ns = select(2, ...)

local GetTime = GetTime
local GetSpellCooldown = GetSpellCooldown

local Addon = ns.Addon

local THEME_DEFAULT = ns.THEME_DEFAULT

local cooldowns = {}

local function setCooldown(cooldown, start, duration)
    return Addon:SetCooldown(cooldown, start, duration)
end

local function cooldownOnShow(cooldown)
    if cooldown._tdcc_start then
        local start, duration = cooldown._tdcc_start, cooldown._tdcc_duration

        cooldown._tdcc_start = nil
        cooldown._tdcc_duration = nil

        if start + duration > GetTime() then
            setCooldown(cooldown, start, duration)
        end
    end
end

local function cooldownOnHide(cooldown)
    ns.Timer:StopTimer(cooldown)
end

function Addon:SetupHooks()
    hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, 'SetCooldown', setCooldown)
end

function Addon:HookCooldown(cooldown)
    if cooldowns[cooldown] then
        return
    end
    cooldowns[cooldown] = true

    cooldown:HookScript('OnShow', cooldownOnShow)
    cooldown:HookScript('OnHide', cooldownOnHide)
end

function Addon:SetCooldown(cooldown, start, duration, m)
    local show, keep = self:ShouldShow(cooldown, start, duration)
    if keep then
        return
    end
    if show then
        self:HookCooldown(cooldown)

        cooldown._tdcc_start = start
        cooldown._tdcc_duration = duration

        return ns.Timer:StartTimer(cooldown, start, duration)
    else
        return ns.Timer:StopTimer(cooldown, start, duration)
    end
end

function Addon:ShouldShow(cooldown, start, duration)
    if cooldown.noCooldownCount or cooldown:IsPaused() then
        return
    end
    if not start or start == 0 then
        return
    end
    if not duration or duration == 0 then
        return
    end
    local profile = self:GetCooldownProfile(cooldown)
    if not profile or not profile.enable then
        return
    end
    if profile.checkGCD then
        local gcdStart, gcdDuration = GetSpellCooldown(29515) -- 29515/61304
        if gcdStart == start and gcdDuration == duration then
            local timer = ns.Timer:GetTimer(cooldown)
            if not timer then
                return
            end

            if timer:GetRemain() < gcdDuration + 0.05 then
                return true, true
            end
        end
    end
    if duration <= profile.minDuration then
        return
    end
    -- if profile.hideHaveCharges and cooldown:GetDrawEdge() then
    --     return
    -- end
    return true, false
end

function Addon:GetCooldownProfile(cooldown)
    local theme = self:GetCooldownTheme(cooldown)
    return theme and self.db.profile.themes[theme] or self.db.profile.themes[THEME_DEFAULT]
end
