
-- SAVE THE EGG | MULTI MENU V15
-- Datei: SaveTheEgg_MultiMenu_V14.lua
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

local old = pg:FindFirstChild("SaveEggMultiV15")
if old then
    old:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SaveEggMultiV15"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(350, 365)
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
    "SAVE THE EGG | MULTI MENU V15",
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

local clickStatus = makeLabel(
    "Purple Click: Bereit", 220, 35
)

local eggStatus = makeLabel(
    "Egg Scanner: Bereit", 258, 85
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

local function getLuckFromGui(root)
    local hasLuckIcon = false
    local bestNumber = nil

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextLabel")
            or obj:IsA("TextButton") then

            local txt = obj.Text or ""
            local lower = string.lower(txt)

            if txt:find("🍀", 1, true)
                or lower:find("luck", 1, true) then

                hasLuckIcon = true
            end

            local value = parseNumber(txt)

            if value and (
                not bestNumber
                or value > bestNumber
            ) then
                bestNumber = value
            end
        end
    end

    if hasLuckIcon then
        return bestNumber
    end

    return nil
end

local function findBestLuckEgg()
    local best = nil
    local bestLuck = -1
    local eggCount = 0

    local seen = {}

    for _, obj in ipairs(
        workspace:GetDescendants()
    ) do

        if obj:IsA("ProximityPrompt")
            and obj.Enabled then

            local action =
                string.lower(obj.ActionText or "")

            local objectText =
                string.lower(obj.ObjectText or "")

            local root = findEggRoot(obj.Parent)

            local isEgg =
                root ~= nil
                or objectText:find("egg", 1, true)

            local isPickup =
                action:find("pick", 1, true)
                or action:find("collect", 1, true)

            if isEgg and isPickup then
                local target = root or obj.Parent

                if target and not seen[target] then
                    seen[target] = true
                    eggCount = eggCount + 1

                    local luck = getLuckFromGui(target)

                    if luck and luck > bestLuck then
                        local pos = getPosition(target)

                        if not pos then
                            local part =
                                target:FindFirstChildWhichIsA(
                                    "BasePart", true
                                )

                            if part then
                                pos = part.Position
                            end
                        end

                        if pos then
                            bestLuck = luck

                            best = {
                                position = pos,
                                luck = luck,
                                name = target.Name
                            }
                        end
                    end
                end
            end
        end
    end

    return best, eggCount
end

local function scanEggs()
    local best, count = findBestLuckEgg()

    if best then
        eggStatus.Text =
            "Bestes Ei: " .. best.name
            .. "\nLuck: " .. tostring(best.luck)
            .. " | Eier gefunden: " .. count
    else
        eggStatus.Text =
            "Eier erkannt: " .. count
            .. "\nKein auslesbarer Luck-Wert."
    end

    return best
end

local function teleportBest()
    local character = player.Character
    local root = character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        eggStatus.Text =
            "Egg TP: Charakter nicht bereit"
        return
    end

    local egg = scanEggs()

    if not egg then
        return
    end

    local key = tostring(egg.position)
        .. ":" .. tostring(egg.luck)

    if autoTP and key == lastEggKey then
        return
    end

    local ok, err = pcall(function()
        root.CFrame = CFrame.new(
            egg.position + Vector3.new(0, 3, 0)
        )
    end)

    if ok then
        lastEggKey = key

        eggStatus.Text =
            "TP versucht: " .. egg.name
            .. "\nLuck: " .. tostring(egg.luck)
    else
        eggStatus.Text =
            "TP Fehler: "
            .. tostring(err):sub(1, 70)
    end
end

scanButton.MouseButton1Click:Connect(function()
    scanEggs()
end)

tpButton.MouseButton1Click:Connect(function()
    lastEggKey = nil
    teleportBest()
end)

autoTPButton.MouseButton1Click:Connect(function()
    autoTP = not autoTP
    lastEggKey = nil

    autoTPButton.Text = autoTP
        and "Auto TP Best Luck: ON"
        or "Auto TP Best Luck: OFF"

    eggStatus.Text = autoTP
        and "Auto TP: Suche Eier ..."
        or "Auto TP: Pausiert"
end)

task.spawn(function()
    while running do
        if autoTP then
            teleportBest()
        end

        task.wait(AUTO_TP_DELAY)
    end
end)
