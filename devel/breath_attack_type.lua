-- scan for new breath_attack_type values
-- df.global.world.raws.creatures.all[190].caste.1.body_info.interactions.0.interaction <type: creature_interaction> -> material_breath

for id, raw in ipairs(df.global.world.raws.creatures.all) do
    for cid, caste in ipairs(raw.caste) do
        for iid, int in ipairs(caste.body_info.interactions) do
            local interaction = int.interaction
            if not df.breath_attack_type[interaction.material_breath] then
                print(id, raw.name[0], cid, iid, 'type:', interaction.material_breath, 'verb:', interaction.verb_2nd, 'wp:', interaction.wait_period)
            end
        end
    end
end
