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
    color = dfhack.units.getProfessionColor,
    title = 'Profession',
    default = true
}

return _ENV
