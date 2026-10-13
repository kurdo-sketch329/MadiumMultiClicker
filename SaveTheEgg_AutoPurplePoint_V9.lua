
-- Save The Egg | Auto Purple Point V10
-- Madium PC

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Alte Version beenden
if _G.PurplePointStop then
    _G.PurplePointStop()
end

local running = true
local enabled = false
local clicked = {}

local old = pg:FindFirstChild("PurplePointV10")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PurplePointV10"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(310, 165)
frame.Position = UDim2.new(0.5, -155, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(32, 27, 44)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 30)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "SAVE THE EGG | V10"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 42)
toggle.Position = UDim2.fromOffset(10, 43)
toggle.BackgroundColor3 = Color3.fromRGB(115, 65, 180)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Text = "Auto Click Purple Point: OFF"
toggle.Parent = frame

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.fromOffset(10, 94)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextWrapped = true
status.Text = "Bereit"
status.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 25)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(180, 55, 75)
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "X"
close.Parent = frame

local function stop()
    running = false
    enabled = false
    gui:Destroy()
end

_G.PurplePointStop = stop

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

-- Mitte des lila Kreises finden
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

local function findTargets()
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

toggle.MouseButton1Click:Connect(function()
    if type(mousemoveabs) ~= "function"
        or type(mouse1click) ~= "function" then
        status.Text = "Madium unterstützt Mausfunktionen nicht!"
        return
    end

    enabled = not enabled
    table.clear(clicked)

    toggle.Text = enabled
        and "Auto Click Purple Point: ON"
        or "Auto Click Purple Point: OFF"

    status.Text = enabled
        and "Suche lila Kreis ..."
        or "Pausiert"
end)

close.MouseButton1Click:Connect(stop)

task.spawn(function()
    while running do
        if enabled then
            local targets = findTargets()
            local visibleNow = {}

            for _, obj in ipairs(targets) do
                visibleNow[obj] = true

                local target = getCircleTarget(obj)

                local pos = target.AbsolutePosition
                local size = target.AbsoluteSize

                -- Mitte berechnen
                local x = math.floor(pos.X + size.X / 2)
                local y = math.floor(pos.Y + size.Y / 2 + 60)

                local signature = x .. ":" .. y

                if clicked[obj] ~= signature then
                    local ok, err = pcall(function()
                       mousemoveabs(x, y)
task.wait(0.15)


if type(mousemoveabs) ~= "function"
    or (
        type(mouse1click) ~= "function"
        and not (
            type(mouse1press) == "function"
            and type(mouse1release) == "function"
        )
    ) then
    status.Text = "Mausfunktionen nicht unterstützt!"
    return
end

                    end)

                    if ok then
                        clicked[obj] = signature
                        status.Text =
                            "Mitte geklickt: " .. x .. ", " .. y
                    else
                        status.Text =
                            "Fehler: " .. tostring(err)
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
                status.Text = "Warte auf lila Kreis ..."
            end
        end

        task.wait(0.08)
    end
end)
