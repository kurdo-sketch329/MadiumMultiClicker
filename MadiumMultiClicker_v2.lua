-- Madium MultiClicker v2 - visible selectable click targets
-- Executor requires mouse1click() and mousemoveabs(x,y).
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local previous = pg:FindFirstChild('MadiumMultiClickerV2')
if previous then previous:Destroy() end
local points, markers = {}, {}
local running, picking, closed = false, false, false
local cps = 5
local gui = Instance.new('ScreenGui')
gui.Name = 'MadiumMultiClickerV2'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = pg
local function round(parent, radius)
 local corner = Instance.new('UICorner')
 corner.CornerRadius = UDim.new(0, radius)
 corner.Parent = parent
end
local panel = Instance.new('Frame')
panel.Size = UDim2.fromOffset(290, 295)
panel.Position = UDim2.new(0.5,-145,0.5,-148)
panel.BackgroundColor3 = Color3.fromRGB(24,27,39)
panel.Active = true
panel.Draggable = true
panel.Parent = gui
round(panel,12)
local function label(text,y,height)
 local t = Instance.new('TextLabel')
 t.Position = UDim2.fromOffset(12,y)
 t.Size = UDim2.new(1,-24,0,height or 24)
 t.BackgroundTransparency = 1
 t.Text = text
 t.TextColor3 = Color3.fromRGB(245,245,250)
 t.Font = Enum.Font.GothamBold
 t.TextSize = 14
 t.TextWrapped = true
 t.Parent = panel
 return t
end
label('MADIUM MULTI CLICKER',8,28)
local function button(text,y,color)
 local b = Instance.new('TextButton')
 b.Position = UDim2.fromOffset(12,y)
 b.Size = UDim2.new(1,-24,0,36)
 b.BackgroundColor3 = color
 b.TextColor3 = Color3.new(1,1,1)
 b.Font = Enum.Font.GothamBold
 b.TextSize = 15
 b.Text = text
 b.Parent = panel
 round(b,8)
 return b
end
local add = button('+ PUNKT HINZUFUEGEN',45,Color3.fromRGB(45,111,212))
local remove = button('LETZTEN PUNKT LOESCHEN',86,Color3.fromRGB(103,73,136))
local speedLabel = label('Klicks pro Sekunde (CPS):',131,22)
local speedBox = Instance.new('TextBox')
speedBox.Position = UDim2.fromOffset(208,131)
speedBox.Size = UDim2.fromOffset(65,26)
speedBox.BackgroundColor3 = Color3.fromRGB(53,58,76)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Text = '5'
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 15
speedBox.ClearTextOnFocus = false
speedBox.Parent = panel
round(speedBox,6)
local start = button('START',169,Color3.fromRGB(34,151,91))
local clear = button('ALLE PUNKTE LOESCHEN',211,Color3.fromRGB(154,61,66))
local status = label('0 Punkte | Bereit',253,34)
local x = Instance.new('TextButton')
x.Size = UDim2.fromOffset(27,27)
x.Position = UDim2.new(1,-32,0,6)
x.Text = 'X'
x.Font = Enum.Font.GothamBold
x.TextColor3 = Color3.new(1,1,1)
x.BackgroundColor3 = Color3.fromRGB(150,50,57)
x.Parent = panel
round(x,6)
local function setStatus(message)
 if not closed then status.Text = tostring(#points)..' Punkte | '..message end
end
local function addPoint(position)
 local p = Vector2.new(math.floor(position.X),math.floor(position.Y))
 table.insert(points,p)
 local dot = Instance.new('Frame')
 dot.Name = 'ClickPoint'..#points
 dot.Size = UDim2.fromOffset(18,18)
 dot.AnchorPoint = Vector2.new(0.5,0.5)
 dot.Position = UDim2.fromOffset(p.X,p.Y)
 dot.BackgroundColor3 = Color3.fromRGB(255,65,75)
 dot.BorderSizePixel = 0
 dot.ZIndex = 10
 dot.Parent = gui
 round(dot,9)
 local num = Instance.new('TextLabel')
 num.Size = UDim2.fromScale(1,1)
 num.BackgroundTransparency = 1
 num.Text = tostring(#points)
 num.TextColor3 = Color3.new(1,1,1)
 num.Font = Enum.Font.GothamBold
 num.TextSize = 12
 num.ZIndex = 11
 num.Parent = dot
 table.insert(markers,dot)
 setStatus('Punkt hinzugefuegt')
end
local pickConnection
local function cancelPicking()
 picking = false
 if pickConnection then pickConnection:Disconnect(); pickConnection = nil end
 add.Text = '+ PUNKT HINZUFUEGEN'
end
add.MouseButton1Click:Connect(function()
 if picking then cancelPicking(); setStatus('Auswahl abgebrochen'); return end
 picking = true
 add.Text = 'ABBRECHEN'
 setStatus('Jetzt ins Spiel klicken')
 -- Defer listener so the button click itself is never recorded.
 task.defer(function()
  if not picking or closed then return end
  pickConnection = UIS.InputBegan:Connect(function(input, processed)
   if not picking or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
   -- Ignore clicks on the menu, including Cancel.
   local mouse = UIS:GetMouseLocation()
   local pos = panel.AbsolutePosition
   local size = panel.AbsoluteSize
   if mouse.X >= pos.X and mouse.X <= pos.X+size.X and mouse.Y >= pos.Y and mouse.Y <= pos.Y+size.Y then return end
   cancelPicking()
   addPoint(mouse)
  end)
 end)
end)
remove.MouseButton1Click:Connect(function()
 if #points == 0 then setStatus('Keine Punkte vorhanden'); return end
 table.remove(points)
 local dot = table.remove(markers)
 if dot then dot:Destroy() end
 setStatus('Letzten Punkt geloescht')
end)
clear.MouseButton1Click:Connect(function()
 table.clear(points)
 for _,dot in ipairs(markers) do dot:Destroy() end
 table.clear(markers)
 setStatus('Alle Punkte geloescht')
end)
local function stop()
 running = false
 start.Text = 'START'
 start.BackgroundColor3 = Color3.fromRGB(34,151,91)
end
start.MouseButton1Click:Connect(function()
 if running then stop(); setStatus('Gestoppt'); return end
 if #points == 0 then setStatus('Erst Punkte hinzufuegen'); return end
 if type(mouse1click) ~= 'function' or type(mousemoveabs) ~= 'function' then
  setStatus('mouse1click/mousemoveabs fehlen')
  return
 end
 cps = math.clamp(tonumber(speedBox.Text) or 5,1,30)
 speedBox.Text = tostring(cps)
 running = true
 start.Text = 'STOP'
 start.BackgroundColor3 = Color3.fromRGB(191,66,74)
 setStatus('Aktiv')
 task.spawn(function()
  local i = 1
  while running and not closed do
   if #points == 0 then stop(); setStatus('Keine Punkte'); break end
   if i > #points then i = 1 end
   local point = points[i]
   if point then
    local ok, err = pcall(function()
     mousemoveabs(point.X,point.Y)
     task.wait(0.03)
     if running and not closed then mouse1click() end
    end)
    if not ok then stop(); setStatus('Klickfehler: '..tostring(err):sub(1,45)); break end
   end
   i = i + 1
   task.wait(math.max(0.01,1/cps))
  end
 end)
end)
x.MouseButton1Click:Connect(function()
 closed = true
 stop()
 cancelPicking()
 gui:Destroy()
end)
