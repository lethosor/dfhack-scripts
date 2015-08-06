args = {...}
if args[1] == 'print' then
    dfhack.color(COLOR_LIGHTGREEN)
    print('keybinding invoked: ' .. args[2])
    dfhack.color()
elseif args[1] then
    prefix = args[1] .. '-'
else
    prefix = ''
end
for ch = string.byte('A'), string.byte('Z') do
    kb = prefix .. string.char(ch) .. '@' .. dfhack.gui.getCurFocus()
    dfhack.run_command{'keybinding', 'add', kb, 'devel/keybinding-test print ' .. kb}
end
