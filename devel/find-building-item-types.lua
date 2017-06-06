function check(enum, search)
    for id, v in ipairs(df[enum]) do
        if v:lower():find(search) then
            print(enum .. ' ' .. v)
        end
    end
end
search = ({...})[1]:lower()
check('building_type', search)
check('item_type', search)
