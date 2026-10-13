
-- SAVE THE EGG | V9 MULTI MENU
-- Auto Purple Click + Best Luck Egg Teleport
-- Madium PC

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Einstellungen
local Y_OFFSET = 60
local HOLD_TIME = 1
local CLICK_SCAN_DELAY = 0.08
local EGG_SCAN_DELAY = 3

-- Alte Version stoppen
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

local old = pg:FindFirstChild("SaveEggMultiV9")
if old then
    old:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SaveEggMultiV9"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(330, 285)
frame.Position = UDim2.new(0.5, -165, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(32, 27, 44)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 10)

local function makeLabel(text, y, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, height)
    label.Position = UDim2.fromOffset(10, y)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextWrapped = true
    label.Text = text
    label.Parent = frame
    return label
end

local function makeButton(text, y, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 38)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 =
        color or Color3.fromRGB(115, 65, 180)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Text = text
    button.Parent = frame

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    return button
end

local title = makeLabel(
    "SAVE THE EGG | MULTI MENU V9",
    7,
    27
)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

local clickButton = makeButton(
    "Auto Click Purple Point: OFF",
    42
)

local tpButton = makeButton(
    "TP Best Luck Egg",
    88,
    Color3.fromRGB(65, 125, 180)
)

local autoTPButton = makeButton(
    "Auto TP Best Luck: OFF",
    134,
    Color3.fromRGB(65, 145, 105)
)

local clickStatus = makeLabel(
    "Purple Click: Bereit",
    185,
    35
)

local eggStatus = makeLabel(
    "Egg TP: Bereit",
    220,
    50
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

-- Sichtbarkeit prüfen
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

-- ==========================
-- AUTO PURPLE POINT
-- ==========================

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

                local signature =
                    tostring(x) .. ":" .. tostring(y)

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
                            .. tostring(err):sub(1, 55)
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

        task.wait(CLICK_SCAN_DELAY)
    end
end)

-- ==========================
-- BEST LUCK EGG TELEPORT
-- ==========================

local function parseLuck(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = text:gsub(",", "")
    cleaned = cleaned:gsub("%s+", "")

    -- Wert mit Kleeblatt erkennen
    local number, suffix =
        cleaned:match("🍀([%d%.]+)([KkMmBbTt]?)")

    if not number then
        number, suffix =
            cleaned:match("([%d%.]+)([KkMmBbTt]?)🍀")
    end

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

    suffix = string.upper(suffix or "")

    return value * (multipliers[suffix] or 1)
end

local function getWorldPosition(obj)
    local current = obj

    while current and current ~= workspace do
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

        if current:IsA("BillboardGui")
            and current.Adornee then

            local adornee = current.Adornee

            if adornee:IsA("BasePart") then
                return adornee.Position
            end

            if adornee:IsA("Attachment") then
                return adornee.WorldPosition
            end
        end

        current = current.Parent
    end

    return nil
end

local function findBestLuckEgg()
    local best = nil
    local bestLuck = -1

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel")
            or obj:IsA("TextButton") then

            local luck = parseLuck(obj.Text)

            if luck and luck > bestLuck then
                local pos = getWorldPosition(obj)

                if pos then
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

    return best
end

local function teleportToBestEgg()
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

    local egg = findBestLuckEgg()

    if not egg then
        eggStatus.Text =
            "Egg TP: Kein Glueckswert gefunden"
        return
    end

    local ok, err = pcall(function()
        root.CFrame = CFrame.new(
            egg.position + Vector3.new(0, 3, 0)
        )
    end)

    if ok then
        eggStatus.Text =
            "TP versucht | Luck: "
            .. tostring(egg.luck)
    else
        eggStatus.Text =
            "TP Fehler: "
            .. tostring(err):sub(1, 55)
    end
end

tpButton.MouseButton1Click:Connect(function()
    teleportToBestEgg()
end)

autoTPButton.MouseButton1Click:Connect(function()
    autoTP = not autoTP

    autoTPButton.Text = autoTP
        and "Auto TP Best Luck: ON"
        or "Auto TP Best Luck: OFF"

    if not autoTP then
        eggStatus.Text = "Auto TP: Pausiert"
    end
end)

task.spawn(function()
    while running do
        if autoTP then
            teleportToBestEgg()
        end

        task.wait(EGG_SCAN_DELAY)
    end
end)
