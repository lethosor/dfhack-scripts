columns.stress = Column{
    callback = function(unit)
        return unit.status.current_soul and unit.status.current_soul.personality.stress_level or 0
    end,
    color = function(unit, stress)
        stress = tonumber(stress)
        if stress >= 500000 then return COLOR_LIGHTMAGENTA
        elseif stress >= 250000 then return COLOR_LIGHTRED
        elseif stress >= 100000 then return COLOR_YELLOW
        elseif stress >= 0 then return COLOR_GREEN
        else return COLOR_LIGHTGREEN
        end
    end,
    title = 'Stress',
    default = true,
    right_align = true
}

columns.name = Column{
    callback = function(unit)
        return dfhack.TranslateName(unit.name)
    end,
    color = COLOR_WHITE,
    title = 'Name',
    default = true,
    highlight = true
}

columns.profession = Column{
    callback = dfhack.units.getProfessionName,
    color = wrap(dfhack.units.getProfessionColor),
    title = 'Profession',
    default = true
}

return _ENV
