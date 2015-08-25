
macro = reqscript('macro')

macro.run(function()
    macro.start()

    screen.navigateTo(df.viewscreen_titlest)
    if scr.sel_subpage == scrtype.T_sel_subpage.About then return end

    local ok = false
    for index, id in pairs(scr.menu_line_id) do
        if id == scrtype.T_menu_line_id.AboutDF then
            scr.sel_menu_line = index
            ok = true
            break
        end
    end
    assert(ok, 'could not find "About" menu item')

    feed 'SELECT'
end)
