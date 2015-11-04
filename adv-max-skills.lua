-- Maximizes adventurer skills/attributes on creation
--[[=begin

adv-max-skills
==============
When creating an adventurer, raises all changeable skills and
attributes to their maximum level.

=end]]
if dfhack.gui.getCurFocus() ~= 'setupadventure' then
    qerror('Must be called on adventure mode setup screen')
end

adv = dfhack.gui.getCurViewscreen().adventurer
for k, v in pairs(adv.skills) do adv.skills[k] = 20 end
for k, v in pairs(adv.attributes) do adv.attributes[k] = 6 end
