u = dfhack.gui.getSelectedUnit(true) or qerror('No selected unit')
s = df.viewscreen_unitlistst:new()
dfhack.screen.show(s)
s.units.Citizens:insert('#', u)
s.jobs.Citizens:insert('#', u.job.current_job)
s.cursor_pos.Citizens = 0
