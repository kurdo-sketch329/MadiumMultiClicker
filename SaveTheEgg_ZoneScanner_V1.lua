-- Save The Egg | ZoneScanner V2
-- Based on the visible structure of V1; separate file, V1 remains unchanged.
-- Client-side diagnosis only: the game's server can reject teleport and pickup.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local pg = player:WaitForChild('PlayerGui')
if _G.SaveEggZoneV2Stop then pcall(_G.SaveEggZoneV2Stop) end
local old = pg:FindFirstChild('SaveEggZoneV2')
if old then old:Destroy() end

local running, auto, busy = true, false, false
local homeCF, lockedZone, lastEgg = nil, nil, nil
local ZONE_Y_TOLERANCE, MAX_ZONE_DISTANCE = 4.5, 350
local WAIT_AT_EGG, BETWEEN_TRIPS = 4, 3

local gui = Instance.new('ScreenGui')
gui.Name = 'SaveEggZoneV2'; gui.ResetOnSpawn = false; gui.Parent = pg
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(375, 360)
frame.Position = UDim2.new(.5,-187,.18,0)
frame.BackgroundColor3 = Color3.fromRGB(35,29,52)
frame.BorderSizePixel = 0; frame.Active = true; frame.Draggable = true; frame.Parent = gui
Instance.new('UICorner',frame).CornerRadius = UDim.new(0,10)
local function label(txt,y,h)
    local x=Instance.new('TextLabel'); x.Size=UDim2.new(1,-20,0,h)
    x.Position=UDim2.fromOffset(10,y); x.BackgroundTransparency=1
    x.TextColor3=Color3.new(1,1,1); x.Font=Enum.Font.Gotham
    x.TextSize=13; x.TextWrapped=true; x.Text=txt; x.Parent=frame; return x
end
local function button(txt,y)
    local x=Instance.new('TextButton'); x.Size=UDim2.new(1,-20,0,35)
    x.Position=UDim2.fromOffset(10,y); x.BackgroundColor3=Color3.fromRGB(92,82,159)
    x.TextColor3=Color3.new(1,1,1); x.Font=Enum.Font.GothamBold
    x.TextSize=13; x.Text=txt; x.Parent=frame
    Instance.new('UICorner',x).CornerRadius=UDim.new(0,7); return x
end
local head=label('SAVE THE EGG | ZONE SCANNER V2',4,27)
head.Font=Enum.Font.GothamBold; head.TextSize=15
local scanB=button('Scan: bestes Ei in meinem Bereich',37)
local tpB=button('TP Best Egg (einmal)',78)
local homeB=button('Meine Base HIER speichern',119)
local testHomeB=button('Test: TP zur gespeicherten Base',160)
local autoB=button('Auto Ei -> Base: AUS',201)
local status=label('Bitte zuerst auf der Base speichern, dann in deinen Ei-Bereich gehen und Scan druecken.',248,97)
local x=Instance.new('TextButton'); x.Size=UDim2.fromOffset(25,23)
x.Position=UDim2.new(1,-30,0,4); x.Text='X'; x.TextColor3=Color3.new(1,1,1)
x.BackgroundColor3=Color3.fromRGB(170,60,70); x.Parent=frame

local function stop()
    running=false; auto=false
    if gui.Parent then gui:Destroy() end
end
_G.SaveEggZoneV2Stop=stop
x.MouseButton1Click:Connect(stop)
local function fmt(n)
    if not n then return '?' end
    if n>=1e12 then return string.format('%.2fT',n/1e12) end
    if n>=1e9 then return string.format('%.2fB',n/1e9) end
    if n>=1e6 then return string.format('%.2fM',n/1e6) end
    if n>=1e3 then return string.format('%.2fK',n/1e3) end
    return tostring(math.floor(n*100)/100)
end
local function num(s)
    if type(s)~='string' then return nil end
    local a,b=s:gsub('[,%s]',''):match('^([%d%.]+)([kKmMbBtT]?)$')
    if not a then return nil end
    local m={K=1e3,M=1e6,B=1e9,T=1e12}
    return tonumber(a)*(m[b:upper()] or 1)
end
local function charRoot()
    local c=player.Character
    return c,c and c:FindFirstChild('HumanoidRootPart')
end
local function ground(pos,ignore)
    local p=RaycastParams.new()
    p.FilterType=Enum.RaycastFilterType.Exclude
    p.FilterDescendantsInstances=ignore or {}
    local hit=workspace:Raycast(pos+Vector3.new(0,3,0),Vector3.new(0,-85,0),p)
    return hit and hit.Normal.Y>.65 and hit.Position.Y or nil
end
local function zoneAtPlayer()
    local c,r=charRoot(); if not r then return nil end
    local y=ground(r.Position,{c})
    if not y then return nil end
    return {floorY=y,center=Vector3.new(r.Position.X,0,r.Position.Z)}
end
local function getEggRoot(prompt)
    local p=prompt.Parent
    for _=1,10 do
        if not p or p==workspace then return nil end
        if p.Name=='EggRoot' then return p end
        p=p.Parent
    end
end
local function eggPosition(root,prompt)
    local part=prompt.Parent
    while part and part~=root.Parent do
        if part:IsA('BasePart') then return part.Position end
        if part:IsA('Attachment') then return part.WorldPosition end
        part=part.Parent
    end
    if root:IsA('BasePart') then return root.Position end
    if root:IsA('Model') then
        local ok,pivot=pcall(function() return root:GetPivot() end)
        if ok then return pivot.Position end
    end
    local fallback=root:FindFirstChildWhichIsA('BasePart',true)
    return fallback and fallback.Position
end
local function readLuck(root)
    local badge=root:FindFirstChild('WeightBadge')
    local luck=badge and badge:FindFirstChild('Luck',true)
    if not luck then return nil end
    if luck:IsA('TextLabel') or luck:IsA('TextButton') then return num(luck.Text) end
    for _,item in ipairs(luck:GetDescendants()) do
        if item:IsA('TextLabel') or item:IsA('TextButton') then
            local v=num(item.Text); if v then return v end
        end
    end
end
local function scan(zone)
    zone=zone or zoneAtPlayer()
    if not zone then status.Text='Kein sicherer Boden erkannt. Stelle dich auf eine feste Ebene.'; return nil end
    local eggs, seen, total, missing, different= {},{},0,0,0
    for _,prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA('ProximityPrompt') and prompt.Enabled then
            local act=(prompt.ActionText or ''):lower()
            local name=(prompt.ObjectText or '')
            if name:lower():find('egg',1,true) and (act:find('pick',1,true) or act:find('collect',1,true)) then
                local root=getEggRoot(prompt)
                if root and not seen[root] then
                    seen[root]=true; total+=1
                    local pos=eggPosition(root,prompt)
                    local luck=readLuck(root)
                    local floor=pos and ground(pos,{root,player.Character})
                    local horiz=pos and (Vector3.new(pos.X,0,pos.Z)-zone.center).Magnitude
                    if not luck or not floor then
                        missing+=1
                    elseif math.abs(floor-zone.floorY)<=ZONE_Y_TOLERANCE and horiz<=MAX_ZONE_DISTANCE then
                        table.insert(eggs,{name=name,luck=luck,position=pos,prompt=prompt,root=root,floor=floor})
                    else
                        different+=1
                    end
                end
            end
        end
    end
    table.sort(eggs,function(a,b) return a.luck>b.luck end)
    print(string.format('[Zone V2] Boden Y %.1f | %d geladen | %d hier | %d anders | %d unbekannt',zone.floorY,total,#eggs,different,missing))
    for i,e in ipairs(eggs) do
        print(string.format('[Zone V2] #%d %s | Luck %s | Y %.1f',i,e.name,fmt(e.luck),e.floor))
    end
    local best=eggs[1]
    if best then
        status.Text='Bereich Boden Y '..math.floor(zone.floorY)..' | '..#eggs..' passende Eier (geladen)'
            ..'\nBESTES: '..best.name..' | Luck '..fmt(best.luck)
            ..'\nKonsole: Rangliste. Nicht geladene Eier fehlen.'
    else
        status.Text='Kein Ei mit lesbarem Luck in diesem Bereich. Geladen: '..total
            ..' | Andere Ebene: '..different..' | Unklar: '..missing
    end
    lastEgg=best
    return best
end
local function teleport(cf)
    local c,r=charRoot()
    if not c or not r then return false,'Charakter nicht bereit' end
    local hum=c:FindFirstChildOfClass('Humanoid')
    if hum and hum.Sit then hum.Sit=false end
    local ok,err=pcall(function()
        r.AssemblyLinearVelocity=Vector3.zero
        r.AssemblyAngularVelocity=Vector3.zero
        c:PivotTo(cf)
    end)
    if not ok then return false,tostring(err) end
    task.wait(.7)
    local _,rr=charRoot()
    if not rr or (rr.Position-cf.Position).Magnitude>17 then
        return false,'Spiel hat TP zurueckgesetzt oder Charakter bewegt'
    end
    return true
end
local function landing(egg)
    local c=player.Character
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={c,egg.root}
    -- Only choose stable ground nearby, never inside the egg or underneath the floor.
    for _,offset in ipairs({Vector3.new(4,0,0),Vector3.new(-4,0,0),Vector3.new(0,0,4),Vector3.new(0,0,-4)}) do
        local p=egg.position+offset
        local hit=workspace:Raycast(p+Vector3.new(0,10,0),Vector3.new(0,-30,0),params)
        if hit and hit.Normal.Y>.7 and math.abs(hit.Position.Y-egg.floor)<5 then
            return CFrame.new(hit.Position+Vector3.new(0,4,0),egg.position)
        end
    end
    return CFrame.new(egg.position+Vector3.new(0,5,0))
end
local function runTrip(isAuto)
    if busy then return end
    busy=true
    local egg=scan(isAuto and lockedZone or nil)
    if not egg then busy=false; return end
    if isAuto and not homeCF then
        status.Text='Speichere zuerst deine Base mit dem Base-Knopf.'
        auto=false; autoB.Text='Auto Ei -> Base: AUS'; busy=false; return
    end
    local ok,err=teleport(landing(egg))
    if not ok then
        status.Text='Ei-TP fehlgeschlagen: '..err
        if isAuto then auto=false; autoB.Text='Auto Ei -> Base: AUS' end
        busy=false; return
    end
    status.Text='Beim Ei: '..egg.name..' | Luck '..fmt(egg.luck)
        ..'\nHinweis: Einsammeln wird NICHT automatisch bestaetigt.'
    if isAuto and running and auto then
        task.wait(WAIT_AT_EGG)
        if running and auto then
            -- Saved CFrame is the player's chosen safe location, not a guessed plot.
            local back,why=teleport(homeCF)
            if back then
                status.Text='Zur gespeicherten Base teleportiert.\nBitte pruefen, ob das Ei eingesammelt wurde.'
            else
                status.Text='Base-TP fehlgeschlagen: '..why
                auto=false; autoB.Text='Auto Ei -> Base: AUS'
            end
        end
    end
    busy=false
end
scanB.MouseButton1Click:Connect(function() scan() end)
tpB.MouseButton1Click:Connect(function() task.spawn(runTrip,false) end)
homeB.MouseButton1Click:Connect(function()
    local _,root=charRoot()
    if not root then status.Text='Charakter nicht bereit'; return end
    homeCF=root.CFrame
    homeB.Text='Base gespeichert!'
    status.Text='Base gespeichert bei Y '..math.floor(root.Position.Y)
        ..'. Teste den Base-TP vor Auto.'
end)
testHomeB.MouseButton1Click:Connect(function()
    if busy then return end
    if not homeCF then status.Text='Erst Base speichern!'; return end
    task.spawn(function()
        busy=true
        local ok,why=teleport(homeCF)
        status.Text=ok and 'Base-Test erfolgreich (Position erreicht).' or ('Base-Test fehlgeschlagen: '..why)
        busy=false
    end)
end)
autoB.MouseButton1Click:Connect(function()
    if auto then
        auto=false; lockedZone=nil; autoB.Text='Auto Ei -> Base: AUS'
        status.Text='Auto deaktiviert.'
        return
    end
    if not homeCF then status.Text='Zuerst auf deiner Base "Base speichern" klicken.'; return end
    lockedZone=zoneAtPlayer()
    if not lockedZone then status.Text='Bereich nicht erkannt. Auf festen Boden stellen.'; return end
    auto=true; autoB.Text='Auto Ei -> Base: AN'
    status.Text='Bereich gespeichert. Suche Eier auf Boden Y '..math.floor(lockedZone.floorY)
end)
task.spawn(function()
    while running do
        if auto and not busy then
            local ok,err=pcall(runTrip,true)
            if not ok then
                auto=false; busy=false; autoB.Text='Auto Ei -> Base: AUS'
                status.Text='Scriptfehler: '..tostring(err):sub(1,110)
            end
        end
        task.wait(BETWEEN_TRIPS)
    end
end)
