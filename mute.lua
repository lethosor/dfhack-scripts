gui = require 'gui'

function sendkey(name, count)
    if not count then
        count = 1
    end
    k = df.interface_key[name]
    if not k then
        error('Invalid key: ' .. tostring(name))
    end
    for i = 1, count do
        gui.simulateInput(dfhack.gui.getCurViewscreen(), k)
    end
end

vs = df.viewscreen_optionst:new()
vs.options:insert('#', 4)
dfhack.screen.show(vs)
sendkey('SELECT')
sendkey('STANDARDSCROLL_PAGEDOWN', 13)
sendkey('LEAVESCREEN')
gui.simulateInput(vs, 'LEAVESCREEN')
