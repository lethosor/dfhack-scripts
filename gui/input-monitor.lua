-- Mouse/keyboard monitor

DFH_MOD_SHIFT = 1
DFH_MOD_CTRL = 2
DFH_MOD_ALT = 4

bit32 = require 'bit32'
gui = require 'gui'

enabler = df.global.enabler
gps = df.global.gps
OutputString = dfhack.screen.paintString

function format_modstate(m)
    s = ''
    if bit32.band(m, DFH_MOD_SHIFT) ~= 0 then s = s .. 'Shift-' end
    if bit32.band(m, DFH_MOD_CTRL) ~= 0 then s = s .. 'Ctrl-' end
    if bit32.band(m, DFH_MOD_ALT) ~= 0 then s = s .. 'Alt-' end
    if #s > 0 then s = s:sub(1, #s - 1) end
    return s
end

viewscreen_inputst = defclass(viewscreen_inputst, gui.Screen)
viewscreen_inputst.focus_path = 'input_monitor'
function viewscreen_inputst:init()
    self.old_fps = gps.display_frames
    gps.display_frames = 0
end

function viewscreen_inputst:onRender()
    dfhack.screen.clear()
    local p = gui.Painter()
    p:seek(0, gps.dimy - 1)
    local mx = gps.mouse_x
    local my = gps.mouse_y
    if my == gps.dimy - 1 then p:seek(nil, 0) end
    p:string(format_modstate(dfhack.internal.getModstate()))
    p:seek(15)
    p:string(('(%i,%i)'):format(mx, my))
    p:seek(15 + 8)
    local mouse_bg = COLOR_RED
    if enabler.mouse_rbut_down == 1 then
        mouse_bg = COLOR_GREEN
        p:string('Right ')
    elseif enabler.mouse_lbut_down == 1 then
        mouse_bg = COLOR_BLUE
        p:string('Left  ')
    else
        p:string('      ')
    end
    p:string(('FPS: %i (%i)'):format(enabler.calculated_fps, enabler.calculated_gfps))
    p:seek(mx, my):string(' ', {bg = mouse_bg})
end

function viewscreen_inputst:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

function viewscreen_inputst:onDismiss()
    gps.display_frames = self.old_fps
end

viewscreen_inputst():show()
