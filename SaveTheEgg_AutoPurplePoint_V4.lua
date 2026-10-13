-- Save The Egg - Auto Purple Point V4
-- Experimental GUI-button detection; does not move the mouse.
-- Requires an executor supporting firesignal for direct GUI event activation.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
local old = pg:FindFirstChild('SaveEggPurpleV4')
if old then old:Destroy() end
local gui = Instance.new('ScreenGui')
gui.Name = 'SaveEggPurpleV4'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = pg
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(310, 180)
frame.Position = UDim2.new(.5,-155,.35,-90)
frame.BackgroundColor3 = Color3.fromRGB(28,25,40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,12)
local function label(txt,y,h)
 local x=Instance.new('TextLabel');x.BackgroundTransparency=1;x.Position=UDim2.fromOffset(12,y);x.Size=UDim2.new(1,-24,0,h)
 x.Text=txt;x.TextColor3=Color3.new(1,1,1);x.TextSize=15;x.Font=Enum.Font.GothamBold;x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=frame;return x
end
label('SAVE THE EGG | PURPLE POINT',8,30)
local toggle=Instance.new('TextButton')
toggle.Size=UDim2.new(1,-24,0,44);toggle.Position=UDim2.fromOffset(12,46)
toggle.BackgroundColor3=Color3.fromRGB(83,60,111);toggle.TextColor3=Color3.new(1,1,1)
toggle.Font=Enum.Font.GothamBold;toggle.TextSize=16;toggle.Text='Auto Click Purple Point: OFF';toggle.Parent=frame
Instance.new('UICorner',toggle).CornerRadius=UDim.new(0,9)
local status=label('Bereit | Erkennung experimentell',101,23)
status.TextSize=12;status.Font=Enum.Font.Gotham
local hint=label('Keine Mausbewegung | nur GUI-Buttons',127,22)
hint.TextSize=12;hint.Font=Enum.Font.Gotham
local close=Instance.new('TextButton');close.Size=UDim2.fromOffset(28,28);close.Position=UDim2.new(1,-34,0,7)
close.Text='X';close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=Color3.fromRGB(140,48,65);close.Parent=frame
local enabled=false;local dead=false
local seen=setmetatable({}, {__mode='k'})
local function visible(o)
 if not o:IsA('GuiButton') or not o.Visible or not o.Active then return false end
 if o.AbsoluteSize.X < 18 or o.AbsoluteSize.Y < 18 then return false end
 local a=o.Parent
 while a and a~=pg do
  if a:IsA('GuiObject') and not a.Visible then return false end
  a=a.Parent
 end
 return true
end
local function isPurplePoint(o)
 -- Conservative heuristic: only buttons with explicit popup/click/point clues.
 -- Unknown image-only buttons cannot be reliably identified by their pixels in Lua.
 local words=(o.Name..' '..(o:IsA('TextButton') and o.Text or '')):lower()
 local parent=o.Parent
 if parent then words=words..' '..parent.Name:lower() end
 local relevant=(words:find('purple') or words:find('popup') or words:find('clickpoint') or words:find('tapcircle'))
 if not relevant then return false end
 local blocked={'shop','rebirth','index','purchase','buy','robux','speedboost','close'}
 for _,s in ipairs(blocked) do if words:find(s) then return false end end
 return true
end
local function trigger(o)
 if type(firesignal)~='function' then status.Text='firesignal fehlt: direktes Klicken nicht möglich';return false end
 local ok=pcall(function() firesignal(o.Activated) end)
 if not ok then ok=pcall(function() firesignal(o.MouseButton1Click) end) end
 if not ok then status.Text='GUI-Event konnte nicht ausgelöst werden' end
 return ok
end
toggle.MouseButton1Click:Connect(function()
 enabled=not enabled
 toggle.Text='Auto Click Purple Point: '..(enabled and 'ON' or 'OFF')
 toggle.BackgroundColor3=enabled and Color3.fromRGB(75,145,96) or Color3.fromRGB(83,60,111)
 status.Text=enabled and 'Suche passende GUI-Kreise ...' or 'Gestoppt'
end)
close.MouseButton1Click:Connect(function() dead=true;enabled=false;gui:Destroy() end)
task.spawn(function()
 while not dead do
  if enabled then
   local count=0
   for _,o in ipairs(pg:GetDescendants()) do
    if dead or not enabled then break end
    if o~=toggle and o~=close and visible(o) and isPurplePoint(o) then
     count=count+1
     local t=os.clock()
     if not seen[o] or t-seen[o]>0.6 then
      seen[o]=t
      if trigger(o) then status.Text='Passenden Button ausgelöst' end
     end
    end
   end
   if count==0 then status.Text='Kein eindeutig erkennbarer Purple-Button' end
  end
  task.wait(.12)
 end
end)
