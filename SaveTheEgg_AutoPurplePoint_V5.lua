-- Save The Egg | Auto Purple Point V5 (experimental)
-- Finds likely purple GUI buttons and moves the mouse to click them.
-- Requires executor mousemoveabs and mouse1click. Cannot inspect screen pixels.
local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
local previous=pg:FindFirstChild('SaveEggPurpleV5')
if previous then previous:Destroy() end
local gui=Instance.new('ScreenGui')
gui.Name='SaveEggPurpleV5';gui.ResetOnSpawn=false;gui.Parent=pg
local f=Instance.new('Frame');f.Size=UDim2.fromOffset(320,205);f.Position=UDim2.new(.5,-160,.35,-100);f.BackgroundColor3=Color3.fromRGB(30,25,44);f.Active=true;f.Draggable=true;f.Parent=gui
Instance.new('UICorner',f).CornerRadius=UDim.new(0,12)
local function text(t,y,h)
 local x=Instance.new('TextLabel');x.BackgroundTransparency=1;x.Size=UDim2.new(1,-24,0,h);x.Position=UDim2.fromOffset(12,y);x.Text=t;x.TextColor3=Color3.new(1,1,1);x.TextSize=14;x.Font=Enum.Font.Gotham;x.TextXAlignment=Enum.TextXAlignment.Left;x.Parent=f;return x
end
local title=text('SAVE THE EGG | PURPLE POINT V5',8,30);title.Font=Enum.Font.GothamBold
local toggle=Instance.new('TextButton');toggle.Size=UDim2.new(1,-24,0,42);toggle.Position=UDim2.fromOffset(12,46);toggle.Text='Auto Click Purple Point: OFF';toggle.TextSize=15;toggle.Font=Enum.Font.GothamBold;toggle.TextColor3=Color3.new(1,1,1);toggle.BackgroundColor3=Color3.fromRGB(94,67,132);toggle.Parent=f
Instance.new('UICorner',toggle).CornerRadius=UDim.new(0,8)
text('Delay (Sekunden, z.B. 0.15):',100,22)
local delay=Instance.new('TextBox');delay.Size=UDim2.fromOffset(90,27);delay.Position=UDim2.fromOffset(215,98);delay.Text='0.15';delay.TextColor3=Color3.new(1,1,1);delay.BackgroundColor3=Color3.fromRGB(65,57,83);delay.Parent=f
local status=text('Bereit | GUI-Erkennung experimentell',135,24);status.TextSize=12
local info=text('Bewegt Maus | benötigt mousemoveabs + mouse1click',165,25);info.TextSize=11
local close=Instance.new('TextButton');close.Size=UDim2.fromOffset(28,28);close.Position=UDim2.new(1,-33,0,6);close.Text='X';close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=Color3.fromRGB(160,55,75);close.Parent=f
local enabled=false;local dead=false
local lastClicked=setmetatable({},{__mode='k'})
local function visible(o)
 if not o:IsA('GuiButton') or not o.Visible or not o.Active or o:IsDescendantOf(gui) then return false end
 if o.AbsoluteSize.X<18 or o.AbsoluteSize.Y<18 then return false end
 local p=o.Parent
 while p and p~=pg do
  if p:IsA('GuiObject') and not p.Visible then return false end
  p=p.Parent
 end
 return true
end
local function purple(c)
 return c.B>c.R*1.12 and c.R>c.G*1.15 and c.B>0.25
end
local function candidate(o)
 if not visible(o) then return false end
 local name=(o.Name..' '..(o.Parent and o.Parent.Name or '')):lower()
 if name:find('shop') or name:find('buy') or name:find('robux') or name:find('close') or name:find('settings') then return false end
 if name:find('purple') or name:find('clickpoint') or name:find('tapcircle') or name:find('popup') then return true end
 -- Color-based heuristic: only small circular-looking GUI buttons.
 local s=o.AbsoluteSize
 if s.X>160 or s.Y>160 or math.abs(s.X-s.Y)>math.max(s.X,s.Y)*.25 then return false end
 if purple(o.BackgroundColor3) and o.BackgroundTransparency<.9 then return true end
 if o:IsA('ImageButton') and purple(o.ImageColor3) then return true end
 return false
end
local function click(o)
 local p=o.AbsolutePosition;local s=o.AbsoluteSize
 local x=math.floor(p.X+s.X/2);local y=math.floor(p.Y+s.Y/2)
 -- Coordinates are screen-relative; some executors use a different coordinate origin.
 mousemoveabs(x,y)
 task.wait(.045)
 mouse1click()
end
toggle.MouseButton1Click:Connect(function()
 enabled=not enabled
 toggle.Text='Auto Click Purple Point: '..(enabled and 'ON' or 'OFF')
 status.Text=enabled and 'Suche lila GUI-Punkte ...' or 'Gestoppt'
end)
close.MouseButton1Click:Connect(function() enabled=false;dead=true;gui:Destroy() end)
task.spawn(function()
 while not dead do
  if enabled then
   if type(mousemoveabs)~='function' or type(mouse1click)~='function' then
    status.Text='Executor: mousemoveabs oder mouse1click fehlt';enabled=false;toggle.Text='Auto Click Purple Point: OFF'
   else
    local count=0
    local cooldown=math.clamp(tonumber(delay.Text) or .15,.06,3)
    for _,o in ipairs(pg:GetDescendants()) do
     if dead or not enabled then break end
     if candidate(o) and (not lastClicked[o] or os.clock()-lastClicked[o]>1) then
      lastClicked[o]=os.clock();count=count+1
      local ok=pcall(click,o)
      if not ok then status.Text='Mausklick fehlgeschlagen';enabled=false;break end
      task.wait(cooldown)
     end
    end
    if enabled then status.Text=count>0 and ('Klickversuche: '..count) or 'Keine passenden GUI-Punkte gefunden' end
   end
  end
  task.wait(.12)
 end
end)
