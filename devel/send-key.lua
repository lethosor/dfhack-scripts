args = {...}
key = df.interface_key[args[1]]
if not key then qerror('Unrecognized key') end
gui = require 'gui'
p = tonumber(args[2])
scr = dfhack.gui.getCurViewscreen()
if p ~= nil then
    while p > 0 do
        p = p - 1
        scr = scr.parent
    end
end
gui.simulateInput(scr, key)
