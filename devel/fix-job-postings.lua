-- Fix broken job postings

posting_structs_known = pcall(function() return df.job:new().posting_index end)

world = df.global.world
print(dfhack.getDFHackVersion())

if posting_structs_known then
    print('Posting structs known')
    job_postings = 'job_postings'
    posting_index = 'posting_index'
    function is_dead(posting)
        return posting.flags.dead
    end
    function set_dead(posting)
        posting.flags.dead = true
    end
else
    print('Posting structs not known')
    job_postings = 'anon_1'
    posting_index = 'unk_v4020_1'
    function is_dead(posting)
        return posting.flags % 2 == 1
    end
    function set_dead(posting)
        posting.flags = -1
    end
end

dry_run = #{...} >= 1
count = 0
link = world.job_list
while link do
    job = link.item
    if job then
        for id, posting in pairs(world[job_postings]) do
            if posting.job == job and id ~= job[posting_index] and not is_dead(posting) then
                count = count + 1
                print(('Found extra job posting: Job %i: %s'):format(job.id, dfhack.job.getName(job)))
                if not dry_run then
                    set_dead(posting)
                end
            end
        end
    end
    link = link.next
end
print(tostring(count) .. ' issue(s) ' .. (dry_run and 'detected' or 'fixed'))

