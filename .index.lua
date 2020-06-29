-- .index.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/29/2020, 3:15:49 PM

---@class Timer
---@field text FontString
---@field remain number
---@field profile Theme
---@field style string
---@field styleProfile RemainStyle
---@field ratio number
---@field fontReady boolean

---@class Color
---@field r number
---@field g number
---@field b number
---@field a number

---@class RemainStyle
---@field color Color
---@field scale number

---@class Theme
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
---@field styles table<string, RemainStyle>
---@field shine boolean

---@class Rule
---@field name string
---@field theme string
---@field priority number
---@field rule fun(cooldown:Cooldown): boolean
