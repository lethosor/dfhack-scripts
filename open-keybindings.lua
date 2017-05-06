gui = require 'gui'
vs = df.viewscreen_optionst:new()
vs.options:insert('#', df.viewscreen_optionst.T_options.KeyBindings)
dfhack.screen.show(vs)
gui.simulateInput(vs, 'SELECT')
