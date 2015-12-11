-- open legends screen when in fortress mode
--@ module = true
--[[=begin

open-legends
============
Open a legends screen when in fortress mode.
Compatible with `exportlegends`.

=end]]

gui = require 'gui'
utils = require 'utils'

Wrapper = defclass(Wrapper, gui.Screen)
Wrapper.focus_path = 'legends'

function Wrapper:onRender()
    self._native.parent:render()
end

function Wrapper:onIdle()
    self._native.parent:logic()
end

function Wrapper:onHelp()
    self._native.parent:help()
end

function Wrapper:onInput(keys)
    if self._native.parent.cur_page == 0 and keys.LEAVESCREEN then
        self:dismiss()
        dfhack.screen.dismiss(self._native.parent)
        return
    end
    gui.simulateInput(self._native.parent, keys)
end

function show(force)
    if not dfhack.isWorldLoaded() then
        qerror('no world loaded')
    end

    local view = df.global.gview.view
    while view do
        if df.viewscreen_legendsst:is_instance(view) then
            qerror('legends screen already displayed')
        end
        view = view.child
    end
    local old_view = dfhack.gui.getCurViewscreen()

    if not dfhack.world.isFortressMode(df.global.gametype) and not dfhack.world.isAdventureMode(df.global.gametype) and not force then
        qerror('mode not tested: ' .. df.game_type[df.global.gametype] .. ' (use "force" to force)')
    end

    local ok, err = pcall(function()
        dfhack.screen.show(df.viewscreen_legendsst:new())
        Wrapper():show()
    end)
    if not ok then
        while dfhack.gui.getCurViewscreen(true) ~= old_view do
            dfhack.screen.dismiss(dfhack.gui.getCurViewscreen(true))
        end
        qerror('Failed to set up legends screen: ' .. tostring(err))
    end
end

if not moduleMode then
    local iargs = utils.invert{...}
    show(iargs.force)
end
