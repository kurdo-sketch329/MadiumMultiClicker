-- SAVE THE EGG | ZONE SCANNER V3 | EGG TOUR
-- Client-side, unofficial. Server may reject teleports. Only streamed eggs are discoverable.
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local VIM = game:GetService('VirtualInputManager')
local VirtualUser = game:GetService('VirtualUser')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
if _G.SaveEggZoneStop then pcall(_G.SaveEggZoneStop) end
for _,name in ipairs({'SaveEggZoneScannerV1','SaveEggZoneScannerV2','SaveEggZoneScannerV3'}) do
 local g=pg:FindFirstChild(name); if g then g:Destroy() end
end
local running=true
local busy=false
local cancelTour=false
local autoClick=false
local antiAfk=false
local idleConnection=nil
local clicked={}
local zoneY=nil
local heightTolerance=18 -- approximate zone, not official game boundary
local selectedEgg=nil
local tourCache={}
local gui=Instance.new('ScreenGui');gui.Name='SaveEggZoneScannerV3';gui.ResetOnSpawn=false;gui.Parent=pg
local frame=Instance.new('Frame');frame.Size=UDim2.fromOffset(420,400)
frame.Position=UDim2.new(.5,-210,.5,-200);frame.BackgroundColor3=Color3.fromRGB(12,12,13)
frame.Active=true;frame.Draggable=true;frame.BorderSizePixel=0;frame.Parent=gui
Instance.new('UIStroke',frame).Color=Color3.fromRGB(220,220,220)
local title=Instance.new('TextLabel');title.Size=UDim2.new(1,-54,0,34);title.Position=UDim2.fromOffset(13,5)
title.Text='SAVE THE EGG  //  V3';title.TextColor3=Color3.new(1,1,1)
title.BackgroundTransparency=1;title.Font=Enum.Font.Code;title.TextSize=19
title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=frame
local close=Instance.new('TextButton');close.Size=UDim2.fromOffset(30,28);close.Position=UDim2.new(1,-37,0,7)
close.Text='X';close.Font=Enum.Font.Code;close.TextSize=18
close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=Color3.fromRGB(35,35,35);close.Parent=frame
local function button(label,parent,y,h)
 local b=Instance.new('TextButton');b.Size=UDim2.new(1,-24,0,h or 36);b.Position=UDim2.fromOffset(12,y)
 b.Text=label;b.Font=Enum.Font.Code;b.TextSize=15;b.TextColor3=Color3.new(1,1,1)
 b.BackgroundColor3=Color3.fromRGB(32,32,34);b.AutoButtonColor=false;b.Parent=parent
 Instance.new('UIStroke',b).Color=Color3.fromRGB(110,110,110)
 b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(84,84,84)}):Play() end)
 b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(32,32,34)}):Play() end)
 return b
end
local tabs=Instance.new('Frame');tabs.Size=UDim2.new(1,-24,0,34);tabs.Position=UDim2.fromOffset(12,45)
tabs.BackgroundTransparency=1;tabs.Parent=frame
local tabEgg=Instance.new('TextButton');tabEgg.Size=UDim2.new(.5,-3,1,0);tabEgg.Text='EASY GET EGG';tabEgg.Parent=tabs
local tabTrain=Instance.new('TextButton');tabTrain.Size=UDim2.new(.5,-3,1,0);tabTrain.Position=UDim2.new(.5,3,0,0);tabTrain.Text='AUTO TRAIN';tabTrain.Parent=tabs
for _,b in ipairs({tabEgg,tabTrain}) do
 b.Font=Enum.Font.Code;b.TextSize=15;b.TextColor3=Color3.new(1,1,1)
 b.BackgroundColor3=Color3.fromRGB(35,35,37);Instance.new('UIStroke',b).Color=Color3.fromRGB(140,140,140)
end
local eggPage=Instance.new('Frame');eggPage.Size=UDim2.new(1,-10,0,240);eggPage.Position=UDim2.fromOffset(5,88)
eggPage.BackgroundTransparency=1;eggPage.Parent=frame
local trainPage=eggPage:Clone();trainPage.Visible=false;trainPage.Parent=frame
local zoneBtn=button('[ 1 ] BEREICH HIER FESTLEGEN',eggPage,4)
local scanBtn=button('[ 2 ] SCAN EGGS (SOFORT)',eggPage,45)
local tourBtn=button('[ 3 ] EGG TOUR: ALLE PRUEFEN',eggPage,86)
local tpBtn=button('[ 4 ] TP BESTES GEFUNDENES EI',eggPage,127)
local cancelBtn=button('TOUR STOPPEN',eggPage,168)
local purpleBtn=button('AUTO CLICK LILA PUNKTE: AUS',trainPage,4)
local afkBtn=button('ANTI-AFK: AUS',trainPage,45)
local trainLabel=Instance.new('TextLabel');trainLabel.Position=UDim2.fromOffset(12,97)
trainLabel.Size=UDim2.new(1,-24,0,92);trainLabel.TextWrapped=true
trainLabel.Text='Auto Train klickt sichtbare Lila-Punkte. Anti-AFK versucht, bei Inaktivitaet Eingaben zu simulieren.'
trainLabel.BackgroundTransparency=1;trainLabel.TextColor3=Color3.fromRGB(224,224,224)
trainLabel.Font=Enum.Font.Code;trainLabel.TextSize=14;trainLabel.Parent=trainPage
local info=Instance.new('TextLabel');info.Size=UDim2.new(1,-24,0,73);info.Position=UDim2.fromOffset(12,315)
info.BackgroundColor3=Color3.fromRGB(25,25,27);info.TextColor3=Color3.new(1,1,1)
info.TextWrapped=true;info.Font=Enum.Font.Code;info.TextSize=13
info.Text='Bereich festlegen; danach Scan oder Egg Tour starten.';info.Parent=frame
local function showPage(egg)
 eggPage.Visible=egg;trainPage.Visible=not egg
 tabEgg.BackgroundColor3=egg and Color3.fromRGB(100,100,100) or Color3.fromRGB(35,35,37)
 tabTrain.BackgroundColor3=not egg and Color3.fromRGB(100,100,100) or Color3.fromRGB(35,35,37)
end
showPage(true)
tabEgg.MouseButton1Click:Connect(function()showPage(true)end)
tabTrain.MouseButton1Click:Connect(function()showPage(false)end)
local function stop()
 running=false;cancelTour=true;autoClick=false;antiAfk=false
 if idleConnection then idleConnection:Disconnect() end
 if gui.Parent then gui:Destroy() end
end
_G.SaveEggZoneStop=stop;close.MouseButton1Click:Connect(stop)
TweenService:Create(frame,TweenInfo.new(.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(.5,-210,.5,-200)}):Play()
local function characterRoot()
 local c=player.Character
 return c,c and c:FindFirstChild('HumanoidRootPart')
end
local multipliers={K=1e3,M=1e6,B=1e9,T=1e12,Q=1e15}
local function parseLuck(s)
 if type(s)~='string' then return nil end
 s=s:gsub('%s+',''):gsub(',','')
 local a,b=s:match('^([%d%.]+)([kKmMbBtTqQ]?)$')
 if not a then return nil end
 local n=tonumber(a)
 return n and n*(multipliers[b:upper()] or 1) or nil
end
local function fmt(n)
 if n>=1e12 then return string.format('%.2fT',n/1e12) end
 if n>=1e9 then return string.format('%.2fB',n/1e9) end
 if n>=1e6 then return string.format('%.2fM',n/1e6) end
 if n>=1e3 then return string.format('%.1fK',n/1e3) end
 return tostring(math.floor(n))
end
local function eggRoot(prompt)
 local p=prompt.Parent
 for _=1,10 do
  if not p or p==workspace then break end
  if p.Name=='EggRoot' then return p end
  p=p.Parent
 end
end
local function eggPos(root,prompt)
 local p=prompt.Parent
 if p:IsA('Attachment') then return p.WorldPosition end
 if p:IsA('BasePart') then return p.Position end
 if root:IsA('BasePart') then return root.Position end
 if root:IsA('Model') then
  local part=root:FindFirstChildWhichIsA('BasePart',true)
  return part and part.Position or root:GetPivot().Position
 end
end
local function luckFrom(root)
 local badge=root:FindFirstChild('WeightBadge',true)
 local luck=badge and badge:FindFirstChild('Luck',true)
 if not luck then return nil end
 if luck:IsA('TextLabel') or luck:IsA('TextButton') then
  local v=parseLuck(luck.Text);if v then return v end
 end
 for _,o in ipairs(luck:GetDescendants()) do
  if o:IsA('TextLabel') or o:IsA('TextButton') then
   local v=parseLuck(o.Text);if v then return v end
  end
 end
end
local function getEggs()
 local eggs,seen={},{}
 for _,prompt in ipairs(workspace:GetDescendants()) do
  if prompt:IsA('ProximityPrompt') and prompt.Enabled then
   local action=(prompt.ActionText or ''):lower()
   local name=(prompt.ObjectText or ''):lower()
   if (action:find('pick',1,true) or action:find('collect',1,true)) and name:find('egg',1,true) then
    local root=eggRoot(prompt)
    if root and not seen[root] then
     seen[root]=true
     local p=eggPos(root,prompt)
     if p then table.insert(eggs,{root=root,prompt=prompt,name=prompt.ObjectText,position=p,luck=luckFrom(root)}) end
    end
   end
  end
 end
 return eggs
end
local function inZone(e)
 return zoneY and math.abs(e.position.Y-zoneY)<=heightTolerance
end
local function setZone()
 if busy then return end
 local _,r=characterRoot();if not r then info.Text='Charakter nicht bereit.';return end
 local near,dist=nil,math.huge
 for _,e in ipairs(getEggs()) do
  local d=(e.position-r.Position).Magnitude
  if d<dist then near=e;dist=d end
 end
 if not near then info.Text='Keine Eier geladen. Gehe naeher zu einem Ei.';return end
 if dist>180 then info.Text='Stell dich zur sicheren Bereichswahl naeher an ein Ei (180 Studs).';return end
 zoneY=near.position.Y;selectedEgg=nil;table.clear(tourCache)
 info.Text='Bereich gesetzt bei '..near.name..'. Jetzt SCAN oder TOUR.'
 print('[ZONE V3] Anchor',near.name,'Y',zoneY)
end
local function candidates()
 local arr={}
 for _,e in ipairs(getEggs()) do
  if inZone(e) then table.insert(arr,e) end
 end
 return arr
end
local function scanNow()
 if not zoneY then info.Text='Zuerst Bereich festlegen.';return end
 local arr=candidates();local readable={}
 for _,e in ipairs(arr) do
  if e.luck then table.insert(readable,e) end
 end
 table.sort(readable,function(a,b)return a.luck>b.luck end)
 selectedEgg=readable[1]
 print('[SCAN] Im Bereich',#arr,'mit Luck',#readable)
 for i,e in ipairs(readable) do
  print('[SCAN]',i,e.name,fmt(e.luck))
 end
 if selectedEgg then info.Text='SCAN: '..#readable..' Eier mit Luck. BESTES: '..selectedEgg.name..' / '..fmt(selectedEgg.luck)
 else info.Text='Keine auslesbaren Luck-Werte im Bereich.' end
end
local function teleport(e)
 local char,r=characterRoot()
 if not char or not r or not e then return false end
 local p=e.position+Vector3.new(3,4,0)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances={char,e.root}
 local hit=workspace:Raycast(p+Vector3.new(0,9,0),Vector3.new(0,-40,0),params)
 if hit and hit.Normal.Y>.65 and hit.Position.Y<=e.position.Y+4 then p=hit.Position+Vector3.new(0,4.2,0) end
 r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
 local ok=pcall(function()char:PivotTo(CFrame.new(p,e.position))end)
 if not ok then return false end
 task.wait(1.25)
 local _,r2=characterRoot()
 return r2~=nil and (r2.Position-p).Magnitude<=18
end
local function tour()
 if busy or not zoneY then
  if not zoneY then info.Text='Zuerst Bereich festlegen.' end
  return
 end
 busy=true;cancelTour=false;selectedEgg=nil
 tourBtn.Text='TOUR LAEUFT ...'
 local seen={};local checked=0;local failed=0
 -- Collect currently loaded candidates. Repeat discovery after each move to include newly streamed eggs.
 local queue=candidates();local index=1
 while running and not cancelTour and index<=#queue and checked<150 do
  local e=queue[index];index=index+1
  if not seen[e.root] and e.root.Parent and inZone(e) then
   seen[e.root]=true
   info.Text=string.format('TOUR: Ei %d/%d | %s',checked+1,#queue,e.name)
   local arrived=teleport(e)
   if arrived then
    task.wait(.4) -- give HUD a moment to update
    if e.root.Parent then
     local luck=luckFrom(e.root)
     if luck then
      e.luck=luck;checked=checked+1
      table.insert(tourCache,e)
      print('[TOUR]',e.name,fmt(luck))
     else
      failed=failed+1;print('[TOUR] Luck unbekannt:',e.name)
     end
    end
   else
    failed=failed+1;print('[TOUR] Teleport blockiert:',e.name)
   end
   for _,newEgg in ipairs(candidates()) do
    if not seen[newEgg.root] then
     local queued=false
     for j=index,#queue do if queue[j].root==newEgg.root then queued=true;break end end
     if not queued then table.insert(queue,newEgg) end
    end
   end
  end
 end
 table.sort(tourCache,function(a,b)return a.luck>b.luck end)
 selectedEgg=tourCache[1]
 tourBtn.Text='[ 3 ] EGG TOUR: ALLE PRUEFEN';busy=false
 if not running then return end
 if cancelTour then info.Text='Tour gestoppt. Geprueft: '..checked..' | fehlgeschlagen: '..failed;return end
 if not selectedEgg then info.Text='Kein Ei verifiziert ('..failed..' Fehler). Server kann TP blockieren.';return end
 info.Text='BESTES: '..selectedEgg.name..' / '..fmt(selectedEgg.luck)..' | geprueft '..checked..' | Fehler '..failed..'. TP ...'
 local best=selectedEgg
 if not teleport(best) then
  info.Text='BESTES: '..best.name..' / '..fmt(best.luck)..' | Rueck-TP wurde blockiert.'
 else
  info.Text='BESTES: '..best.name..' / '..fmt(best.luck)..' | '..checked..' geprueft, '..failed..' Fehler.'
 end
end
zoneBtn.MouseButton1Click:Connect(setZone)
scanBtn.MouseButton1Click:Connect(function()if not busy then scanNow()end end)
tourBtn.MouseButton1Click:Connect(function()if not busy then task.spawn(tour)end end)
cancelBtn.MouseButton1Click:Connect(function()cancelTour=true;info.Text='Stoppe Tour nach aktuellem Teleport ...' end)
tpBtn.MouseButton1Click:Connect(function()
 if busy then return end
 if not selectedEgg then info.Text='Zuerst Scan oder Tour starten.';return end
 busy=true
 local e=selectedEgg
 if teleport(e) then info.Text='TP zu '..e.name..' / '..fmt(e.luck)..' gelungen (clientseitig).'
 else info.Text='TP blockiert oder zurueckgesetzt.' end
 busy=false
end)
local function visible(obj)
 if not obj:IsA('GuiObject') or obj.AbsoluteSize.X<5 or obj.AbsoluteSize.Y<5 then return false end
 local p=obj
 while p and p~=pg do
  if p:IsA('GuiObject') and not p.Visible then return false end
  if p:IsA('ScreenGui') and not p.Enabled then return false end
  p=p.Parent
 end
 return true
end
purpleBtn.MouseButton1Click:Connect(function()
 autoClick=not autoClick;table.clear(clicked)
 purpleBtn.Text=autoClick and 'AUTO CLICK LILA PUNKTE: AN' or 'AUTO CLICK LILA PUNKTE: AUS'
end)
task.spawn(function()
 while running do
  if autoClick then
   local now={}
   for _,obj in ipairs(pg:GetDescendants()) do
    if not running or not autoClick then break end
    if obj.Name=='Tap2' and visible(obj) and not obj:IsDescendantOf(gui) then
     now[obj]=true
     local target=obj
     local parent=obj.Parent
     if parent then
      local tap=parent:FindFirstChild('Tap')
      local hit=parent:FindFirstChild('Hit')
      if tap and visible(tap) then target=tap elseif hit and visible(hit) then target=hit end
     end
     local x=math.floor(target.AbsolutePosition.X+target.AbsoluteSize.X/2)
     local y=math.floor(target.AbsolutePosition.Y+target.AbsoluteSize.Y/2+60)
     local sig=x..':'..y
     if clicked[obj]~=sig then
      pcall(function()
       if type(mousemoveabs)=='function' then mousemoveabs(x,y) end
       task.wait(.15)
       if not autoClick then return end
       VIM:SendMouseButtonEvent(x,y,0,true,game,0)
       task.wait(1)
       VIM:SendMouseButtonEvent(x,y,0,false,game,0)
      end)
      clicked[obj]=sig
      break
     end
    end
   end
   for obj in pairs(clicked) do if not now[obj] then clicked[obj]=nil end end
  end
  task.wait(.08)
 end
end)
afkBtn.MouseButton1Click:Connect(function()
 antiAfk=not antiAfk;afkBtn.Text=antiAfk and 'ANTI-AFK: AN' or 'ANTI-AFK: AUS'
 if idleConnection then idleConnection:Disconnect();idleConnection=nil end
 if antiAfk then
  idleConnection=player.Idled:Connect(function()
   if running and antiAfk then pcall(function()VirtualUser:CaptureController();VirtualUser:ClickButton2(Vector2.new(0,0))end)end
  end)
 end
end)
print('[SAVE THE EGG V3] Egg Tour loaded. Discover and verify streamed eggs in approximate height zone.')
