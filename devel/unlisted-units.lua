local active = df.global.world.units.active
local scr = dfhack.gui.getCurViewscreen()
local utils = require 'utils'

if not df.viewscreen_unitlistst:is_instance(scr) then
    qerror('need unit list screen')
end

local scr_count = 0
scr_ids = {}
for _, vec in pairs(scr.units) do
    scr_count = scr_count + #vec
    for _, u in pairs(vec) do
        scr_ids[u.id] = true
    end
end
active_ids = {}
for _, u in pairs(active) do
    active_ids[u.id] = true
end
print('Units in screen: ' .. scr_count)
print('Active units: ' .. #active)

unlisted_ids = utils.clone(active_ids)
for listed_id in pairs(scr_ids) do
    unlisted_ids[listed_id] = nil
end
print('Unlisted IDs:')
printall(unlisted_ids)
unlisted_count = 0
for _ in pairs(unlisted_ids) do
    unlisted_count = unlisted_count + 1
end
print('total: ' .. unlisted_count)
print('expected: ' .. (#active - scr_count))
