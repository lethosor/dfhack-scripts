-- View a unit's thoughts and preferences

unit = dfhack.gui.getSelectedUnit()
if not unit then return end
scr = df.viewscreen_unitst:new()
scr.unit = unit
dfhack.screen.show(scr)
