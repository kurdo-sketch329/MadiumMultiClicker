-- SAVE THE EGG | ZONE SCANNER V1 - Neuaufbau
-- Inoffizieller Client-Scanner fuer geladene Eier. Keine garantierte Server-Teleportation.
-- Bereich wird anhand des naechsten geladenen Eis und seiner Hoehe geschaetzt; keine echten Zonengrenzen.
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
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
local baseVerified=false
local zoneY=nil
local zoneCenter=nil
local maxHorizontal=1200
local heightTolerance=18
local interval=8
local gui=Instance.new('ScreenGui')
gui.Name='SaveEggZoneScannerV1'; gui.ResetOnSpawn=false; gui.Parent=pg
local frame=Instance.new('Frame')
frame.Size=UDim2.fromOffset(394,455)
frame.Position=UDim2.new(.5,-197,.15,0)
frame.BackgroundColor3=Color3.fromRGB(13,13,15)
frame.BorderSizePixel=0
frame.Active=true;frame.Draggable=true;frame.Parent=gui
Instance.new('UICorner',frame).CornerRadius=UDim.new(0,16)
local outline=Instance.new('UIStroke',frame);outline.Color=Color3.fromRGB(90,90,94);outline.Thickness=1
local top=Instance.new('Frame',frame);top.Size=UDim2.new(1,0,0,66);top.BackgroundTransparency=1
local accent=Instance.new('Frame',frame);accent.Size=UDim2.new(1,-24,0,2);accent.Position=UDim2.fromOffset(12,65);accent.BackgroundColor3=Color3.fromRGB(232,232,232);accent.BorderSizePixel=0
local function label(t,y,h)
 local o=Instance.new('TextLabel');o.Size=UDim2.new(1,-24,0,h);o.Position=UDim2.fromOffset(12,y)
 o.BackgroundTransparency=1;o.TextColor3=Color3.fromRGB(235,235,235);o.Font=Enum.Font.Gotham
 o.TextSize=13;o.TextWrapped=true;o.Text=t;o.Parent=frame;return o
end
local function button(t,y)
 local o=Instance.new('TextButton');o.Size=UDim2.new(1,-24,0,39);o.Position=UDim2.fromOffset(12,y)
 o.BackgroundColor3=Color3.fromRGB(36,36,39);o.AutoButtonColor=false
 o.TextColor3=Color3.fromRGB(248,248,248)
 o.Font=Enum.Font.GothamBold;o.TextSize=13;o.Text=t;o.Parent=frame
 Instance.new('UICorner',o).CornerRadius=UDim.new(0,9)
 local line=Instance.new('UIStroke',o);line.Color=Color3.fromRGB(75,75,78);line.Thickness=.7
 o.MouseEnter:Connect(function() TweenService:Create(o,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(78,78,82)}):Play() end)
 o.MouseLeave:Connect(function() TweenService:Create(o,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(36,36,39)}):Play() end)
 return o
end
local title=label('SAVE THE EGG',9,28);title.Font=Enum.Font.GothamBlack;title.TextSize=20;title.TextXAlignment=Enum.TextXAlignment.Left
local subtitle=label('ZONE SCANNER  /  V1',36,22);subtitle.TextSize=11;subtitle.TextColor3=Color3.fromRGB(163,163,167);subtitle.TextXAlignment=Enum.TextXAlignment.Left
local zoneBtn=button('01   BEREICH FESTLEGEN',79)
local scanBtn=button('02   BESTES EI SUCHEN',124)
local tpBtn=button('03   TP ZUM BESTEN EI',169)
local saveBtn=button('04   BASE HIER SPEICHERN',214)
local baseBtn=button('05   BASE TP TESTEN',259)
local autoBtn=button('AUTO EI  ->  BASE: AUS',304)
local info=label('Bereich festlegen und dann scannen.',357,85)
info.TextColor3=Color3.fromRGB(198,198,204)
local close=Instance.new('TextButton');close.Size=UDim2.fromOffset(30,29)
close.Position=UDim2.new(1,-39,0,15);close.Text='X';close.Font=Enum.Font.GothamBold;close.TextSize=14
close.TextColor3=Color3.fromRGB(235,235,235);close.BackgroundColor3=Color3.fromRGB(55,55,60);close.Parent=frame
Instance.new('UICorner',close).CornerRadius=UDim.new(0,8)
local function stop() active=false;auto=false; if gui.Parent then gui:Destroy() end end
_G.SaveEggZoneStop=stop;close.MouseButton1Click:Connect(stop)
frame.Position=UDim2.new(.5,-197,-.65,0)
TweenService:Create(frame,TweenInfo.new(.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(.5,-197,.15,0)}):Play()
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
local function saveBase()
 local char,root=rootPart()
 if not root then info.Text='Base: Charakter nicht bereit.';return end
 -- Root-Position und Blickrichtung speichern, nicht das Model-Pivot des gesamten Pets.
 baseCFrame=root.CFrame
 baseVerified=false
 info.Text='Baseposition gespeichert. Bitte Base-TP testen.'
 print('[BASE] Gespeicherte Position:',baseCFrame.Position)
end
local function tpBase()
 if not baseCFrame then info.Text='Zuerst Base speichern.';return false end
 local target=baseCFrame+Vector3.new(0,3,0)
 local ok=teleportTo(target,'Base TP')
 if ok then baseVerified=true end
 return ok
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
 saveBase()
end)
baseBtn.MouseButton1Click:Connect(function()
 if busy then return end
 if not baseCFrame then info.Text='Bitte zuerst Base speichern.';return end
 busy=true;tpBase();busy=false
end)
autoBtn.MouseButton1Click:Connect(function()
 if not auto and not baseVerified then info.Text='Zuerst Base speichern UND Base TP erfolgreich testen.';return end
 if not auto and not zoneY then info.Text='Zuerst im Ei-Bereich Bereich setzen.';return end
 auto=not auto;autoBtn.Text=auto and 'AUTO EI  ->  BASE: AN' or 'AUTO EI  ->  BASE: AUS'
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
      local reached=tpBase()
      if not reached then auto=false;autoBtn.Text='AUTO EI  ->  BASE: AUS' end
     end
    else
     auto=false;autoBtn.Text='AUTO EI  ->  BASE: AUS'
    end
   end
   busy=false
  end
  task.wait(interval)
 end
end)
print('[ZONE SCANNER V1] Neuaufbau geladen. Bereich neben einem Ei festlegen, dann Scan.')
