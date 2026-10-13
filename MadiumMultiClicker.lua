-- Madium MultiClicker - Roblox executor UI
-- Requires executor support for mouse1click and mousemoveabs.
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('MadiumMultiClicker')
if old then old:Destroy() end
local points, running, closed, cps = {}, false, false, 5
local gui = Instance.new('ScreenGui')
gui.Name = 'MadiumMultiClicker'
gui.ResetOnSpawn = false
gui.Parent = pg
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(300, 320)
frame.Position = UDim2.new(.5, -150, .5, -160)
frame.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 12)
local function makeButton(text, y, color)
    local b = Instance.new('TextButton')
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.fromOffset(10, y)
    b.Text = text
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = color
    b.Parent = frame
    Instance.new('UICorner', b).CornerRadius = UDim.new(0, 8)
    return b
end
local title = Instance.new('TextLabel')
title.Size = UDim2.new(1, -55, 0, 38)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = 'MADIUM MULTI CLICKER'
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame
local close = Instance.new('TextButton')
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -37, 0, 4)
close.Text = 'X'
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(180,55,60)
close.Parent = frame
local add = makeButton('F7: Position unter Maus speichern', 48, Color3.fromRGB(55,110,200))
local clear = makeButton('Alle Positionen loeschen', 92, Color3.fromRGB(120,80,145))
local speed = Instance.new('TextBox')
speed.Size = UDim2.new(1, -20, 0, 36)
speed.Position = UDim2.fromOffset(10, 138)
speed.Text = '5'
speed.PlaceholderText = 'Klicks pro Sekunde (1-30)'
speed.TextColor3 = Color3.new(1,1,1)
speed.BackgroundColor3 = Color3.fromRGB(55,57,72)
speed.Parent = frame
local start = makeButton('START / F6', 186, Color3.fromRGB(40,155,85))
local status = Instance.new('TextLabel')
status.Size = UDim2.new(1, -20, 0, 75)
status.Position = UDim2.fromOffset(10, 231)
status.TextWrapped = true
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,1,1)
status.Text = '0 Positionen. F7 ueber Spielstelle druecken.'
status.Parent = frame
local function savePosition()
    local p = UIS:GetMouseLocation()
    table.insert(points, Vector2.new(p.X, p.Y))
    status.Text = #points .. ' Position(en) gespeichert.'
end
-- Clicking the button would save its own position, so F7 is the actual picker.
add.MouseButton1Click:Connect(function()
    status.Text = 'Maus auf Ziel bewegen und F7 druecken.'
end)
clear.MouseButton1Click:Connect(function()
    table.clear(points)
    status.Text = 'Alle Positionen geloescht.'
end)
local function toggle()
    if running then
        running = false
        start.Text = 'START / F6'
        return
    end
    if #points == 0 then
        status.Text = 'Zuerst mit F7 Positionen speichern.'
        return
    end
    if type(mouse1click) ~= 'function' or type(mousemoveabs) ~= 'function' then
        status.Text = 'Executor braucht mouse1click() und mousemoveabs().'
        return
    end
    cps = math.clamp(tonumber(speed.Text) or 5, 1, 30)
    running = true
    start.Text = 'STOP / F6'
    task.spawn(function()
        while running and not closed do
            for _, p in ipairs(points) do
                if not running or closed then break end
                local ok, err = pcall(function()
                    mousemoveabs(p.X, p.Y)
                    task.wait(.04)
                    mouse1click()
                end)
                if not ok then
                    running = false
                    start.Text = 'START / F6'
                    status.Text = 'Klickfehler: ' .. tostring(err)
                    break
                end
                task.wait(1 / cps)
            end
        end
    end)
end
start.MouseButton1Click:Connect(toggle)
local connection
connection = UIS.InputBegan:Connect(function(input, processed)
    if processed or closed then return end
    if input.KeyCode == Enum.KeyCode.F7 then savePosition() end
    if input.KeyCode == Enum.KeyCode.F6 then toggle() end
end)
close.MouseButton1Click:Connect(function()
    running, closed = false, true
    connection:Disconnect()
    gui:Destroy()
end)
