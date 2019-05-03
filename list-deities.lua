-- print('race=', df.historical_entity.find(df.global.ui.civ_id).race)
-- for _,f in pairs(df.global.world.history.figures) do
--     if f.flags.deity and f.race==572 then
--         print(f, f.id, 'race=', f.race)
--     end
-- end

-- found={}
-- for _, hfid in ipairs(df.historical_entity.find(df.global.ui.civ_id).histfig_ids) do
--     for _, link in ipairs(df.historical_figure.find(hfid).histfig_links) do
--         if df.histfig_hf_link_deityst:is_instance(link) then
--             found[link.target_hf] = true
--         end
--     end
-- end
-- for did in pairs(found) do
--     print(did)
-- end

unit = dfhack.gui.getSelectedUnit()
for _, link in ipairs(df.historical_figure.find(unit.hist_figure_id).histfig_links) do
    if df.histfig_hf_link_deit:is_instance(link) then
        deity = df.historical_figure.find(link.target_hf)
        print(dfhack.df2console(dfhack.TranslateName(deity.name)))
    end
end


