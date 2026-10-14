-- SAVE THE EGG | ZONE SCANNER V9 | OHNE TELEPORT
-- Client-side tool; TP can be rejected by the Roblox server.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
if _G.SaveEggZoneStop then pcall(_G.SaveEggZoneStop) end
for _, name in ipairs({"SaveEggZoneScannerV1", "SaveEggZoneScannerV2", "SaveEggZoneScannerV4", "SaveEggZoneScannerV9", "SaveEggZoneScannerV3", "SaveEggZoneScannerV9"}) do
 local old = pg:FindFirstChild(name)
 if old then old:Destroy() end
end
local active, autoClick, busy = true, false, false
local antiAfk = false
local walking = false
local walkToken = 0
local idleConnection = nil
local clickedPurple = {}
local PURPLE_Y_OFFSET = 60
local PURPLE_HOLD_TIME = 1
local PURPLE_DELAY = 0.08
local zoneY, zoneCenter = nil, nil
local heightTolerance = 35
local selectedEgg = nil
-- Memory only stores observations, not proof an egg still exists.
local eggMemory = {}
local MEMORY_SECONDS = 600
local lastScanAt = 0
local function eggKey(e)
 local p=e.position
 return string.format('%s:%.0f:%.0f:%.0f',e.name,math.floor(p.X/4),math.floor(p.Y/4),math.floor(p.Z/4))
end
local gui = Instance.new("ScreenGui")
gui.Name = "SaveEggZoneScannerV9"
gui.ResetOnSpawn = false
gui.Parent = pg
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(410, 505)
frame.Position = UDim2.new(.5,-205,.5,-252)
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
title.Text = "SAVE THE EGG  //  SMART V9"
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
eggPage.Size = UDim2.new(1,-10,0,325)
eggPage.Position = UDim2.fromOffset(5,91)
eggPage.BackgroundTransparency = 1
eggPage.Parent = frame
local trainPage = eggPage:Clone()
trainPage.Name = "TrainPage"
trainPage.Visible = false
trainPage.Parent = frame
for _,o in ipairs(trainPage:GetChildren()) do o:Destroy() end
local zoneBtn = button("[ 1 ]  BEREICH HIER FESTLEGEN",eggPage,5)
local scanBtn = button("[ 2 ]  SCAN EGGS (MAX LUCK)",eggPage,49)
local baseSaveBtn = button("[ 3 ]  BASE MITTE SPEICHERN",eggPage,93)
local baseTpBtn = button("[ 4 ]  AUTO WALK BASE",eggPage,137)
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
info.Size = UDim2.new(1,-30,0,85)
info.Position = UDim2.fromOffset(15,420)
info.BackgroundColor3 = Color3.fromRGB(20,20,22)
info.TextColor3 = Color3.fromRGB(226,226,226)
info.Font = Enum.Font.Code
info.TextSize = 13
info.TextWrapped = true
info.Text = "Ohne TP: Bereich scannen, Base speichern, dann Auto Walk nutzen."
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
 antiAfk=false
 walking=false
 walkToken=walkToken+1
 if idleConnection then idleConnection:Disconnect(); idleConnection=nil end
 if gui.Parent then gui:Destroy() end
end
_G.SaveEggZoneStop = stop
close.MouseButton1Click:Connect(stop)
frame.Position = UDim2.new(.5,-205,.5,-352)
TweenService:Create(frame,TweenInfo.new(.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(.5,-205,.5,-252)}):Play()
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
-- Flexible egg detection: no fixed EggRoot/WeightBadge hierarchy required.
local function eggRootFromPrompt(prompt)
 local node=prompt.Parent
 local fallback=nil
 for i=1,12 do
  if not node or node==workspace then break end
  if node.Name=='EggRoot' then return node end
  if node:IsA('Model') then
   if node.Name:lower():find('egg',1,true) then return node end
   if not fallback then fallback=node end
  end
  node=node.Parent
 end
 return fallback or prompt.Parent
end
local function eggPosition(root,prompt)
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
local function readLuck(root,prompt)
 -- Prefer explicit Luck attributes / labels; never use unrelated board numbers.
 for _,obj in ipairs({root,prompt}) do
  for _,key in ipairs({'Luck','LuckValue','Weight'}) do
   local v=obj:GetAttribute(key)
   if type(v)=='number' then return v end
   if type(v)=='string' and number(v) then return number(v) end
  end
 end
 local containers={root}
 if prompt.Parent and prompt.Parent~=root then table.insert(containers,prompt.Parent) end
 for _,container in ipairs(containers) do
  for _,obj in ipairs(container:GetDescendants()) do
   if obj.Name:lower()=='luck' or obj.Name:lower()=='luckvalue' then
    if obj:IsA('NumberValue') or obj:IsA('IntValue') then return obj.Value end
    if obj:IsA('StringValue') then local v=number(obj.Value);if v then return v end end
    if obj:IsA('TextLabel') or obj:IsA('TextButton') then
     local v=number(obj.Text) or number((obj.Text or ''):match('([%d%.]+[KkMmBbTtQq]?)'))
     if v then return v end
    end
    for _,child in ipairs(obj:GetDescendants()) do
     if child:IsA('TextLabel') or child:IsA('TextButton') then
      local v=number(child.Text)
      if v then return v end
     end
    end
   end
  end
  -- Clover and number can be separate text labels under the same badge.
  local badge=container:FindFirstChild('WeightBadge',true)
  if badge then
   local nums={}
   for _,obj in ipairs(badge:GetDescendants()) do
    if obj:IsA('TextLabel') or obj:IsA('TextButton') then
     local v=number(obj.Text)
     if v then table.insert(nums,v) end
    end
   end
   if #nums==1 then return nums[1] end
  end
 end
 return nil
end
-- Diagnostics: a custom pickup UI can exist without a ProximityPrompt.
local function diagnostics()
 local promptCount, eggNames, luckLabels, pickupLabels = 0, 0, 0, 0
 local examples = {}
 for _,obj in ipairs(workspace:GetDescendants()) do
  if obj:IsA('ProximityPrompt') then promptCount=promptCount+1 end
  if (obj:IsA('Model') or obj:IsA('BasePart')) and (obj.Name:lower():find('egg',1,true) or obj.Name:lower():find('ei',1,true)) then
   eggNames=eggNames+1
   if #examples<4 then table.insert(examples,obj:GetFullName():sub(-90)) end
  end
 end
 for _,parent in ipairs({workspace,pg}) do
  for _,obj in ipairs(parent:GetDescendants()) do
   if obj:IsA('TextLabel') or obj:IsA('TextButton') then
    local t=obj.Text or ''
    if t:find('🍀',1,true) or t:lower():find('luck',1,true) then luckLabels=luckLabels+1 end
    if t:lower():find('aufheben',1,true) or t:lower():find('pick up',1,true) then pickupLabels=pickupLabels+1 end
   end
  end
 end
 print('[V4 DIAG] Prompts:',promptCount,'Egg-name objects:',eggNames,'Luck labels:',luckLabels,'Pickup labels:',pickupLabels)
 for _,name in ipairs(examples) do print('[V4 EGG OBJECT]',name) end
 return string.format('Diagnose: Prompts %d | Ei-Objekte %d | Luck-Texte %d | Pickup-Texte %d',promptCount,eggNames,luckLabels,pickupLabels)
end
-- V5: collect world-space egg models and nearby world-space luck labels.
local function worldPosition(obj)
 if obj:IsA('Attachment') then return obj.WorldPosition end
 if obj:IsA('BasePart') then return obj.Position end
 if obj:IsA('Model') then
  local ok,cf=pcall(function() return obj:GetPivot() end)
  if ok then return cf.Position end
 end
 if obj:IsA('BillboardGui') or obj:IsA('SurfaceGui') then
  local ad=obj.Adornee
  if ad then return worldPosition(ad) end
 end
 local node=obj.Parent
 for _=1,12 do
  if not node or node==workspace then break end
  if node:IsA('Attachment') or node:IsA('BasePart') then return worldPosition(node) end
  node=node.Parent
 end
 return nil
end
local function parseLuckText(t)
 if type(t)~='string' then return nil end
 local cleaned=t:gsub(',',''):gsub('%s+','')
 local v=cleaned:match('🍀([%d%.]+[KkMmBbTtQq]?)')
 if v then return number(v) end
 v=cleaned:match('[Ll][Uu][Cc][Kk][^%d]*([%d%.]+[KkMmBbTtQq]?)')
 if v then return number(v) end
 return nil
end
local function loadedEggs()
 local objects=workspace:GetDescendants()
 local eggs,labels={},{}
 local seen={}
 local promptCount=0
 for _,obj in ipairs(objects) do
  if obj:IsA('ProximityPrompt') then promptCount=promptCount+1 end
  if (obj:IsA('Model') or obj:IsA('BasePart')) and
   (obj.Name:lower():find('egg',1,true) or obj.Name:lower():find('ei',1,true)) then
   -- Prefer models over their nested named parts.
   local ancestor=obj.Parent;local nested=false
   while ancestor and ancestor~=workspace do
    if ancestor:IsA('Model') and (ancestor.Name:lower():find('egg',1,true) or ancestor.Name:lower():find('ei',1,true)) then nested=true;break end
    ancestor=ancestor.Parent
   end
   if not nested then
    local pos=worldPosition(obj)
    if pos then table.insert(eggs,{name=obj.Name,position=pos,root=obj}) end
   end
  end
  if obj:IsA('TextLabel') or obj:IsA('TextButton') then
   local t=obj.Text or ''
   local luck=parseLuckText(t)
   if not luck and (obj.Name:lower():find('luck',1,true) or obj.Name:lower()=='value') then
    luck=number(t)
   end
   if luck and luck>0 then
    local pos=worldPosition(obj)
    if pos then table.insert(labels,{luck=luck,position=pos,object=obj}) end
   end
  end
 end
 -- If clover is a separate image/label, the number can be a sibling.
 for _,obj in ipairs(objects) do
  if (obj:IsA('TextLabel') or obj:IsA('TextButton')) and (obj.Text or ''):find('🍀',1,true) then
   local parent=obj.Parent
   if parent then
    for _,sib in ipairs(parent:GetChildren()) do
     if sib~=obj and (sib:IsA('TextLabel') or sib:IsA('TextButton')) then
      local luck=number(sib.Text or '')
      local pos=worldPosition(obj)
      if luck and luck>0 and pos then table.insert(labels,{luck=luck,position=pos,object=obj}) end
     end
    end
   end
  end
 end
 local arr={};local unmatched=0
 for _,egg in ipairs(eggs) do
  local luck=readLuck(egg.root,egg.root)
  local nearest,dist=nil,math.huge
  for _,label in ipairs(labels) do
   local d=(label.position-egg.position).Magnitude
   if d<dist then nearest,dist=label,d end
  end
  -- Do not borrow luck from a distant unrelated object.
  if not luck and nearest and dist<=28 then luck=nearest.luck end
  if luck then
   table.insert(arr,{name=egg.name,position=egg.position,luck=luck,root=egg.root,prompt=nil})
  else unmatched=unmatched+1 end
 end
 print('[V5 SCAN] Egg models',#eggs,'World luck labels',#labels,'Unmatched',unmatched,'All prompts',promptCount)
 return arr,unmatched,promptCount
end
local function setZone()
 local _,r=rootPart()
 if not r then info.Text='Charakter noch nicht bereit.';return end
 local arr,unparsed,prompts=loadedEggs()
 local nearest=nil;local nd=math.huge
 for _,egg in ipairs(arr) do
  local d=(egg.position-r.Position).Magnitude
  if d<nd then nd=d;nearest=egg end
 end
 if nearest then
  zoneY=nearest.position.Y
  zoneCenter=Vector3.new(nearest.position.X,0,nearest.position.Z)
  info.Text='Bereich gesetzt bei '..nearest.name..'. Jetzt Scan druecken.'
 else
  -- Use current floor/character height as fallback, not an egg requirement.
  local params=RaycastParams.new()
  params.FilterType=Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances={player.Character}
  local hit=workspace:Raycast(r.Position,Vector3.new(0,-80,0),params)
  zoneY=hit and hit.Position.Y+3 or r.Position.Y
  zoneCenter=Vector3.new(r.Position.X,0,r.Position.Z)
  info.Text='Bereich an deiner Position gesetzt. PickUp-Prompts: '..prompts..' | Luck unklar: '..unparsed
 end
 selectedEgg=nil
 table.clear(eggMemory)
end
local function candidates()
 local eggs,unparsed,prompts=loadedEggs()
 if not zoneY then return {},#eggs,unparsed,'Bereich noch nicht festgelegt.' end
 local usable={}; local wrongLevel=0
 for _,e in ipairs(eggs) do
  -- Keine Entfernungsgrenze: auch 50M weit weg soll gegen 5M gewinnen.
  -- Nur die bei Bereich festlegen gespeicherte Ei-Ebene wird beruecksichtigt.
  if math.abs(e.position.Y-zoneY)>heightTolerance then
   wrongLevel=wrongLevel+1
  else
   table.insert(usable,e)
  end
 end
 table.sort(usable,function(a,b)
  if a.luck~=b.luck then return a.luck>b.luck end
  local da=(Vector3.new(a.position.X,0,a.position.Z)-zoneCenter).Magnitude
  local db=(Vector3.new(b.position.X,0,b.position.Z)-zoneCenter).Magnitude
  return da<db
 end)
 local summary=string.format('Eier %d | Bereich %d | andere Hoehe %d | Luck unklar %d | Prompts %d',#eggs,#usable,wrongLevel,unparsed,prompts)
 return usable,#eggs,unparsed,summary
end
local function scan()
 local arr,_,_,summary=candidates()
 local now=os.clock()
 lastScanAt=now
 local present={}
 for _,e in ipairs(arr) do
  local key=eggKey(e)
  present[key]=true
  local item=eggMemory[key]
  if not item then
   item={name=e.name,position=e.position,luck=e.luck,firstSeen=now}
   eggMemory[key]=item
  end
  item.name=e.name
  item.position=e.position
  item.luck=e.luck
  item.lastSeen=now
 end
 -- Remove outdated observations; never claim cached eggs are still available.
 for k,item in pairs(eggMemory) do
  if now-item.lastSeen>MEMORY_SECONDS then eggMemory[k]=nil end
 end
 local remembered=nil
 local memoryCount=0
 for k,item in pairs(eggMemory) do
  memoryCount=memoryCount+1
  if not remembered or item.luck>remembered.luck then remembered=item end
 end
 selectedEgg=arr[1]
 print('[SMART SCAN] '..summary..' | Memory '..memoryCount)
 for i,e in ipairs(arr) do
  if i>20 then break end
  print(string.format('[EGG #%d] %s | Luck %s | Y %.1f',i,e.name,fmt(e.luck),e.position.Y))
 end
 if not selectedEgg then
  info.Text=summary..'\n'..diagnostics()..'\nKein geladenes Ei erreichbar. Gespeichert: '..
   (remembered and (remembered.name..' / '..fmt(remembered.luck)..' (NICHT geladen)') or 'keines')
  return nil
 end
 local extra=''
 if remembered and remembered.luck>selectedEgg.luck then
  extra='\nBesser gemerkt: '..remembered.name..' '..fmt(remembered.luck)..' (NICHT bestaetigt)'
 end
 info.Text=summary..'\nBESTES GELADEN: '..selectedEgg.name..' '..fmt(selectedEgg.luck)..extra
 print('[BEST LOADED]',selectedEgg.name,fmt(selectedEgg.luck))
 if remembered then print('[BEST REMEMBERED]',remembered.name,fmt(remembered.luck),
   present[eggKey(remembered)] and 'geladen' or 'moeglicherweise entladen') end
 return selectedEgg
end
-- Base position is session-local.
local basePosition = nil
baseSaveBtn.MouseButton1Click:Connect(function()
 local _,r=rootPart()
 if not r then info.Text="Charakter nicht bereit.";return end
 basePosition=r.Position
 info.Text=string.format("Base-Mitte gespeichert: %.0f / %.0f / %.0f",basePosition.X,basePosition.Y,basePosition.Z)
end)
-- Server-valid walking via Humanoid:MoveTo, not CFrame teleport.
-- Animal avoidance is heuristic: only identifiable NPC humanoid models are considered.
local function nearbyThreats(position)
 local threats={}
 for _,model in ipairs(workspace:GetDescendants()) do
  if model:IsA("Model") and model~=player.Character and not Players:GetPlayerFromCharacter(model) then
   local hum=model:FindFirstChildOfClass("Humanoid")
   local part=model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
   if hum and hum.Health>0 and part and (part.Position-position).Magnitude<100 then
    table.insert(threats,part.Position)
   end
  end
 end
 return threats
end
-- Mounted movement uses camera-relative WASD instead of Humanoid:MoveTo.
local heldKeys = {}
local function releaseRideKeys()
 for key in pairs(heldKeys) do
  pcall(function() VirtualInputManager:SendKeyEvent(false,key,false,game) end)
  heldKeys[key]=nil
 end
end
local function setRideKey(key,down)
 if down == (heldKeys[key] == true) then return end
 pcall(function() VirtualInputManager:SendKeyEvent(down,key,false,game) end)
 heldKeys[key]=down or nil
end
local function rideSeat(hum)
 local seat=hum and hum.SeatPart
 return seat and seat:IsA("VehicleSeat") and seat or nil
end
local function rideTowards(hum,target,token,deadline)
 local seat=hum.SeatPart
 if not seat then return false end
 local lastPos=seat.Position
 local lastProgress=os.clock()
 while active and walking and token==walkToken and os.clock()<deadline do
  if hum.SeatPart~=seat then break end
  local delta=Vector3.new(target.X-seat.Position.X,0,target.Z-seat.Position.Z)
  if delta.Magnitude<6 then releaseRideKeys();return true end
  local cam=workspace.CurrentCamera
  if not cam then break end
  local forward=Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
  if forward.Magnitude<.01 then break end
  forward=forward.Unit
  local right=Vector3.new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z).Unit
  local direction=delta.Unit
  local f=direction:Dot(forward)
  local r=direction:Dot(right)
  -- Use the dominant axis to avoid contradictory steering.
  setRideKey(Enum.KeyCode.W, f>.35)
  setRideKey(Enum.KeyCode.S, f<-.35)
  setRideKey(Enum.KeyCode.D, r>.35)
  setRideKey(Enum.KeyCode.A, r<-.35)
  if (seat.Position-lastPos).Magnitude>2 then
   lastPos=seat.Position;lastProgress=os.clock()
  elseif os.clock()-lastProgress>2.5 then break end
  task.wait(.12)
 end
 releaseRideKeys()
 return false
end
local function walkToBase(token)
 local char,root=rootPart()
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not root or not hum then info.Text="Charakter nicht bereit.";return end
 local attempts=0
 while active and walking and token==walkToken and attempts<12 do
  char,root=rootPart()
  hum=char and char:FindFirstChildOfClass("Humanoid")
  if not root or not hum or hum.Health<=0 then info.Text="Auto Walk: Charakter nicht bereit.";break end
  local seat=rideSeat(hum)
  local navPosition=seat and seat.Position or root.Position
  if (navPosition-basePosition).Magnitude<7 then
   info.Text="Base erreicht. Pruefe, ob das Ei abgegeben wurde."
   break
  end
  attempts=attempts+1
  local path=PathfindingService:CreatePath({AgentRadius=2.5,AgentHeight=5,AgentCanJump=true,WaypointSpacing=5})
  local ok=pcall(function() path:ComputeAsync(navPosition,basePosition) end)
  if not ok or path.Status~=Enum.PathStatus.Success then
   info.Text="Auto Walk: Kein Weg gefunden (Versuch "..attempts..")."
   task.wait(.5)
  else
   local blocked=false
   local conn=path.Blocked:Connect(function() blocked=true end)
   for _,waypoint in ipairs(path:GetWaypoints()) do
    if not active or not walking or token~=walkToken or blocked then break end
    local _,r=rootPart()
    if not r then break end
    local currentSeat=rideSeat(hum)
    local currentPosition=currentSeat and currentSeat.Position or r.Position
    if (currentPosition-basePosition).Magnitude<7 then break end
    local threats=nearbyThreats(currentPosition)
    local tooClose=false
    for _,pos in ipairs(threats) do
     if (pos-currentPosition).Magnitude<13 then tooClose=true;break end
    end
    if tooClose then
     info.Text="Tier/NPC in der Naehe: Route wird neu gesucht."
     blocked=true
     break
    end
    if currentSeat then
     info.Text="Reittier: WASD zur Base (Kamera nicht drehen)."
     local reached=rideTowards(hum,waypoint.Position,token,os.clock()+7)
     if not reached then blocked=true;break end
    else
     releaseRideKeys()
     if waypoint.Action==Enum.PathWaypointAction.Jump then hum.Jump=true end
     hum:MoveTo(waypoint.Position)
     local reached=false
     local done=false
     local moveConn=hum.MoveToFinished:Connect(function(success) reached=success;done=true end)
     local deadline=os.clock()+4
     while active and walking and token==walkToken and not blocked and not done and os.clock()<deadline do
      task.wait(.1)
     end
     moveConn:Disconnect()
     if not reached then blocked=true;break end
    end
   end
   conn:Disconnect()
  end
  task.wait(.15)
 end
 releaseRideKeys()
 if walking and token==walkToken and attempts>=12 then
  info.Text="Auto Walk gestoppt: Keine sichere Route gefunden."
 end
 if token==walkToken then
  walking=false
  baseTpBtn.Text="[ 4 ]  AUTO WALK BASE"
 end
end
baseTpBtn.MouseButton1Click:Connect(function()
 if walking then
  walking=false
  walkToken=walkToken+1
  releaseRideKeys()
  baseTpBtn.Text="[ 4 ]  AUTO WALK BASE"
  local char=player.Character
  local hum=char and char:FindFirstChildOfClass("Humanoid")
  local root=char and char:FindFirstChild("HumanoidRootPart")
  if hum and root then hum:MoveTo(root.Position) end
  info.Text="Auto Walk angehalten."
  return
 end
 if not basePosition then info.Text="Erst in der Base-Mitte BASE SPEICHERN druecken.";return end
 walking=true
 walkToken=walkToken+1
 local token=walkToken
 baseTpBtn.Text="[ 4 ]  WALK STOPPEN"
 info.Text="Auto Walk gestartet. Tiere/NPCs werden soweit erkennbar gemieden."
 task.spawn(function()
  local ok,err=pcall(function() walkToBase(token) end)
  if not ok then
   warn("[AUTO WALK] "..tostring(err))
   if token==walkToken then walking=false;baseTpBtn.Text="[ 4 ]  AUTO WALK BASE";info.Text="Auto Walk Fehler: "..tostring(err):sub(1,65) end
  end
 end)
end)
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
print("[SAVE THE EGG V9] Ohne TP | Scan, Auto Walk, Reittier-WASD, Auto Click, Anti-AFK")
