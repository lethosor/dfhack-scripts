j = df.global.world.job_list
types = {}
while j.next do
    j = j.next
    t = df.job_type[j.item.job_type]
    types[t] = (types[t] or 0) + 1
end
printall(types)
