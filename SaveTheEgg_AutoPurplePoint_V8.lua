    t.Parent = frame
    return t
end
label('SAVE THE EGG | PURPLE POINT V8',7,28)
local toggle = Instance.new('TextButton')
toggle.Size = UDim2.new(1,-20,0,40)
toggle.Position = UDim2.fromOffset(10,42)
toggle.Text = 'Auto Click Purple Point: OFF'
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(110,67,175)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Parent = frame
Instance.new('UICorner',toggle).CornerRadius = UDim.new(0,7)
local status = label('Bereit. Erkennt Tap2.',91,43)
local close = Instance.new('TextButton')
close.Size = UDim2.fromOffset(35,25)
close.Position = UDim2.new(1,-39,0,3)
close.Text = 'X'
close.BackgroundColor3 = Color3.fromRGB(170,55,75)
close.TextColor3 = Color3.new(1,1,1)
close.Parent = frame
local enabled, closed = false, false
local clicked = {}
local function visible(o)
    if not o:IsA('GuiObject') then return false end
    if o.AbsoluteSize.X < 5 or o.AbsoluteSize.Y < 5 then return false end
    local p = o
    while p and p ~= pg do
        if p:IsA('GuiObject') and not p.Visible then return false end
        if p:IsA('ScreenGui') and not p.Enabled then return false end
        p = p.Parent
    end
    return true
end
local function findTargets()
    local result = {}
    for _,obj in ipairs(pg:GetDescendants()) do
        if obj.Name == 'Tap2' and visible(obj) and not obj:IsDescendantOf(gui) then
            table.insert(result,obj)
        end
    end
    return result
end
toggle.MouseButton1Click:Connect(function()
    if type(mousemoveabs) ~= 'function' or type(mouse1click) ~= 'function' then
        status.Text = 'Madium braucht mousemoveabs + mouse1click.'
        return
    end
    enabled = not enabled
    toggle.Text = 'Auto Click Purple Point: '..(enabled and 'ON' or 'OFF')
    status.Text = enabled and 'Suche nach Tap2 ...' or 'Pausiert.'
    if not enabled then table.clear(clicked) end
end)
close.MouseButton1Click:Connect(function()
    enabled = false
    closed = true
    gui:Destroy()
end)
task.spawn(function()
    while not closed do
        if enabled then
            local targets = findTargets()
            local live = {}
            for _,obj in ipairs(targets) do
                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize
                local x = math.floor(pos.X + size.X/2)
                local y = math.floor(pos.Y + size.Y/2)
                local signature = tostring(x)..':'..tostring(y)
                live[obj] = true
                if clicked[obj] ~= signature then
                    -- GUI AbsolutePosition uses screen coordinates. Executor coordinate
                    -- conventions can differ, so alignment may need adjustment.
                    local ok,err = pcall(function()
                        mousemoveabs(x,y)
                        task.wait(.045)
                        mouse1click()
                    end)
                    if ok then
                        clicked[obj] = signature
                        status.Text = 'Tap2 geklickt: '..x..', '..y
                    else
                        status.Text = 'Klickfehler: '..tostring(err):sub(1,55)
                    end
                    break
                end
            end
            for obj in pairs(clicked) do
                if not live[obj] then clicked[obj] = nil end
            end
            if #targets == 0 then status.Text = 'Warte auf sichtbaren Tap2 ...' end
        end
        task.wait(.08)
    end
end)
