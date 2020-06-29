-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/30/2020, 12:21:34 AM

---@type ns
local ns = select(2, ...)

function ns.orderGenerater()
    local order = 0
    return function()
        order = order + 1
        return order
    end
end
