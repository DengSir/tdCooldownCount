
--[[

by ldz5

--]]

local MAJOR, MINOR = 'LibClass-1.0', 1
local Class = LibStub:NewLibrary(MAJOR, MINOR)
if not Class then
	return
end

---- Lua APIS

local error, pcall, type = error, pcall, type
local wipe, pairs, rawget, rawset = wipe, pairs, rawget, rawset
local setmetatable, hooksecurefunc = setmetatable, hooksecurefunc

---- WOW APIS

local CreateFrame = CreateFrame 

-----------------------------
--                     Object
-----------------------------

local Object = {}

local function Create(class, ...)
    local super = class:GetSuper()
    if super then
        return super:New(...)
    elseif Class:IsWidget(class) then
        return CreateFrame(class:GetObjectType(), nil, nil, class._Inherit)
    else
        return {}
    end
end

local function CreateMeta(class)
    local _Meta = rawget(class, '_Meta') or {}
    _Meta.__index = _Meta.__index or class
    
    rawset(class, '_Meta', _Meta)
    return _Meta
end

local function Destroy(object)
    if Class:IsWidget(object) then
        object:SetParent(nil)
        object:ClearAllPoints()
    end
    wipe(object)
end

function Object:New(...)
    if not Class:IsClass(self) then
        error([[bad argument #self to 'New' (class expected)]], 2)
    end
    
    local object = setmetatable(Create(self, ...), CreateMeta(self))
    
    local ctor = rawget(self, 'Constructor')
    if type(ctor) == 'function' then
        ctor(object, ...)
    end
    return object
end

function Object:GetSuper()
    return self._Super
end

function Object:GetType()
    return self._Type
end

function Object:GetTypeName()
    return self._TypeName
end

function Object:IsType(class)
    if not self.GetType then
        return false
    end
    if not Class:IsClass(class) then
        return false
    end
    if self:GetType() == class then
        return true
    end
    local super = self:GetSuper()
    return super and super:IsType(class) or false
end

function Object:IsInstance(object)
    if not Class:IsClass(self) then
        error([[bad argument #self to 'IsInstance' (class expected)]], 2)
    end
    if not Class:IsObject(object) then
        return false
    end
    return object:IsType(self)
end

-----------------------------
--                      Class
-----------------------------

function Class:New(name, super)
    if self ~= Class then
        error([[Usage: Class:New(name[, super])]], 2)
    end
    if type(name) ~= 'string' then
        error(([[bad argument #1 to 'New' (string expected, got %s)]]):format(type(name)), 2)
    end
    
    local class
    if super == nil then
        class = {}
    elseif type(super) == 'string' then
        local objectType, inherit = super:match('^(%a+)%.?([%w_]*)$')
        
        local ok, value = pcall(CreateFrame, objectType)
        if not ok then
            error(([['%s' isnot blizzard widget object.]]):format(super), 2)
        end
        class = value
        class._Inherit = inherit ~= '' and inherit or nil
        class:Hide()
    elseif Class:IsClass(super) then
        class = super:New()
        class._Super = super
        if Class:IsWidget(class) then
            class:Hide()
        end
    else
        error([[bad argument #2 to 'New' (string/class/widget expected)]], 2)
    end
    
    rawset(class, '_Type', class)
    rawset(class, '_TypeName', name)
    
    for k, v in pairs(Object) do
        class[k] = v
    end
    
    return class
end

function Class:IsClass(value)
    if self ~= Class then
        error([[Usage: Class:IsClass(value)]], 2)
    end
    if type(value) ~= 'table' then
        return false
    end
    return rawget(value, '_Type') == value
end

function Class:IsObject(value)
    if self ~= Class then
        error([[Usage: Class:IsObject(value)]], 2)
    end
    if type(value) ~= 'table' then
        return false
    end
    return not rawget(value, '_Type') and Class:IsClass(value._Type) or false
end

function Class:IsWidget(value)
    if self ~= Class then
        error([[Usage: Class:IsWidget(value)]], 2)
    end
    if type(value) ~= 'table' then
        return false
    end
    return value.GetObjectType and type(value[0]) == 'userdata' or false
end

local classes = setmetatable({}, {__index = function(o, k)
    o[k] = {}
    return o[k]
end})

function Class:NewClass(name, ...)
    if classes[self][name] then
        return
    end
    local class = Class:New(name, ...)
    classes[self][name] = class
    return class
end

function Class:GetClass(name)
    return classes[self][name]
end

function Class:Embed(object)
    object.NewClass = Class.NewClass
    object.GetClass = Class.GetClass
end
