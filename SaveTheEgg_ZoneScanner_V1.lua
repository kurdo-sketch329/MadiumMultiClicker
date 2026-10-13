-- SAVE THE EGG | ZONE SCANNER V1 - Neuaufbau
-- Inoffizieller Client-Scanner fuer geladene Eier. Keine garantierte Server-Teleportation.
-- Bereich wird per Spielerposition/naechstem Eier-Hoehencluster bestimmt.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
if _G.SaveEggZoneStop then pcall(_G.SaveEggZoneStop) end
for _,n in ipairs({'SaveEggZoneScannerV1','SaveEggZoneScannerV2'}) do
    local g=pg:FindFirstChild(n); if g then g:Destroy() end
end
local active=true
local auto=false
local busy=false
local baseCFrame=nil
local zoneY=nil
local zoneCenter=nil
local maxHorizontal=700
local heightTolerance=18
local interval=8
local gui=Instance.new('ScreenGui')
gui.Name='SaveEggZoneScannerV1'; gui.ResetOnSpawn=false; gui.Parent=pg
local frame=Instance.new('Frame')
frame.Size=UDim2.fromOffset(385,425)
frame.Position=UDim2.new(.5,-192, .15,0)
frame.BackgroundColor3=Color3.fromRGB(31,26,44)
frame.Active=true; frame.Draggable=true; frame.Parent=gui
Instance.new('UICorner',frame).CornerRadius=UDim.new(0,10)
local function label(t,y,h)
 local o=Instance.new('TextLabel');o.Size=UDim2.new(1,-18,0,h);o.Position=UDim2.fromOffset(9,y)
 o.BackgroundTransparency=1;o.TextColor3=Color3.new(1,1,1);o.Font=Enum.Font.Gotham
 o.TextSize=13;o.TextWrapped=true;o.Text=t;o.Parent=frame;return o
end
local function button(t,y)
 local o=Instance.new('TextButton');o.Size=UDim2.new(1,-20,0,34);o.Position=UDim2.fromOffset(10,y)
 o.BackgroundColor3=Color3.fromRGB(86,65,157);o.TextColor3=Color3.new(1,1,1)
 o.Font=Enum.Font.GothamBold;o.TextSize=13;o.Text=t;o.Parent=frame
 Instance.new('UICorner',o).CornerRadius=UDim.new(0,7);return o
end
local title=label('SAVE THE EGG | ZONE SCANNER V1',5,27);title.Font=Enum.Font.GothamBold
local zoneBtn=button('Bereich HIER festlegen',38)
local scanBtn=button('Scan: beste Eier im Bereich',77)
local tpBtn=button('TP: bestes Ei (einmal)',116)
local saveBtn=button('Meine Base HIER speichern',155)
local baseBtn=button('Test: TP zur Base',194)
local autoBtn=button('Auto Ei -> Base: AUS',233)
local info=label('Zuerst im Ei-Bereich auf "Bereich HIER festlegen" klicken.',282,128)
local close=Instance.new('TextButton');close.Size=UDim2.fromOffset(28,25)
close.Position=UDim2.new(1,-33,0,4);close.Text='X';close.TextColor3=Color3.new(1,1,1)
close.BackgroundColor3=Color3.fromRGB(175,45,72);close.Parent=frame
local function stop() active=false;auto=false; if gui.Parent then gui:Destroy() end end
_G.SaveEggZoneStop=stop;close.MouseButton1Click:Connect(stop)
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
 if not nearest or nd>180 then
  info.Text='Stell dich neben ein Ei in deinem gewuenschten Bereich (max. 180 Studs).'
  return
 end
 zoneY=nearest.position.Y
 zoneCenter=Vector3.new(r.Position.X,0,r.Position.Z)
 info.Text='Bereich gesetzt: Ei-Hoehe Y '..string.format('%.1f',zoneY)..'. Jetzt Scan druecken.'
 print('[ZONE] Anchor '..nearest.name..' | Hoehe '..zoneY)
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
 local before=root.Position
 char:PivotTo(cframe)
 task.wait(1.1)
 local afterRoot=char:FindFirstChild('HumanoidRootPart')
 if not afterRoot then info.Text='Teleport: Charakter neu geladen.';return false end
 local desired=cframe.Position
 if (afterRoot.Position-desired).Magnitude>18 then
  info.Text=desc..': Zurueckgesetzt oder blockiert (Abstand '..math.floor((afterRoot.Position-desired).Magnitude)..').'
  return false
 end
 info.Text=desc..': Ziel erreicht (clientseitig).'
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
zoneBtn.MouseButton1Click:Connect(setZone)
scanBtn.MouseButton1Click:Connect(scan)
tpBtn.MouseButton1Click:Connect(function()
 if busy then return end
 busy=true
 local e=scan();if e then eggTP(e) end
 busy=false
end)
saveBtn.MouseButton1Click:Connect(function()
 local char,root=rootPart()
 if root then baseCFrame=char:GetPivot(); info.Text='Base gespeichert. Bitte Base-Test ausfuehren.' end
end)
baseBtn.MouseButton1Click:Connect(function()
 if busy then return end
 if not baseCFrame then info.Text='Bitte zuerst Base speichern.';return end
 busy=true;teleportTo(baseCFrame,'Base-Teleport');busy=false
end)
autoBtn.MouseButton1Click:Connect(function()
 if not auto and not baseCFrame then info.Text='Zuerst Base speichern und testen.';return end
 if not auto and not zoneY then info.Text='Zuerst im Ei-Bereich Bereich setzen.';return end
 auto=not auto;autoBtn.Text=auto and 'Auto Ei -> Base: AN' or 'Auto Ei -> Base: AUS'
end)
task.spawn(function()
 while active do
  if auto and not busy then
   busy=true
   local e=scan()
   if e then
    local ok=eggTP(e)
    if ok then
     -- Keine automatische Einsammlung vortaeuschen: hier nur warten.
     info.Text='Beim Ei. Einsammeln mit E; Rueckkehr zur Base in 5 Sekunden.'
     task.wait(5)
     if auto and baseCFrame then
      local reached=teleportTo(baseCFrame,'Base-Teleport')
      if not reached then auto=false;autoBtn.Text='Auto Ei -> Base: AUS' end
     end
    else
     auto=false;autoBtn.Text='Auto Ei -> Base: AUS'
    end
   end
   busy=false
  end
  task.wait(interval)
 end
end)
print('[ZONE SCANNER V1] Neuaufbau geladen. Bereich neben einem Ei festlegen, dann Scan.')
