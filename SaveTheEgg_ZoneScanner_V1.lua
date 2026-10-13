
-- SAVE THE EGG | ZONE SCANNER V1
-- Datei: SaveTheEgg_ZoneScanner_V1.lua
-- Madium PC

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Einstellungen
local Y_OFFSET = 60
local HOLD_TIME = 1
local CLICK_DELAY = 0.08
local AUTO_TP_DELAY = 3
local EGG_WAIT_SECONDS = 4 -- Zeit beim Ei, bevor es zur Base geht

-- Alte Instanzen stoppen
if _G.SaveEggMultiStop then
    pcall(_G.SaveEggMultiStop)
end

if _G.PurplePointStop then
    pcall(_G.PurplePointStop)
end

local running = true
local autoClick = false
local autoTP = false
local clicked = {}
local lastEggKey = nil
local savedBaseCFrame = nil
local tpBusy = false
local lastScanDetails = {}
local areaAnchor = nil -- Bereich beim Aktivieren merken, nicht an der Base neu waehlen

for _, oldName in ipairs({"SaveEggMultiV14", "SaveEggMultiV15", "SaveEggMultiV16", "SaveEggZoneScannerV1"}) do
    local old = pg:FindFirstChild(oldName)
    if old then old:Destroy() end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SaveEggZoneScannerV1"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(350, 440)
frame.Position = UDim2.new(0.5, -175, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(32, 27, 44)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

local function makeLabel(text, y, height)
    local obj = Instance.new("TextLabel")
    obj.Size = UDim2.new(1, -20, 0, height)
    obj.Position = UDim2.fromOffset(10, y)
    obj.BackgroundTransparency = 1
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.Gotham
    obj.TextSize = 13
    obj.TextWrapped = true
    obj.Text = text
    obj.Parent = frame
    return obj
end

local function makeButton(text, y, color)
    local obj = Instance.new("TextButton")
    obj.Size = UDim2.new(1, -20, 0, 37)
    obj.Position = UDim2.fromOffset(10, y)
    obj.BackgroundColor3 =
        color or Color3.fromRGB(115, 65, 180)
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = 13
    obj.Text = text
    obj.Parent = frame

    Instance.new("UICorner", obj).CornerRadius =
        UDim.new(0, 8)

    return obj
end

local title = makeLabel(
    "SAVE THE EGG | ZONE SCANNER V1",
    5, 30
)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

local clickButton = makeButton(
    "Auto Click Purple Point: OFF", 42
)

local scanButton = makeButton(
    "Scan Eggs", 85,
    Color3.fromRGB(65, 125, 180)
)

local tpButton = makeButton(
    "TP Best Luck Egg", 128,
    Color3.fromRGB(65, 125, 180)
)

local autoTPButton = makeButton(
    "Auto TP Best Luck: OFF", 171,
    Color3.fromRGB(65, 145, 105)
)

local baseButton = makeButton(
    "Meine Base hier speichern", 214,
    Color3.fromRGB(110, 90, 165)
)

local clickStatus = makeLabel(
    "Purple Click: Bereit", 263, 35
)

local eggStatus = makeLabel(
    "Egg Scanner: Bereit", 300, 126
)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 25)
close.Position = UDim2.new(1, -33, 0, 4)
close.BackgroundColor3 =
    Color3.fromRGB(180, 55, 75)
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "X"
close.Parent = frame

local function stop()
    running = false
    autoClick = false
    autoTP = false

    if gui.Parent then
        gui:Destroy()
    end
end

_G.SaveEggMultiStop = stop
_G.PurplePointStop = stop

close.MouseButton1Click:Connect(stop)

-- ==================================
-- AUTO PURPLE CLICKER
-- ==================================

local function isVisible(obj)
    if not obj:IsA("GuiObject") then
        return false
    end

    if obj.AbsoluteSize.X < 5
        or obj.AbsoluteSize.Y < 5 then
        return false
    end

    local current = obj

    while current and current ~= pg do
        if current:IsA("GuiObject")
            and not current.Visible then
            return false
        end

        if current:IsA("ScreenGui")
            and not current.Enabled then
            return false
        end

        current = current.Parent
    end

    return true
end

local function getCircleTarget(obj)
    local parent = obj.Parent

    if parent then
        local tap = parent:FindFirstChild("Tap")

        if tap and isVisible(tap) then
            return tap
        end

        local hit = parent:FindFirstChild("Hit")

        if hit and isVisible(hit) then
            return hit
        end
    end

    return obj
end

local function findPurpleTargets()
    local result = {}

    for _, obj in ipairs(pg:GetDescendants()) do
        if obj.Name == "Tap2"
            and isVisible(obj)
            and not obj:IsDescendantOf(gui) then
            table.insert(result, obj)
        end
    end

    return result
end

local function purpleClick(x, y)
    if type(mousemoveabs) == "function" then
        mousemoveabs(x, y)
    end

    task.wait(0.15)

    VIM:SendMouseButtonEvent(
        x, y, 0, true, game, 0
    )

    task.wait(HOLD_TIME)

    VIM:SendMouseButtonEvent(
        x, y, 0, false, game, 0
    )
end

clickButton.MouseButton1Click:Connect(function()
    autoClick = not autoClick
    table.clear(clicked)

    clickButton.Text = autoClick
        and "Auto Click Purple Point: ON"
        or "Auto Click Purple Point: OFF"

    clickStatus.Text = autoClick
        and "Purple Click: Suche ..."
        or "Purple Click: Pausiert"
end)

task.spawn(function()
    while running do
        if autoClick then
            local targets = findPurpleTargets()
            local visibleNow = {}

            for _, obj in ipairs(targets) do
                visibleNow[obj] = true

                local target = getCircleTarget(obj)
                local pos = target.AbsolutePosition
                local size = target.AbsoluteSize

                local x = math.floor(
                    pos.X + size.X / 2
                )

                local y = math.floor(
                    pos.Y + size.Y / 2 + Y_OFFSET
                )

                local signature = x .. ":" .. y

                if clicked[obj] ~= signature then
                    local ok, err = pcall(function()
                        purpleClick(x, y)
                    end)

                    if ok then
                        clicked[obj] = signature
                        clickStatus.Text =
                            "Purple Click: Klick gesendet"
                    else
                        clickStatus.Text =
                            "Klickfehler: "
                            .. tostring(err):sub(1, 50)
                    end

                    break
                end
            end

            for obj in pairs(clicked) do
                if not visibleNow[obj] then
                    clicked[obj] = nil
                end
            end

            if #targets == 0 then
                clickStatus.Text =
                    "Purple Click: Warte auf Kreis ..."
            end
        end

        task.wait(CLICK_DELAY)
    end
end)

-- ==================================
-- VERBESSERTER EGG SCANNER
-- ==================================

local function parseNumber(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = text:gsub(",", "")
    cleaned = cleaned:gsub("%s+", "")

    local number, suffix =
        cleaned:match("^([%d%.]+)([KkMmBbTt]?)$")

    if not number then
        return nil
    end

    local value = tonumber(number)
    if not value then
        return nil
    end

    local mult = {
        K = 1e3,
        M = 1e6,
        B = 1e9,
        T = 1e12
    }

    return value *
        (mult[string.upper(suffix or "")] or 1)
end

local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Attachment") then
        return obj.WorldPosition
    end

    if obj:IsA("Model") then
        local ok, pivot = pcall(function()
            return obj:GetPivot()
        end)

        if ok then
            return pivot.Position
        end
    end

    return nil
end

local function findEggRoot(obj)
    local current = obj
    local depth = 0

    while current
        and current ~= workspace
        and depth < 8 do

        local lower = string.lower(current.Name)

        if lower:find("egg", 1, true)
            and (
                current:IsA("Model")
                or current:IsA("BasePart")
            ) then

            return current
        end

        current = current.Parent
        depth = depth + 1
    end

    return nil
end

-- V14: Die Luck-Anzeige eines echten Eis liegt unter
-- EggRoot.WeightBadge.Luck (aus Madium-Diagnose).
-- Nichts ausserhalb des zugehoerigen Eis als Luck interpretieren.
local function isUpgradeObject(obj)
    local current = obj
    while current and current ~= workspace do
        local name = current.Name:lower():gsub("%s+", "")
        if name:find("hatchluck", 1, true)
            or name:find("upgrades", 1, true)
            or name:find("luckupgrade", 1, true) then
            return true
        end
        current = current.Parent
    end
    return false
end

local function getEggRootFromPrompt(prompt)
    -- Wichtig: nicht im gesamten Workspace nach irgendeinem "Luck" suchen.
    -- Nur die direkten Vorfahren des Pick-Up-Prompts durchgehen.
    local current = prompt.Parent
    local depth = 0
    while current and current ~= workspace and depth < 9 do
        if current.Name == "EggRoot" then
            return current
        end
        current = current.Parent
        depth += 1
    end
    return nil
end

local function readLuck(eggRoot)
    local badge = eggRoot:FindFirstChild("WeightBadge")
    if not badge then return nil end
    local luckLabel = badge:FindFirstChild("Luck", true)
    if not luckLabel then return nil end

    if luckLabel:IsA("TextLabel") or luckLabel:IsA("TextButton") then
        return parseNumber(luckLabel.Text)
    end
    -- Falls "Luck" ein Container und die Zahl darunter ist:
    for _, child in ipairs(luckLabel:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local value = parseNumber(child.Text)
            if value then return value end
        end
    end
    return nil
end

local function getEggPosition(eggRoot, prompt)
    -- Position vom Ei, nicht von einem globalen Menue oder Upgrade-Schild.
    local pos = getPosition(eggRoot)
    if pos then return pos end
    local current = prompt.Parent
    while current and current ~= eggRoot.Parent do
        pos = getPosition(current)
        if pos then return pos end
        current = current.Parent
    end
    local part = eggRoot:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position or nil
end

-- Bekannte Mindest-Jump-Werte aus dem Spiel.
-- Weitere bekannte Eier kannst du hier eintragen.
local REQUIRED_JUMP_BY_EGG = {
    ["desert egg"] = 5.2e6,
}

-- Liest den eigenen Jump-Wert, nicht den Wert der Eier.
-- In verschiedenen Spielversionen kann er in leaderstats, Attributes
-- oder als Bildschirmanzeige liegen.
local function getPlayerJump()
    local function fromValue(container)
        if not container then return nil end
        for _, obj in ipairs(container:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("jump", 1, true))
                and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                if obj.Value >= 0 then return obj.Value end
            end
        end
        for key, value in pairs(container:GetAttributes()) do
            local name = tostring(key):lower()
            if type(value) == "number" and value >= 0
                and (name:find("jump", 1, true)) then
                return value
            end
        end
        return nil
    end

    local value = fromValue(player:FindFirstChild("leaderstats"))
        or fromValue(player:FindFirstChild("Data"))
        or fromValue(player)
    if value then return value end

    local candidates = {}
    for _, label in ipairs(pg:GetDescendants()) do
        if label:IsA("TextLabel") and not label:IsDescendantOf(gui) then
            local v = parseNumber(label.Text)
            if v then
                local context = (label.Name .. " " .. (label.Parent and label.Parent.Name or "")):lower()
                if context:find("jump", 1, true) then
                    table.insert(candidates, v)
                end
            end
        end
    end
    if #candidates == 1 then return candidates[1] end
    return nil
end

local function readDisplayedJumpRequirements()
    local markers = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = (obj.Text or ""):lower()
            local amount = text:match("reach%s+([%d%.]+%s*[kmbt]?)%s+jump")
            if amount then
                local required = parseNumber(amount)
                if required then
                    -- GUI muss einer Position in der Welt zuordenbar sein.
                    local pos = nil
                    local current = obj.Parent
                    for _ = 1, 10 do
                        if not current or current == workspace then break end
                        pos = getPosition(current)
                        if pos then break end
                        if current:IsA("BillboardGui") or current:IsA("SurfaceGui") then
                            local adornee = current.Adornee
                            if adornee then pos = getPosition(adornee) end
                            if pos then break end
                        end
                        current = current.Parent
                    end
                    if pos then table.insert(markers, {position = pos, required = required}) end
                end
            end
        end
    end
    return markers
end

-- Strikte Bereichserkennung: Wir vergleichen den Boden unter dem Spieler
-- mit dem Boden unter jedem Ei, nicht mit dem naechsten Ei (das kann
-- bereits eine Etage hoeher sein!). Lieber kein Ziel als falsche Etage.
local AREA_FLOOR_TOLERANCE = 5 -- Studs zwischen Ebenen
local AREA_RADIUS = 650 -- weitere Eier derselben Ebene beruecksichtigen

local function floorAt(position, ignore)
    if not position then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore or {}
    local start = position + Vector3.new(0, 2, 0)
    local cast = workspace:Raycast(start, Vector3.new(0, -65, 0), params)
    if cast and cast.Normal.Y > 0.65 then
        return cast.Position.Y
    end
    return nil
end

local function getPlayerAreaAnchor()
    local character = player.Character
    local root = character and character:FindFirstChild('HumanoidRootPart')
    if not root then return nil end
    local y = floorAt(root.Position, {character})
    if not y then return nil end
    return {position = root.Position, floorY = y}
end

local function inArea(entry, anchor)
    if not anchor or not entry.position or not entry.floorY then return false end
    local d = entry.position - anchor.position
    local distance = Vector3.new(d.X, 0, d.Z).Magnitude
    return math.abs(entry.floorY - anchor.floorY) <= AREA_FLOOR_TOLERANCE
        and distance <= AREA_RADIUS
end

local function findBestLuckEgg(referenceAnchor)
    local best, bestLuck, count = nil, -1, 0
    local seen = {}
    local jump = getPlayerJump()
    local markers = readDisplayedJumpRequirements()
    local eligible = 0
    local skipped = 0
    local unverified = 0
    local details = {}

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local action = (prompt.ActionText or ""):lower()
            local label = (prompt.ObjectText or ""):lower()
            local isPickup = action:find("pick", 1, true)
                or action:find("collect", 1, true)
            local isEgg = label:find("egg", 1, true)
            if isPickup and isEgg and not isUpgradeObject(prompt) then
                local eggRoot = getEggRootFromPrompt(prompt)
                if eggRoot and not seen[eggRoot] then
                    seen[eggRoot] = true
                    count += 1
                    local luck = readLuck(eggRoot)
                    local pos = getEggPosition(eggRoot, prompt)
                    local required = REQUIRED_JUMP_BY_EGG[label]

                    -- Dynamisch erkennen, wenn ein Mindestwert am Ei/der Zone
                    -- als Attribut hinterlegt ist.
                    for _, source in ipairs({prompt, eggRoot, eggRoot.Parent}) do
                        if source then
                            for key, v in pairs(source:GetAttributes()) do
                                local keyLower = tostring(key):lower()
                                if keyLower:find("required", 1, true)
                                    and (keyLower:find("jump", 1, true)) then
                                    local parsed = type(v) == "number" and v or parseNumber(tostring(v))
                                    if parsed and parsed >= 0 then
                                        required = math.max(required or 0, parsed)
                                    end
                                end
                            end
                        end
                    end

                    -- Nur sehr nahe Markierungen zuordnen; nicht blind jede
                    -- Zone dem naechsten Egg zuweisen.
                    if pos then
                        for _, marker in ipairs(markers) do
                            if (pos - marker.position).Magnitude < 28 then
                                required = math.max(required or 0, marker.required)
                            end
                        end
                    end

                    local entry = {name = prompt.ObjectText, luck = luck, required = required, position = pos, floorY = floorAt(pos, player.Character and {player.Character, eggRoot} or {eggRoot}), status = "unknown"}
                    table.insert(details, entry)
                    -- Bereich erst bestimmen, nachdem alle Eier erfasst wurden.
                    entry.status = "pending"

                end
            end
        end
    end
    local anchor = referenceAnchor or getPlayerAreaAnchor()
    for _, entry in ipairs(details) do
        if not inArea(entry, anchor) then
            entry.status = "andere Ebene / ueber 650 Studs"
        elseif jump == nil then
            -- Im gleichen Bereich vorsichtig zulassen; Spielerwert unbekannt.
            entry.status = "jump unbekannt / ungeprueft"
            unverified += 1
            if entry.luck and entry.position and entry.luck > bestLuck then
                bestLuck = entry.luck
                best = {position = entry.position, luck = entry.luck,
                    name = entry.name, required = entry.required}
            end
        elseif entry.required and jump < entry.required then
            entry.status = "locked"
            skipped += 1
        elseif entry.luck and entry.position then
            entry.status = entry.required and "eligible" or "unverified"
            if not entry.required then unverified += 1 end
            eligible += 1
            if entry.luck > bestLuck then
                bestLuck = entry.luck
                best = {position = entry.position, luck = entry.luck,
                    name = entry.name, required = entry.required}
            end
        else
            entry.status = "kein Luck-Wert"
        end
    end
    table.sort(details, function(a,b) return (a.luck or -1) > (b.luck or -1) end)
    lastScanDetails = details
    return best, count, jump, skipped, unverified, anchor
end

local function showJump(value)
    if not value then return "nicht erkannt" end
    if value >= 1e6 then return string.format("%.2fM", value / 1e6) end
    if value >= 1e3 then return string.format("%.2fK", value / 1e3) end
    return tostring(math.floor(value))
end

local function scanEggs(referenceAnchor)
    local best, count, jump, skipped, unverified, anchor = findBestLuckEgg(referenceAnchor)
    print("[Zone V1] Scan: " .. count .. " Eier; Jump " .. showJump(jump) .. "; Bereich Hoehe " .. (anchor and string.format("%.1f",anchor.floorY) or "unbekannt"))
    for i = 1, math.min(30, #lastScanDetails) do
        local e = lastScanDetails[i]
        print(string.format("[Egg V14] #%d %s | Luck %s | Mindest-Jump %s | %s", i, e.name, showJump(e.luck), showJump(e.required), e.status))
    end
    if best then
        eggStatus.Text = "Bereich: " .. (anchor and string.format("Boden Y %.0f", anchor.floorY) or "unbekannt")
            .. " | Jump: " .. showJump(jump)
            .. " | Eier: " .. count
            .. "\nBestes moegliches Ei: " .. best.name
            .. " | Luck: " .. showJump(best.luck)
            .. "\nGesperrt: " .. skipped .. " | Ungeprueft: " .. unverified
    else
        eggStatus.Text = "Bereich: " .. (anchor and string.format("Boden Y %.0f", anchor.floorY) or "unbekannt")
            .. " | Jump: " .. showJump(jump)
            .. " | Eier: " .. count
            .. "\nKein Ei auf deinem Boden-Niveau gefunden."
            .. "\nGesperrt: " .. skipped .. " | Ungeprueft: " .. unverified
    end
    return best
end

-- Sichere Position auf freiem Boden seitlich neben dem Ei finden.
-- Ein groesserer Abstand vermeidet Kollisionen mit dem getragenen Pet.
local function safeLanding(eggPosition, character)
    -- Nah am Ei bleiben: weit entfernte Landungen liegen oft ausserhalb
    -- der Reichweite des Pick-Up-Prompts.
    local offsets = {
        Vector3.new(4, 0, 0), Vector3.new(-4, 0, 0),
        Vector3.new(0, 0, 4), Vector3.new(0, 0, -4),
        Vector3.new(6, 0, 0), Vector3.new(-6, 0, 0)
    }
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    for _, offset in ipairs(offsets) do
        local probe = eggPosition + offset
        local hit = workspace:Raycast(probe + Vector3.new(0, 12, 0), Vector3.new(0, -35, 0), params)
        if hit and hit.Normal.Y > 0.7 and hit.Position.Y <= eggPosition.Y + 3 then
            return CFrame.new(hit.Position + Vector3.new(0, 4.5, 0), eggPosition)
        end
    end
    return CFrame.new(eggPosition + Vector3.new(4, 5, 0), eggPosition)
end

local function getCharacterRoot()
    local char = player.Character
    return char, char and char:FindFirstChild("HumanoidRootPart")
end

local function isMyBaseOwner(obj)
    -- Nur eine eindeutige Zuordnung benutzen, sonst versehentlich fremde Base.
    local matchingNames = {Owner = true, OwnerName = true, PlayerName = true, UserId = true, OwnerUserId = true}
    for name in pairs(matchingNames) do
        local val = obj:GetAttribute(name)
        if val ~= nil and (tostring(val) == player.Name or tostring(val) == tostring(player.UserId)) then
            return true
        end
        local child = obj:FindFirstChild(name)
        if child and child:IsA("ValueBase") then
            local v = child.Value
            if v == player or tostring(v) == player.Name or tostring(v) == tostring(player.UserId) then
                return true
            end
        end
    end
    return false
end

local function discoverBase()
    -- Nicht irgendeine "Base" waehlen: nur eindeutig zugewiesene Plots.
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart"))
            and (obj.Name:lower():find("base", 1, true) or obj.Name:lower():find("plot", 1, true))
            and isMyBaseOwner(obj) then
            local pos = getPosition(obj)
            if pos then return CFrame.new(pos + Vector3.new(0, 7, 0)) end
        end
    end
    return nil
end

baseButton.MouseButton1Click:Connect(function()
    local _, root = getCharacterRoot()
    if not root then
        eggStatus.Text = "Base: Charakter nicht bereit"
        return
    end
    savedBaseCFrame = root.CFrame
    baseButton.Text = "Base gespeichert!"
    eggStatus.Text = "Base gespeichert. Auto TP bringt dich nach dem Ei hierher zurueck."
end)

local function getHome()
    return savedBaseCFrame or discoverBase()
end

local function teleportTo(cf)
    local char, root = getCharacterRoot()
    if not char or not root then return false, "Charakter nicht bereit" end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Sit then humanoid.Sit = false end
    local ok, err = pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        char:PivotTo(cf)
    end)
    return ok, err
end

local function teleportBest(automatic)
    if tpBusy then return end
    tpBusy = true
    local egg = scanEggs(automatic and areaAnchor or nil)
    if not egg then tpBusy = false; return end
    local home = automatic and getHome() or nil
    if automatic and not home then
        eggStatus.Text = "Base nicht gefunden! Stelle dich auf deine Base und druecke 'Meine Base hier speichern'."
        tpBusy = false
        return
    end

    local char, root = getCharacterRoot()
    if not root then
        eggStatus.Text = "TP: Charakter nicht bereit"
        tpBusy = false
        return
    end

    local destination = safeLanding(egg.position, char)
    local ok, err = teleportTo(destination)
    if not ok then
        eggStatus.Text = "TP Fehler: " .. tostring(err):sub(1, 80)
        tpBusy = false
        return
    end
    eggStatus.Text = "TP-Versuch: " .. egg.name .. " | Luck: " .. showJump(egg.luck)

    -- Wird die Position vom Server zurueckgesetzt, nicht staendig neu teleportieren.
    task.wait(0.8)
    local _, currentRoot = getCharacterRoot()
    if not currentRoot or (currentRoot.Position - destination.Position).Magnitude > 17 then
        autoTP = false
        autoTPButton.Text = "Auto TP Best Luck: OFF"
        eggStatus.Text = "TP vom Spiel zurueckgesetzt. Server erlaubt Position eventuell nicht."
        tpBusy = false
        return
    end

    if automatic and autoTP and running then
        eggStatus.Text = "Beim Ei: " .. egg.name .. " | Danach zur Base"
        task.wait(EGG_WAIT_SECONDS)
        if autoTP and running then
            -- Bei der Rueckkehr etwas hoeher landen, falls ein Pet getragen wird.
            local returnCF = home + Vector3.new(0, 4, 0)
            local backOK, backErr = teleportTo(returnCF)
            eggStatus.Text = backOK and "Zur Base zurueck. Naechstes Ei wird gesucht ..."
                or ("Rueckkehr fehlgeschlagen: " .. tostring(backErr))
        end
    end
    tpBusy = false
end

scanButton.MouseButton1Click:Connect(function()
    scanEggs()
end)

tpButton.MouseButton1Click:Connect(function()
    task.spawn(function() teleportBest(false) end)
end)

autoTPButton.MouseButton1Click:Connect(function()
    autoTP = not autoTP
    if autoTP then
        -- Die Position des Spielers ist die Bereichsreferenz, nicht das
        -- naechste Ei (das koennte bereits in der naechsten Welt sein).
        areaAnchor = getPlayerAreaAnchor()
        if not areaAnchor then
            autoTP = false
            eggStatus.Text = "Bereich nicht erkennbar: Stelle dich auf festen Boden und starte Auto TP erneut."
        end
    else
        areaAnchor = nil
    end
    autoTPButton.Text = autoTP
        and "Auto TP Best Luck: ON"
        or "Auto TP Best Luck: OFF"
    if areaAnchor or not autoTP then
        eggStatus.Text = autoTP
            and "Auto TP: Suche Ei in dieser Ebene ..."
            or "Auto TP: Pausiert"
    end
end)

task.spawn(function()
    while running do
        if autoTP and not tpBusy then
            teleportBest(true)
        end
        task.wait(AUTO_TP_DELAY)
    end
end)
