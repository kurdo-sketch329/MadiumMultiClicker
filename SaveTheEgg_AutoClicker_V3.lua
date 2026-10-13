-- Save The Egg - GUI Auto Clicker V3
-- Best effort: works only when targets are accessible GuiButtons.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')
local old = playerGui:FindFirstChild('SaveEggAutoV3')
if old then old:Destroy() end
local running, interval = false, 0.15
local gui = Instance.new('ScreenGui')
gui.Name = 'SaveEggAutoV3'
gui.ResetOnSpawn = false
gui.Parent = playerGui
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(290, 215)
frame.Position = UDim2.new(.5,-145,.4,0)
frame.BackgroundColor3 = Color3.fromRGB(34,32,48)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,10)
local function make(class, props)
 local obj=Instance.new(class)
 for k,v in pairs(props) do obj[k]=v end
 obj.Parent=frame
 return obj
end
make('TextLabel',{Size=UDim2.new(1,-20,0,32),Position=UDim2.fromOffset(10,5),Text='SAVE THE EGG | AUTO V3',TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,TextSize=17})
local toggle=make('TextButton',{Size=UDim2.new(1,-20,0,42),Position=UDim2.fromOffset(10,43),Text='START',TextSize=19,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(36,145,84)})
make('TextLabel',{Size=UDim2.fromOffset(100,30),Position=UDim2.fromOffset(10,95),Text='Intervall (s):',TextColor3=Color3.new(1,1,1),BackgroundTransparency=1})
local speed=make('TextBox',{Size=UDim2.fromOffset(145,30),Position=UDim2.fromOffset(120,95),Text='0.15',TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(65,62,85),ClearTextOnFocus=false})
local status=make('TextLabel',{Size=UDim2.new(1,-20,0,50),Position=UDim2.fromOffset(10,130),Text='Bereit | erkennt nur GUI-Buttons',TextWrapped=true,TextColor3=Color3.fromRGB(220,215,245),BackgroundTransparency=1})
local close=make('TextButton',{Size=UDim2.fromOffset(60,24),Position=UDim2.fromOffset(220,185),Text='X Close',TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(155,50,65)})
local function looksLikeTarget(button)
 if not button:IsA('GuiButton') or not button.Visible then return false end
 if not button:IsDescendantOf(playerGui) or button:IsDescendantOf(gui) then return false end
 local a=button.AbsoluteSize
 if a.X<15 or a.Y<15 then return false end
 local tokens={ 'tap','click','egg','hit','pop','circle' }
 local function match(s)
  s=string.lower(tostring(s or ''))
  for _,token in ipairs(tokens) do if string.find(s,token,1,true) then return true end end
  return false
 end
 if match(button.Name) or match(button.Text) then return true end
 for _,child in ipairs(button:GetDescendants()) do
  if (child:IsA('TextLabel') and match(child.Text)) or match(child.Name) then return true end
 end
 return false
end
local function activate(button)
 if type(firesignal)=='function' then
  local ok=pcall(function() firesignal(button.Activated) end)
  if ok then return true end
  ok=pcall(function() firesignal(button.MouseButton1Click) end)
  if ok then return true end
 end
 return false
end
toggle.MouseButton1Click:Connect(function()
 running=not running
 interval=math.clamp(tonumber(speed.Text) or .15,.05,5)
 toggle.Text=running and 'STOP' or 'START'
 if not running then status.Text='Gestoppt' end
end)
close.MouseButton1Click:Connect(function() running=false gui:Destroy() end)
task.spawn(function()
 while gui.Parent do
  if running then
   local found,clicked=0,0
   for _,item in ipairs(playerGui:GetDescendants()) do
    if not running then break end
    if looksLikeTarget(item) then
     found+=1
     if activate(item) then clicked+=1 end
    end
   end
   status.Text=string.format('Gefunden: %d | Ausgeloest: %d',found,clicked)
   task.wait(interval)
  else task.wait(.1) end
 end
end)
