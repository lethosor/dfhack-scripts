local start = os.clock()
for i = 1, 5 do
    local stop = start + i
    local iters = 0
    while os.clock() < stop do
        iters = iters + 1
    end
    print(i, iters)
end
