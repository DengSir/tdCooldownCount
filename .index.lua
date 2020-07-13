-- .index.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 3:15:49 PM

---@class Addon
---@field rules tdCCRule[]
---@field db tdCCDB

---@class tdCCTimer
---@field text FontString
---@field remain number
---@field profile tdCCThemeProfile
---@field style string
---@field styleProfile tdCCStyleProfile
---@field ratio number
---@field fontReady boolean
---
---@field cooldownTimers table<Cooldown, tdCCTimer>
---@field pool table<tdCCTimer, true>

---@class tdCCColor
---@field r number
---@field g number
---@field b number
---@field a number

---@class tdCCStyleProfile
---@field color tdCCColor
---@field scale number

---@class tdCCThemeProfile
---@field enable boolean
---@field hideBlizModel boolean
---@field minRatio number
---@field minDuration number
---@field startRemain number
---@field fontFace string
---@field fontSize number
---@field fontStyle string
---@field point string
---@field relativePoint string
---@field xOffset number
---@field yOffset number
---@field styles table<string, tdCCStyleProfile>
---@field shine boolean
---@field shineMinDuration number
---@field shineStyle string
---@field shineDuration number
---@field checkGCD boolean
---@field shortThreshold number
---@field expireThreshold number

---@class tdCCRule
---@field name string
---@field theme string
---@field priority number
---@field rule fun(cooldown:Cooldown): boolean
---@field enable boolean

---@class tdCCDB
---@field profile tdCCProfile

---@class tdCCProfile
---@field themes table<string, tdCCThemeProfile>
