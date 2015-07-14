key = df.interface_key[({...})[1]]
if not key then qerror('Unrecognized key') end
gui = require 'gui'
gui.simulateInput(dfhack.gui.getCurViewscreen(), key)
