-- manipulator
SKILL_COLUMNS = {
    {group = 0, color = 7, profession = 'MINER', labor = 'MINE', skill = 'MINING', label = "Mi", special = true},
-- Woodworking
    {group = 1, color = 14, profession = 'CARPENTER', labor = 'CARPENTER', skill = 'CARPENTRY', label = "Ca"},
    {group = 1, color = 14, profession = 'BOWYER', labor = 'BOWYER', skill = 'BOWYER', label = "Bw"},
    {group = 1, color = 14, profession = 'WOODCUTTER', labor = 'CUTWOOD', skill = 'WOODCUTTING', label = "WC", special = true},
-- Stoneworking
    {group = 2, color = 15, profession = 'MASON', labor = 'MASON', skill = 'MASONRY', label = "Ma"},
    {group = 2, color = 15, profession = 'ENGRAVER', labor = 'DETAIL', skill = 'DETAILSTONE', label = "En"},
-- Hunting/Related
    {group = 3, color = 2, profession = 'ANIMAL_TRAINER', labor = 'ANIMALTRAIN', skill = 'ANIMALTRAIN', label = "Tn"},
    {group = 3, color = 2, profession = 'ANIMAL_CARETAKER', labor = 'ANIMALCARE', skill = 'ANIMALCARE', label = "Ca"},
    {group = 3, color = 2, profession = 'HUNTER', labor = 'HUNT', skill = 'SNEAK', label = "Hu", special = true},
    {group = 3, color = 2, profession = 'TRAPPER', labor = 'TRAPPER', skill = 'TRAPPING', label = "Tr"},
    {group = 3, color = 2, profession = 'ANIMAL_DISSECTOR', labor = 'DISSECT_VERMIN', skill = 'DISSECT_VERMIN', label = "Di"},
-- Healthcare
    {group = 4, color = 5, profession = 'DIAGNOSER', labor = 'DIAGNOSE', skill = 'DIAGNOSE', label = "Di"},
    {group = 4, color = 5, profession = 'SURGEON', labor = 'SURGERY', skill = 'SURGERY', label = "Su"},
    {group = 4, color = 5, profession = 'BONE_SETTER', labor = 'BONE_SETTING', skill = 'SET_BONE', label = "Bo"},
    {group = 4, color = 5, profession = 'SUTURER', labor = 'SUTURING', skill = 'SUTURE', label = "St"},
    {group = 4, color = 5, profession = 'DOCTOR', labor = 'DRESSING_WOUNDS', skill = 'DRESS_WOUNDS', label = "Dr"},
    {group = 4, color = 5, profession = 'NONE', labor = 'FEED_WATER_CIVILIANS', skill = 'NONE', label = "Fd"},
    {group = 4, color = 5, profession = 'NONE', labor = 'RECOVER_WOUNDED', skill = 'NONE', label = "Re"},
-- Farming/Related
    {group = 5, color = 6, profession = 'BUTCHER', labor = 'BUTCHER', skill = 'BUTCHER', label = "Bu"},
    {group = 5, color = 6, profession = 'TANNER', labor = 'TANNER', skill = 'TANNER', label = "Ta"},
    {group = 5, color = 6, profession = 'PLANTER', labor = 'PLANT', skill = 'PLANT', label = "Gr"},
    {group = 5, color = 6, profession = 'DYER', labor = 'DYER', skill = 'DYER', label = "Dy"},
    {group = 5, color = 6, profession = 'SOAP_MAKER', labor = 'SOAP_MAKER', skill = 'SOAP_MAKING', label = "So"},
    {group = 5, color = 6, profession = 'WOOD_BURNER', labor = 'BURN_WOOD', skill = 'WOOD_BURNING', label = "WB"},
    {group = 5, color = 6, profession = 'POTASH_MAKER', labor = 'POTASH_MAKING', skill = 'POTASH_MAKING', label = "Po"},
    {group = 5, color = 6, profession = 'LYE_MAKER', labor = 'LYE_MAKING', skill = 'LYE_MAKING', label = "Ly"},
    {group = 5, color = 6, profession = 'MILLER', labor = 'MILLER', skill = 'MILLING', label = "Ml"},
    {group = 5, color = 6, profession = 'BREWER', labor = 'BREWER', skill = 'BREWING', label = "Br"},
    {group = 5, color = 6, profession = 'HERBALIST', labor = 'HERBALIST', skill = 'HERBALISM', label = "He"},
    {group = 5, color = 6, profession = 'THRESHER', labor = 'PROCESS_PLANT', skill = 'PROCESSPLANTS', label = "Th"},
    {group = 5, color = 6, profession = 'CHEESE_MAKER', labor = 'MAKE_CHEESE', skill = 'CHEESEMAKING', label = "Ch"},
    {group = 5, color = 6, profession = 'MILKER', labor = 'MILK', skill = 'MILK', label = "Mk"},
    {group = 5, color = 6, profession = 'SHEARER', labor = 'SHEARER', skill = 'SHEARING', label = "Sh"},
    {group = 5, color = 6, profession = 'SPINNER', labor = 'SPINNER', skill = 'SPINNING', label = "Sp"},
    {group = 5, color = 6, profession = 'COOK', labor = 'COOK', skill = 'COOK', label = "Co"},
    {group = 5, color = 6, profession = 'PRESSER', labor = 'PRESSING', skill = 'PRESSING', label = "Pr"},
    {group = 5, color = 6, profession = 'BEEKEEPER', labor = 'BEEKEEPING', skill = 'BEEKEEPING', label = "Be"},
    {group = 5, color = 6, profession = 'GELDER', labor = 'GELD', skill = 'GELD', label = "Ge"},
-- Fishing/Related
    {group = 6, color = 1, profession = 'FISHERMAN', labor = 'FISH', skill = 'FISH', label = "Fi"},
    {group = 6, color = 1, profession = 'FISH_CLEANER', labor = 'CLEAN_FISH', skill = 'PROCESSFISH', label = "Cl"},
    {group = 6, color = 1, profession = 'FISH_DISSECTOR', labor = 'DISSECT_FISH', skill = 'DISSECT_FISH', label = "Di"},
-- Metalsmithing
    {group = 7, color = 8, profession = 'FURNACE_OPERATOR', labor = 'SMELT', skill = 'SMELT', label = "Fu"},
    {group = 7, color = 8, profession = 'WEAPONSMITH', labor = 'FORGE_WEAPON', skill = 'FORGE_WEAPON', label = "We"},
    {group = 7, color = 8, profession = 'ARMORER', labor = 'FORGE_ARMOR', skill = 'FORGE_ARMOR', label = "Ar"},
    {group = 7, color = 8, profession = 'BLACKSMITH', labor = 'FORGE_FURNITURE', skill = 'FORGE_FURNITURE', label = "Bl"},
    {group = 7, color = 8, profession = 'METALCRAFTER', labor = 'METAL_CRAFT', skill = 'METALCRAFT', label = "Cr"},
-- Jewelry
    {group = 8, color = 10, profession = 'GEM_CUTTER', labor = 'CUT_GEM', skill = 'CUTGEM', label = "Cu"},
    {group = 8, color = 10, profession = 'GEM_SETTER', labor = 'ENCRUST_GEM', skill = 'ENCRUSTGEM', label = "Se"},
-- Crafts
    {group = 9, color = 9, profession = 'LEATHERWORKER', labor = 'LEATHER', skill = 'LEATHERWORK', label = "Le"},
    {group = 9, color = 9, profession = 'WOODCRAFTER', labor = 'WOOD_CRAFT', skill = 'WOODCRAFT', label = "Wo"},
    {group = 9, color = 9, profession = 'STONECRAFTER', labor = 'STONE_CRAFT', skill = 'STONECRAFT', label = "St"},
    {group = 9, color = 9, profession = 'BONE_CARVER', labor = 'BONE_CARVE', skill = 'BONECARVE', label = "Bo"},
    {group = 9, color = 9, profession = 'GLASSMAKER', labor = 'GLASSMAKER', skill = 'GLASSMAKER', label = "Gl"},
    {group = 9, color = 9, profession = 'WEAVER', labor = 'WEAVER', skill = 'WEAVING', label = "We"},
    {group = 9, color = 9, profession = 'CLOTHIER', labor = 'CLOTHESMAKER', skill = 'CLOTHESMAKING', label = "Cl"},
    {group = 9, color = 9, profession = 'STRAND_EXTRACTOR', labor = 'EXTRACT_STRAND', skill = 'EXTRACT_STRAND', label = "Ad"},
    {group = 9, color = 9, profession = 'POTTER', labor = 'POTTERY', skill = 'POTTERY', label = "Po"},
    {group = 9, color = 9, profession = 'GLAZER', labor = 'GLAZING', skill = 'GLAZING', label = "Gl"},
    {group = 9, color = 9, profession = 'WAX_WORKER', labor = 'WAX_WORKING', skill = 'WAX_WORKING', label = "Wx"},
-- Engineering
    {group = 10, color = 12, profession = 'SIEGE_ENGINEER', labor = 'SIEGECRAFT', skill = 'SIEGECRAFT', label = "En"},
    {group = 10, color = 12, profession = 'SIEGE_OPERATOR', labor = 'SIEGEOPERATE', skill = 'SIEGEOPERATE', label = "Op"},
    {group = 10, color = 12, profession = 'MECHANIC', labor = 'MECHANIC', skill = 'MECHANICS', label = "Me"},
    {group = 10, color = 12, profession = 'PUMP_OPERATOR', labor = 'OPERATE_PUMP', skill = 'OPERATE_PUMP', label = "Pu"},
-- Hauling
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_STONE', skill = 'NONE', label = "St"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_WOOD', skill = 'NONE', label = "Wo"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_ITEM', skill = 'NONE', label = "It"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_BODY', skill = 'NONE', label = "Bu"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_FOOD', skill = 'NONE', label = "Fo"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_REFUSE', skill = 'NONE', label = "Re"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_FURNITURE', skill = 'NONE', label = "Fu"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_ANIMALS', skill = 'NONE', label = "An"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HANDLE_VEHICLES', skill = 'NONE', label = "Ve"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_TRADE', skill = 'NONE', label = "Tr"},
    {group = 11, color = 3, profession = 'NONE', labor = 'HAUL_WATER', skill = 'NONE', label = "Wa"},
-- Other Jobs
    {group = 12, color = 4, profession = 'ARCHITECT', labor = 'ARCHITECT', skill = 'DESIGNBUILDING', label = "Ar"},
    {group = 12, color = 4, profession = 'ALCHEMIST', labor = 'ALCHEMIST', skill = 'ALCHEMY', label = "Al"},
    {group = 12, color = 4, profession = 'NONE', labor = 'CLEAN', skill = 'NONE', label = "Cl"},
    {group = 12, color = 4, profession = 'NONE', labor = 'PULL_LEVER', skill = 'NONE', label = "Lv"},
    {group = 12, color = 4, profession = 'NONE', labor = 'BUILD_ROAD', skill = 'NONE', label = "Ro"},
    {group = 12, color = 4, profession = 'NONE', labor = 'BUILD_CONSTRUCTION', skill = 'NONE', label = "Co"},
    {group = 12, color = 4, profession = 'NONE', labor = 'REMOVE_CONSTRUCTION', skill = 'NONE', label = "CR"},
-- Military - Weapons
    {group = 13, color = 7, profession = 'WRESTLER', labor = 'NONE', skill = 'WRESTLING', label = "Wr"},
    {group = 13, color = 7, profession = 'AXEMAN', labor = 'NONE', skill = 'AXE', label = "Ax"},
    {group = 13, color = 7, profession = 'SWORDSMAN', labor = 'NONE', skill = 'SWORD', label = "Sw"},
    {group = 13, color = 7, profession = 'MACEMAN', labor = 'NONE', skill = 'MACE', label = "Mc"},
    {group = 13, color = 7, profession = 'HAMMERMAN', labor = 'NONE', skill = 'HAMMER', label = "Ha"},
    {group = 13, color = 7, profession = 'SPEARMAN', labor = 'NONE', skill = 'SPEAR', label = "Sp"},
    {group = 13, color = 7, profession = 'CROSSBOWMAN', labor = 'NONE', skill = 'CROSSBOW', label = "Cb"},
    {group = 13, color = 7, profession = 'THIEF', labor = 'NONE', skill = 'DAGGER', label = "Kn"},
    {group = 13, color = 7, profession = 'BOWMAN', labor = 'NONE', skill = 'BOW', label = "Bo"},
    {group = 13, color = 7, profession = 'BLOWGUNMAN', labor = 'NONE', skill = 'BLOWGUN', label = "Bl"},
    {group = 13, color = 7, profession = 'PIKEMAN', labor = 'NONE', skill = 'PIKE', label = "Pk"},
    {group = 13, color = 7, profession = 'LASHER', labor = 'NONE', skill = 'WHIP', label = "La"},
-- Military - Other Combat
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'BITE', label = "Bi"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'GRASP_STRIKE', label = "St"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'STANCE_STRIKE', label = "Ki"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'MISC_WEAPON', label = "Mi"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'MELEE_COMBAT', label = "Fg"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'RANGED_COMBAT', label = "Ac"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'ARMOR', label = "Ar"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'SHIELD', label = "Sh"},
    {group = 14, color = 15, profession = 'NONE', labor = 'NONE', skill = 'DODGING', label = "Do"},
-- Military - Misc
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'LEADERSHIP', label = "Ld"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'TEACHING', label = "Te"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'KNOWLEDGE_ACQUISITION', label = "St"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'DISCIPLINE', label = "Di"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'CONCENTRATION', label = "Co"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'SITUATIONAL_AWARENESS', label = "Ob"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'COORDINATION', label = "Cr"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'BALANCE', label = "Ba"},
    {group = 15, color = 8, profession = 'NONE', labor = 'NONE', skill = 'CLIMBING', label = "Cl"},
-- Social
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'PERSUASION', label = "Pe"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'NEGOTIATION', label = "Ne"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'JUDGING_INTENT', label = "Ju"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'LYING', label = "Li"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'INTIMIDATION', label = "In"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'CONVERSATION', label = "Cn"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'COMEDY', label = "Cm"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'FLATTERY', label = "Fl"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'CONSOLE', label = "Cs"},
    {group = 16, color = 3, profession = 'NONE', labor = 'NONE', skill = 'PACIFY', label = "Pc"},
-- Noble
    {group = 17, color = 5, profession = 'TRADER', labor = 'NONE', skill = 'APPRAISAL', label = "Ap"},
    {group = 17, color = 5, profession = 'ADMINISTRATOR', labor = 'NONE', skill = 'ORGANIZATION', label = "Or"},
    {group = 17, color = 5, profession = 'CLERK', labor = 'NONE', skill = 'RECORD_KEEPING', label = "RK"},
-- Miscellaneous
    {group = 18, color = 3, profession = 'NONE', labor = 'NONE', skill = 'THROW', label = "Th"},
    {group = 18, color = 3, profession = 'NONE', labor = 'NONE', skill = 'CRUTCH_WALK', label = "CW"},
    {group = 18, color = 3, profession = 'NONE', labor = 'NONE', skill = 'SWIMMING', label = "Sw"},
    {group = 18, color = 3, profession = 'NONE', labor = 'NONE', skill = 'KNAPPING', label = "Kn"},

    {group = 19, color = 6, profession = 'NONE', labor = 'NONE', skill = 'WRITING', label = "Wr"},
    {group = 19, color = 6, profession = 'NONE', labor = 'NONE', skill = 'PROSE', label = "Pr"},
    {group = 19, color = 6, profession = 'NONE', labor = 'NONE', skill = 'POETRY', label = "Po"},
    {group = 19, color = 6, profession = 'NONE', labor = 'NONE', skill = 'READING', label = "Rd"},
    {group = 19, color = 6, profession = 'NONE', labor = 'NONE', skill = 'SPEAKING', label = "Sp"},

    {group = 20, color = 5, profession = 'NONE', labor = 'NONE', skill = 'MILITARY_TACTICS', label = "MT"},
    {group = 20, color = 5, profession = 'NONE', labor = 'NONE', skill = 'TRACKING', label = "Tr"},
    {group = 20, color = 5, profession = 'NONE', labor = 'NONE', skill = 'MAGIC_NATURE', label = "Dr"},
}

SKILL_LEVELS = {
    {name = "Dabbling",     points = 500,  abbr = '0'},
    {name = "Novice",       points = 600,  abbr = '1'},
    {name = "Adequate",     points = 700,  abbr = '2'},
    {name = "Competent",    points = 800,  abbr = '3'},
    {name = "Skilled",      points = 900,  abbr = '4'},
    {name = "Proficient",   points = 1000, abbr = '5'},
    {name = "Talented",     points = 1100, abbr = '6'},
    {name = "Adept",        points = 1200, abbr = '7'},
    {name = "Expert",       points = 1300, abbr = '8'},
    {name = "Professional", points = 1400, abbr = '9'},
    {name = "Accomplished", points = 1500, abbr = 'A'},
    {name = "Great",        points = 1600, abbr = 'B'},
    {name = "Master",       points = 1700, abbr = 'C'},
    {name = "High Master",  points = 1800, abbr = 'D'},
    {name = "Grand Master", points = 1900, abbr = 'E'},
    {name = "Legendary",    points = 2000, abbr = 'U'},
    {name = "Legendary+1",  points = 2100, abbr = 'V'},
    {name = "Legendary+2",  points = 2200, abbr = 'W'},
    {name = "Legendary+3",  points = 2300, abbr = 'X'},
    {name = "Legendary+4",  points = 2400, abbr = 'Y'},
    {name = "Legendary+5",  points = 0,    abbr = 'Z'},
}

function check_nil(v, msg)
    if v == nil then
        qerror(msg ~= nil and msg or 'nil value')
    end
    return v
end

for id, col in pairs(SKILL_COLUMNS) do
    check_nil(tonumber(col.group), ('Column %i: Invalid group ID: %s'):format(id, col.group))
    check_nil(tonumber(col.color), ('Column %i: Invalid color ID: %s'):format(id, col.color))
    col.profession = check_nil(df.profession[col.profession], ('Column %i: Unrecognized profession: %s'):format(id, col.profession))
    col.labor = check_nil(df.unit_labor[col.labor], ('Column %i: Unrecognized labor: %s'):format(id, col.labor))
    col.skill = check_nil(df.job_skill[col.skill], ('Column %i: Unrecognized skill: %s'):format(id, col.skill))
    if col.label == nil or type(col.label) ~= 'string' or #tostring(col.label) ~= 2 then
        qerror(('Column %i: Invalid label: %s'):format(id, col.label))
    end
    if col.special == nil then col.special = false end
end

for id, lvl in pairs(SKILL_LEVELS) do
    check_nil(lvl.name, ('Skill level %i: Missing name'):format(id))
    check_nil(tonumber(lvl.points), ('Skill level %i: Invalid points: %s'):format(id, lvl.points))
    lvl.abbr = tostring(check_nil(lvl.abbr, ('Skill level %i: Missing abbreviation'):format(id))):sub(0, 1)
end
