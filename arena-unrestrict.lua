for _, creature_raw in pairs(df.global.world.raws.creatures.all) do
    for _, caste_raw in pairs(creature_raw.caste) do
        if caste_raw.flags.ARENA_RESTRICTED then
            caste_raw.flags.ARENA_RESTRICTED = false
            print(('Unrestricted %s:%s'):format(creature_raw.creature_id, caste_raw.caste_id))
        end
    end
end
