-- Save The Egg: Tap marker diagnostic V7
-- Shows positions of GUI objects named Tap, Tap2, Tap3.
-- No clicks or mouse movement.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('TapMarkerV7')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'TapMarkerV7'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.Parent = pg
local colors = {Tap = Color3.fromRGB(255,70,70), Tap2 = Color3.fromRGB(70,255,120), Tap3 = Color3.fromRGB(80,170,255)}
local markers = {}
for name,color in pairs(colors) do
    local label = Instance.new('TextLabel')
    label.Name = 'Marker_'..name
    label.Size = UDim2.fromOffset(110,32)
    label.AnchorPoint = Vector2.new(0.5,0.5)
    label.BackgroundColor3 = color
    label.BackgroundTransparency = 0.2
    label.TextColor3 = Color3.fromRGB(0,0,0)
    label.TextScaled = true
    label.Text = name
    label.Visible = false
    label.ZIndex = 100
    label.Parent = gui
    markers[name] = label
end
local status = Instance.new('TextLabel')
status.Size = UDim2.fromOffset(320,36)
status.Position = UDim2.fromOffset(15,55)
status.BackgroundColor3 = Color3.fromRGB(20,20,30)
status.TextColor3 = Color3.new(1,1,1)
status.Text = 'Tap marker V7: scanning...'
status.ZIndex = 100
status.Parent = gui
local close = Instance.new('TextButton')
close.Size = UDim2.fromOffset(35,36)
close.Position = UDim2.fromOffset(335,55)
close.Text = 'X'
close.ZIndex = 101
close.Parent = gui
local active = true
close.MouseButton1Click:Connect(function() active = false; gui:Destroy() end)
local elapsed = 0
local connection
connection = RunService.Heartbeat:Connect(function(dt)
    if not active or not gui.Parent then connection:Disconnect(); return end
    elapsed = elapsed + dt
    if elapsed < 0.2 then return end
    elapsed = 0
    local found = {}
    for _,root in ipairs({pg, game:GetService('CoreGui')}) do
        for _,obj in ipairs(root:GetDescendants()) do
            if colors[obj.Name] and obj:IsA('GuiObject') and obj.Visible and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0 then
                -- Prefer first visible matching object; do not move mouse or click.
                if not found[obj.Name] then found[obj.Name] = obj end
            end
        end
    end
    local names = {}
    for name,mark in pairs(markers) do
        local obj = found[name]
        mark.Visible = obj ~= nil
        if obj then
            local p,s = obj.AbsolutePosition,obj.AbsoluteSize
            mark.Position = UDim2.fromOffset(p.X+s.X/2,p.Y+s.Y/2)
            table.insert(names,name)
        end
    end
    status.Text = 'Found: '..(#names > 0 and table.concat(names,', ') or 'none')
end)
