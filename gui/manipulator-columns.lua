columns.name = Column{
    callback = function(unit)
        return dfhack.TranslateName(unit.name)
    end,
    default = true
}

return _ENV
