
-- SAVE THE EGG | MULTI MENU V14
-- Madium PC
-- Auto Purple Click + Best Luck Egg Teleport

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local Y_OFFSET = 60
local HOLD_TIME = 1
local CLICK_DELAY = 0.08

-- Alte Multi-Menu-Instanz beenden
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

local old = pg:FindFirstChild("SaveEggMultiV14")
if old then
    old:Destroy()
end

-- GUI erstellen
local gui = Instance.new("ScreenGui")
gui.Name = "SaveEggMultiV14"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 345)
frame.Position = UDim2.new(0.5, -170, 0.2, 0)
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
    "SAVE THE EGG | MULTI MENU V14",
    5, 30
)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

local clickButton = makeButton(
    "Auto Click Purple Point: OFF",
    42
)

local scanButton = makeButton(
    "Scan Eggs",
    85,
    Color3.fromRGB(65, 125, 180)
)

local tpButton = makeButton(
    "TP Best Luck Egg",
    128,
    Color3.fromRGB(65, 125, 180)
)

local autoTPButton = makeButton(
    "Auto TP Best Luck: OFF",
    171,
    Color3.fromRGB(65, 145, 105)
)

local clickStatus = makeLabel(
    "Purple Click: Bereit",
    220, 38
)

local eggStatus = makeLabel(
    "Egg Scanner: Bereit",
    260, 65
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

-- ============================
-- AUTO PURPLE POINT
-- ============================

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

-- ============================
-- LUCK EGG SCANNER
-- ============================

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

    local multipliers = {
        K = 1e3,
        M = 1e6,
        B = 1e9,
        T = 1e12
    }

    return value * (
        multipliers[string.upper(suffix or "")]
        or 1
    )
end

local function parseLuckText(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = text:gsub(",", "")
    cleaned = cleaned:gsub("%s+", "")

    local number, suffix =
        cleaned:match("🍀([%d%.]+)([KkMmBbTt]?)")

    if not number then
        number, suffix =
            cleaned:match("([%d%.]+)([KkMmBbTt]?)🍀")
    end

    if number then
        return parseNumber(number .. (suffix or ""))
    end

    return nil
end

local function getWorldPosition(obj)
    local current = obj

    while current and current ~= workspace do
        if current:IsA("BillboardGui")
            and current.Adornee then

            local adorn = current.Adornee

            if adorn:IsA("BasePart") then
                return adorn.Position
            end

            if adorn:IsA("Attachment") then
                return adorn.WorldPosition
            end
        end

        if current:IsA("Attachment") then
            return current.WorldPosition
        end

        if current:IsA("BasePart") then
            return current.Position
        end

        if current:IsA("Model") then
            local ok, pivot = pcall(function()
                return current:GetPivot()
            end)

            if ok then
                return pivot.Position
            end
        end

        current = current.Parent
    end

    return nil
end

local function findLuckInGui(root)
    local texts = {}
    local hasClover = false
    local bestNumber = nil

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextLabel")
            or obj:IsA("TextButton") then

            local txt = obj.Text or ""

            -- Glückswert direkt im Text
            local directLuck = parseLuckText(txt)

            if directLuck then
                return directLuck
            end

            table.insert(texts, txt)

            if txt:find("🍀", 1, true)
                or string.lower(txt):find(
                    "luck", 1, true
                ) then

                hasClover = true
            end
        end
    end

    -- Glückssymbol und Zahl getrennt
    if hasClover then
        for _, txt in ipairs(texts) do
            local value = parseNumber(txt)

            if value and (
                not bestNumber
                or value > bestNumber
            ) then
                bestNumber = value
            end
        end
    end

    return bestNumber
end

local function findBestLuckEgg()
    local best = nil
    local bestLuck = -1
    local scanned = 0

    for _, obj in ipairs(
        workspace:GetDescendants()
    ) do

        if obj:IsA("BillboardGui")
            or obj:IsA("SurfaceGui") then

            local pos = getWorldPosition(obj)

            if pos then
                scanned = scanned + 1

                local luck = findLuckInGui(obj)

                if luck and luck > bestLuck then
                    bestLuck = luck

                    best = {
                        position = pos,
                        luck = luck,
                        name = obj.Parent
                            and obj.Parent.Name
                            or "Egg"
                    }
                end
            end
        end
    end

    return best, scanned
end

local function scanEggs()
    local best, scanned = findBestLuckEgg()

    if best then
        eggStatus.Text =
            "Bestes Ei: " .. best.name
            .. " | Luck: " .. tostring(best.luck)
            .. " | GUIs: " .. scanned
    else
        eggStatus.Text =
            "Kein Luck-Ei gefunden | "
            .. scanned .. " Welt-GUIs gescannt"
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
            "TP versucht | Luck: "
            .. tostring(egg.luck)
    else
        eggStatus.Text =
            "TP Fehler: "
            .. tostring(err):sub(1, 65)
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

        task.wait(3)
    end
end)
