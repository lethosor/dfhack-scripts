s = df.global.gview.view
depth = 0
while s do
    print((' '):rep(depth) .. tostring(s))
    s = s.child
    depth = depth + 1
end
