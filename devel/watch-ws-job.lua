local cur = dfhack.gui.getSelectedJob()
function desc(job)
    return ('Job %i: %s'):format(job.id, dfhack.job.getName(job))
end
if cur then
    job = cur
    print('set to ' .. desc(job))
elseif job then
    print(desc(job))
else
    qerror('no job selected')
end

function findJob(j)
    local link = df.global.world.job_list
    while link do
        if j == link.item then return true end
        link = link.next
    end
    return false
end

last = last or {}

function reset()
    job = nil
    last = {}
end

function tick()
    ticking = true
    dfhack.timeout(1, 'ticks', tick)
    if job then
        if not findJob(job) then
            dfhack.printerr('Job deleted!')
            reset()
            return
        end
        local text = ''
        local function tprint(s)
            text = text .. s .. '\n'
        end
        tprint(desc(job))
        local workers = {}
        for _, ref in pairs(job.general_refs) do
            if df.general_ref_unit_workerst:is_instance(ref) then
                local u = df.unit.find(ref.unit_id)
                table.insert(workers, ('%i: %s'):format(u.id, dfhack.TranslateName(u.name)))
            end
        end
        tprint(('%i workers: %s'):format(#workers, table.concat(workers, ', ')))
        local postings = {}
        for idx, p in pairs(df.global.world.job_postings) do
            if p.job == job then
                table.insert(postings, tostring(idx) .. (p.flags.dead and ' (dead)' or ''))
            end
        end
        tprint(('%i postings: %s'):format(#postings, table.concat(postings, ', ')))
        tprint('posting_index: ' .. job.posting_index)
        if text ~= last.text then
            last.text = text
            print(text)
        end
    end
end

if not ticking then tick() end
