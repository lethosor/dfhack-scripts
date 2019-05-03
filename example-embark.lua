
was_embarking = false
dfhack.onStateChange.your_script_name = function(event)
    if event == SC_VIEWSCREEN_CHANGED then
        if df.viewscreen_choose_start_sitest:is_instance(dfhack.gui.getCurViewscreen()) then
            was_embarking = true
        end
    elseif event == SC_MAP_LOADED then
        if was_embarking then
            print('do stuff')
        end
        -- make sure this doesn't fire again the next time a map loads, unless the user embarks again
        was_embarking = false
    end
end
