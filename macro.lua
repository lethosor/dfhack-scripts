-- A Lua macro system
--@module = true

if not moduleMode then qerror('This script cannot be run standalone.') end

gui = require 'gui'

restricted = {}
exported = {}

local function getCurViewscreen() return dfhack.gui.getCurViewscreen(true) end

function typeName(type)
    return tostring(type):match(': ([^>]+)')
end

local function _add_to_list(name, list)
    if not _ENV[name] then error('Undefined: ' .. tostring(name)) end
    list[name] = true
end

local function restrict(name) _add_to_list(name, restricted) end
local function export(name) _add_to_list(name, exported) end

-- http://lua-users.org/lists/lua-l/2011-05/msg00115.html
local setfenv = setfenv or function(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name
    local up = 0
    repeat
        up = up + 1
        name = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    if name then
debug.upvaluejoin(f, up, function() return name end, 1) -- use unique upvalue
        debug.setupvalue(f, up, t)
    end
end

function run(func)
    func()
end
restrict('run')

index_handlers = {}
function index_handlers.scr() return getCurViewscreen() end
function index_handlers.scrtype() return getCurViewscreen()._type end

function setupenv(idx)
    local fenv = {}
    setmetatable(fenv, {__index = function(self, k)
        if index_handlers[k] then
            return index_handlers[k]()
        else
            return dfhack.BASE_G[k]
        end
    end})
    for k, v in pairs(_ENV) do
        if (type(v) == 'function' and not restricted[k]) or exported[k] then
            fenv[k] = v
        end
    end
    setfenv(idx or 2, fenv)
end
restrict('setupenv')

function start()
    setupenv(3)
end
restrict('start')

local function format(...)
    local args = {...}
    local fmt = table.remove(args, 1)
    if not fmt then return end
    return fmt:format(table.unpack(args))
end

-- exported functions

function log(...)
    print(format(...))
end

function assert(val, msg)
    if not val then
        qerror(msg)
    end
end

function feed(input)
    gui.simulateInput(getCurViewscreen(), input)
    return feed
end
key = feed
keys = feed

screen = {}
export('screen')
function screen.assert(type, ...)
    if not type:is_instance(getCurViewscreen()) then
        local args = {...}
        if #args >= 1 then
            qerror(format(...))
        else
            qerror(format('screen is not of type %s', typeName(type)))
        end
    end
end

function screen.findParent(type)
    local scr = getCurViewscreen()
    while scr and scr._type ~= type do
        scr = scr.parent
    end
    return scr
end

gotoHandlers = {}

function screen.navigateTo(destType, errMsg, opts)
    errMsg = errMsg and tostring(errMsg) or ('cannot navigate to required screen (%s)'):format(typeName(destType))
    local function err(s)
        qerror(errMsg .. ': ' .. tostring(s))
    end
    local srcType = typeName(getCurViewscreen()._type)
    if type(destType) ~= 'string' then destType = typeName(destType) end
    if srcType == destType then return end
    if not gotoHandlers[destType] or not gotoHandlers[destType][srcType] then
        err('no handlers found')
    end
    local ok, ret = pcall(gotoHandlers[destType][srcType].handler, opts)
    if not ok then
        err(ret)
    elseif ret == false then
        err('handler failed')
    end
end

function screen.registerGotoHandler(destType, srcType, handler, overwrite)
    if type(destType) ~= 'string' then destType = typeName(destType) end
    if type(srcType) ~= 'string' then srcType = typeName(srcType) end
    if not gotoHandlers[destType] then gotoHandlers[destType] = {} end
    if gotoHandlers[destType][srcType] and gotoHandlers[destType][srcType].defined and not overwrite then
        error('handler already exists')
    end
    gotoHandlers[destType][srcType] = {defined = true, handler = handler}
end

screen.registerGotoHandler(df.viewscreen_titlest, df.viewscreen_optionst, function()
    setupenv()
    if dfhack.isWorldLoaded() then qerror('world loaded') end
    if not screen.findParent(df.viewscreen_titlest) then
        qerror("can't find title screen")
    end
    while getCurViewscreen()._type ~= df.viewscreen_titlest do
        dfhack.screen.dismiss(getCurViewscreen())
    end
end)
