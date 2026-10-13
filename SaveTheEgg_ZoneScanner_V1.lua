-- SAVE THE EGG | ZONE SCANNER V1 | MONO MENU
-- Client-side tool; TP can be rejected by the Roblox server.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
if _G.SaveEggZoneStop then pcall(_G.SaveEggZoneStop) end
for _, name in ipairs({"SaveEggZoneScannerV1", "SaveEggZoneScannerV2"}) do
 local old = pg:FindFirstChild(name)
 if old then old:Destroy() end
end
local active, autoClick, busy, autoEgg = true, false, false, false
local antiAfk = false
local idleConnection = nil
local clickedPurple = {}
local PURPLE_Y_OFFSET = 60
local PURPLE_HOLD_TIME = 1
local PURPLE_DELAY = 0.08
local zoneY, zoneCenter = nil, nil
local maxHorizontal, heightTolerance = 1200, 18
local gui = Instance.new("ScreenGui")
gui.Name = "SaveEggZoneScannerV1"
gui.ResetOnSpawn = false
gui.Parent = pg
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(410, 360)
frame.Position = UDim2.new(.5,-205,.5,-180)
frame.BackgroundColor3 = Color3.fromRGB(12,12,13)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UIStroke",frame).Color = Color3.fromRGB(210,210,210)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-55,0,34)
title.Position = UDim2.fromOffset(15,5)
title.BackgroundTransparency = 1
title.Text = "SAVE THE EGG  //  V1"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.Code
title.TextSize = 19
title.TextColor3 = Color3.fromRGB(245,245,245)
title.Parent = frame
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30,29)
close.Position = UDim2.new(1,-37,0,7)
close.Text = "X"
close.Font = Enum.Font.Code
close.TextSize = 19
close.BackgroundColor3 = Color3.fromRGB(32,32,34)
close.TextColor3 = Color3.new(1,1,1)
close.Parent = frame
local function button(text, parent, y, height)
 local o = Instance.new("TextButton")
 o.Size = UDim2.new(1,-24,0,height or 37)
 o.Position = UDim2.fromOffset(12,y)
 o.Text = text
 o.Font = Enum.Font.Code
 o.TextSize = 16
 o.BackgroundColor3 = Color3.fromRGB(29,29,31)
 o.TextColor3 = Color3.fromRGB(248,248,248)
 o.AutoButtonColor = false
 o.Parent = parent
 local st = Instance.new("UIStroke",o)
 st.Color = Color3.fromRGB(105,105,105)
 o.MouseEnter:Connect(function()
  TweenService:Create(o,TweenInfo.new(.14),{BackgroundColor3=Color3.fromRGB(85,85,85)}):Play()
 end)
 o.MouseLeave:Connect(function()
  TweenService:Create(o,TweenInfo.new(.14),{BackgroundColor3=Color3.fromRGB(29,29,31)}):Play()
 end)
 return o
end
local tabRow = Instance.new("Frame")
tabRow.Size = UDim2.new(1,-24,0,35)
tabRow.Position = UDim2.fromOffset(12,46)
tabRow.BackgroundTransparency = 1
tabRow.Parent = frame
local function tab(name,x)
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(.5,-3,1,0)
 b.Position = UDim2.new(x, x==0 and 0 or 3,0,0)
 b.Text = name
 b.Font = Enum.Font.Code
 b.TextSize = 15
 b.TextColor3 = Color3.new(1,1,1)
 b.BackgroundColor3 = Color3.fromRGB(35,35,37)
 b.Parent = tabRow
 Instance.new("UIStroke",b).Color = Color3.fromRGB(140,140,140)
 return b
end
local eggTab = tab("EASY GET EGG",0)
local trainTab = tab("AUTO TRAIN",.5)
local eggPage = Instance.new("Frame")
eggPage.Size = UDim2.new(1,-10,0,190)
eggPage.Position = UDim2.fromOffset(5,91)
eggPage.BackgroundTransparency = 1
eggPage.Parent = frame
local trainPage = eggPage:Clone()
trainPage.Name = "TrainPage"
trainPage.Visible = false
trainPage.Parent = frame
for _,o in ipairs(trainPage:GetChildren()) do o:Destroy() end
local zoneBtn = button("[ 1 ]  BEREICH HIER FESTLEGEN",eggPage,5)
local scanBtn = button("[ 2 ]  BESTES EI SCANNEN",eggPage,49)
local tpBtn = button("[ 3 ]  TP BEST EGG",eggPage,93)
local autoBtn = button("AUTO BEST EGG: AUS",eggPage,137)
local purpleBtn = button("AUTO CLICK LILA PUNKTE: AUS",trainPage,5)
local afkBtn = button("ANTI-AFK: AUS",trainPage,49)
local trainInfo = Instance.new("TextLabel")
trainInfo.Size = UDim2.new(1,-24,0,88)
trainInfo.Position = UDim2.fromOffset(12,98)
trainInfo.BackgroundTransparency = 1
trainInfo.Text = "Lila Punkte: automatisches Training.\nAnti-AFK: simuliert Eingabe, wenn Roblox dich als inaktiv erkennt."
trainInfo.TextWrapped = true
trainInfo.Font = Enum.Font.Code
trainInfo.TextSize = 15
trainInfo.TextColor3 = Color3.fromRGB(210,210,210)
trainInfo.Parent = trainPage
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,-30,0,65)
info.Position = UDim2.fromOffset(15,287)
info.BackgroundColor3 = Color3.fromRGB(20,20,22)
info.TextColor3 = Color3.fromRGB(226,226,226)
info.Font = Enum.Font.Code
info.TextSize = 13
info.TextWrapped = true
info.Text = "Bereich festlegen, dann bestes Ei suchen."
info.Parent = frame
local function showPage(egg)
 eggPage.Visible = egg
 trainPage.Visible = not egg
 eggTab.BackgroundColor3 = egg and Color3.fromRGB(100,100,103) or Color3.fromRGB(35,35,37)
 trainTab.BackgroundColor3 = (not egg) and Color3.fromRGB(100,100,103) or Color3.fromRGB(35,35,37)
end
eggTab.MouseButton1Click:Connect(function() showPage(true) end)
trainTab.MouseButton1Click:Connect(function() showPage(false) end)
showPage(true)
local function stop()
 active=false
 autoClick=false
 autoEgg=false
 antiAfk=false
 if idleConnection then idleConnection:Disconnect(); idleConnection=nil end
 if gui.Parent then gui:Destroy() end
end
_G.SaveEggZoneStop = stop
close.MouseButton1Click:Connect(stop)
frame.Position = UDim2.new(.5,-205,.5,-280)
TweenService:Create(frame,TweenInfo.new(.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(.5,-205,.5,-180)}):Play()
local function rootPart()
 local c=player.Character
 return c,c and c:FindFirstChild('HumanoidRootPart')
end
local mult={K=1e3,M=1e6,B=1e9,T=1e12,Q=1e15}
local function number(v)
 if type(v)~='string' then return nil end
 v=v:gsub('%s+',''):gsub(',','')
 local raw,suf=v:match('^([%d%.]+)([kKmMbBtTqQ]?)$')
 if not raw then return nil end
 local n=tonumber(raw)
 if not n then return nil end
 return n*(mult[suf:upper()] or 1)
end
local function fmt(n)
 if not n then return '?' end
 if n>=1e12 then return string.format('%.2fT',n/1e12) end
 if n>=1e9 then return string.format('%.2fB',n/1e9) end
 if n>=1e6 then return string.format('%.2fM',n/1e6) end
 if n>=1e3 then return string.format('%.1fK',n/1e3) end
 return tostring(math.floor(n))
end
local function eggRootFromPrompt(prompt)
 local node=prompt.Parent
 for i=1,10 do
  if not node or node==workspace then break end
  if node.Name=='EggRoot' then return node end
  node=node.Parent
 end
 return nil
end
local function eggPosition(root,prompt)
 -- Position des Pickup-Prompts bevorzugen statt Model-Pivot
 local par=prompt.Parent
 if par:IsA('Attachment') then return par.WorldPosition end
 if par:IsA('BasePart') then return par.Position end
 if root:IsA('Model') then
  local part=root:FindFirstChildWhichIsA('BasePart',true)
  if part then return part.Position end
  return root:GetPivot().Position
 end
 if root:IsA('BasePart') then return root.Position end
 return nil
end
local function readLuck(root)
 local badge=root:FindFirstChild('WeightBadge',true)
 if not badge then return nil end
 local luck=badge:FindFirstChild('Luck',true)
 if not luck then return nil end
 if luck:IsA('TextLabel') or luck:IsA('TextButton') then return number(luck.Text) end
 for _,x in ipairs(luck:GetDescendants()) do
  if x:IsA('TextLabel') or x:IsA('TextButton') then
   local v=number(x.Text);if v then return v end
  end
 end
 return nil
end
local function loadedEggs()
 local arr={};local seen={};local unparsed=0
 for _,p in ipairs(workspace:GetDescendants()) do
  if p:IsA('ProximityPrompt') and p.Enabled then
   local action=(p.ActionText or ''):lower()
   local name=(p.ObjectText or ''):lower()
   if (action:find('pick',1,true) or action:find('collect',1,true)) and name:find('egg',1,true) then
    local root=eggRootFromPrompt(p)
    if root and not seen[root] then
     seen[root]=true
     local pos=eggPosition(root,p)
     local luck=readLuck(root)
     if pos and luck then table.insert(arr,{name=p.ObjectText,position=pos,luck=luck,prompt=p,root=root})
     else unparsed=unparsed+1 end
    end
   end
  end
 end
 return arr,unparsed
end
local function setZone()
 local _,r=rootPart()
 if not r then info.Text='Charakter noch nicht bereit.';return end
 local arr=loadedEggs()
 if #arr==0 then info.Text='Noch keine Eier geladen. Geh naeher zu einem Ei.';return end
 -- Die naechste Eierhoehe ist meist zuverlaessiger als der Boden-Raycast.
 local nearest=nil;local nd=math.huge
 for _,egg in ipairs(arr) do
  local d=(egg.position-r.Position).Magnitude
  if d<nd then nd=d;nearest=egg end
 end
 if not nearest then
  info.Text='Kein geladenes Ei gefunden.'
  return
 end
 zoneY=nearest.position.Y
 -- Zone um das Anker-Ei statt die aktuelle Spielerposition zentrieren.
 zoneCenter=Vector3.new(nearest.position.X,0,nearest.position.Z)
 info.Text='Bereich gesetzt bei '..nearest.name..' (Abstand '..math.floor(nd)..' Studs). Jetzt Scan druecken.'
 print('[ZONE] Anchor '..nearest.name..' | Hoehe '..zoneY..' | Suchradius '..maxHorizontal)
end
local function candidates()
 local eggs,unparsed=loadedEggs()
 if not zoneY then return {},#eggs,unparsed,'Bereich noch nicht festgelegt.' end
 local usable={}; local wrongLevel=0;local far=0
 for _,e in ipairs(eggs) do
  local dist=(Vector3.new(e.position.X,0,e.position.Z)-zoneCenter).Magnitude
  if math.abs(e.position.Y-zoneY)>heightTolerance then wrongLevel=wrongLevel+1
  elseif dist>maxHorizontal then far=far+1
  else table.insert(usable,e) end
 end
 table.sort(usable,function(a,b)
  if a.luck==b.luck then return (a.position-zoneCenter).Magnitude<(b.position-zoneCenter).Magnitude end
  return a.luck>b.luck
 end)
 local summary=string.format('Geladen %d | Bereich %d | andere Hoehe %d | weit %d | Luck unklar %d',#eggs,#usable,wrongLevel,far,unparsed)
 return usable,#eggs,unparsed,summary
end
local function scan()
 local arr,_,_,summary=candidates()
 print('[ZONE SCAN] '..summary)
 for i,e in ipairs(arr) do
  if i>20 then break end
  print(string.format('[ZONE] #%d: %s | Luck %s | Y %.1f | %s',i,e.name,fmt(e.luck),e.position.Y,e.root:GetFullName()))
 end
 if #arr==0 then info.Text=summary..'\nKein passendes Ei: Bereich neu setzen oder Eier laden.';return nil end
 info.Text=summary..'\nBESTES: '..arr[1].name..' | Luck '..fmt(arr[1].luck)
 return arr[1]
end
local function teleportTo(cframe,desc)
 local char,root=rootPart()
 if not root then info.Text='Charakter nicht bereit.';return false end
 local hum=char:FindFirstChildOfClass('Humanoid')
 local wasSeated=hum and hum.Sit
 -- Bei Reittieren bewegt sich die eigene Figur moeglicherweise nicht unabhaengig vom Pet.
 root.AssemblyLinearVelocity=Vector3.zero
 root.AssemblyAngularVelocity=Vector3.zero
 char:PivotTo(cframe)
 task.wait(1.2)
 local afterRoot=char:FindFirstChild('HumanoidRootPart')
 if not afterRoot then info.Text='Teleport: Charakter neu geladen.';return false end
 local errorDist=(afterRoot.Position-cframe.Position).Magnitude
 if errorDist>18 then
  info.Text=desc..': zurueckgesetzt/blockiert ('..math.floor(errorDist)..' Studs).'
  print('[ZONE TP]',desc,'Abweichung',errorDist,'Sitzt:',wasSeated)
  return false
 end
 info.Text=desc..': Position erreicht (clientseitig).'
 return true
end
local function eggTP(e)
 if not e then return false end
 local char,root=rootPart();if not root then return false end
 -- Landen neben Prompt, ueber dem Fussboden. Keine falsche Weltposition garantieren.
 local offset=Vector3.new(3,4,0)
 local target=e.position+offset
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances={char,e.root}
 local hit=workspace:Raycast(target+Vector3.new(0,9,0),Vector3.new(0,-40,0),params)
 if hit and hit.Normal.Y>.65 and hit.Position.Y<=e.position.Y+4 then target=hit.Position+Vector3.new(0,4.2,0) end
 return teleportTo(CFrame.new(target,e.position),'Ei-Teleport')
end
local function purpleVisible(obj)
 if not obj:IsA('GuiObject') then return false end
 if obj.AbsoluteSize.X < 5 or obj.AbsoluteSize.Y < 5 then return false end
 local current=obj
 while current and current~=pg do
  if current:IsA('GuiObject') and not current.Visible then return false end
  if current:IsA('ScreenGui') and not current.Enabled then return false end
  current=current.Parent
 end
 return true
end
local function purpleTarget(obj)
 local parent=obj.Parent
 if parent then
  for _,name in ipairs({'Tap','Hit'}) do
   local child=parent:FindFirstChild(name)
   if child and purpleVisible(child) then return child end
  end
 end
 return obj
end
local function purpleClick(x,y)
 if type(mousemoveabs)=='function' then mousemoveabs(x,y) end
 task.wait(.15)
 if not active or not autoClick then return end
 VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
 task.wait(PURPLE_HOLD_TIME)
 VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
end
-- Nur bei Roblox-Idle ein kurzes Eingabesignal senden.
-- Dies kann je nach Spiel/Executor blockiert werden; keine Garantie gegen Kick.
afkBtn.MouseButton1Click:Connect(function()
 antiAfk = not antiAfk
 afkBtn.Text = antiAfk and "ANTI-AFK: AN" or "ANTI-AFK: AUS"
 if idleConnection then idleConnection:Disconnect(); idleConnection=nil end
 if antiAfk then
  idleConnection = player.Idled:Connect(function()
   if not active or not antiAfk then return end
   local ok,err = pcall(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
   end)
   if not ok then
    warn("[ANTI-AFK] "..tostring(err))
    info.Text="Anti-AFK Fehler: "..tostring(err):sub(1,70)
   end
  end)
  info.Text="Anti-AFK AN. Reagiert auf das Roblox-Idle-Signal (keine Garantie)."
 else
  info.Text="Anti-AFK AUS."
 end
end)

purpleBtn.MouseButton1Click:Connect(function()
 autoClick = not autoClick
 table.clear(clickedPurple)
 purpleBtn.Text = autoClick and "AUTO CLICK LILA PUNKTE: AN" or "AUTO CLICK LILA PUNKTE: AUS"
 info.Text = autoClick and "Auto Train: Suche Lila Punkte ..." or "Auto Train: Pausiert"
end)
task.spawn(function()
 while active do
  if autoClick then
   local visibleNow = {}
   for _,obj in ipairs(pg:GetDescendants()) do
    if not active or not autoClick then break end
    if obj.Name == "Tap2" and purpleVisible(obj) and not obj:IsDescendantOf(gui) then
     visibleNow[obj] = true
     local target = purpleTarget(obj)
     local pos,size = target.AbsolutePosition,target.AbsoluteSize
     local x = math.floor(pos.X+size.X/2)
     local y = math.floor(pos.Y+size.Y/2+PURPLE_Y_OFFSET)
     local sig = tostring(x)..":"..tostring(y)
     if clickedPurple[obj] ~= sig then
      local ok,err=pcall(function() purpleClick(x,y) end)
      if ok and autoClick then clickedPurple[obj]=sig
      else warn("[PURPLE] "..tostring(err)); info.Text="Lila Klick: "..tostring(err):sub(1,70) end
      break
     end
    end
   end
   for obj in pairs(clickedPurple) do
    if not visibleNow[obj] then clickedPurple[obj]=nil end
   end
  end
  task.wait(PURPLE_DELAY)
 end
end)
zoneBtn.MouseButton1Click:Connect(setZone)
scanBtn.MouseButton1Click:Connect(scan)
tpBtn.MouseButton1Click:Connect(function()
 if busy then return end
 busy=true
 local e=scan()
 if e then eggTP(e) end
 busy=false
end)
autoBtn.MouseButton1Click:Connect(function()
 if not autoEgg and not zoneY then info.Text="Erst Bereich festlegen.";return end
 autoEgg=not autoEgg
 autoBtn.Text=autoEgg and "AUTO BEST EGG: AN" or "AUTO BEST EGG: AUS"
end)
task.spawn(function()
 while active do
  if autoEgg and not busy then
   busy=true
   local e=scan()
   if e then
    local ok=eggTP(e)
    if not ok then autoEgg=false;autoBtn.Text="AUTO BEST EGG: AUS" end
   end
   busy=false
  end
  task.wait(8)
 end
end)
print("[SAVE THE EGG V1] Mono UI: Easy Get Egg / Auto Train geladen")
