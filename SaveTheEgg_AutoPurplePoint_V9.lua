
-- Save The Egg | Auto Purple Point V9
-- Madium PC


local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("PurplePointV9")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "PurplePointV9"
gui.ResetOnSpawn = false
gui.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 165)
frame.Position = UDim2.new(0.5, -150, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(32, 27, 44)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 30)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "SAVE THE EGG | V9"
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

local enabled = false
local running = true
local clicked = {}

local function isVisible(obj)
    if not obj:IsA("GuiObject") then
        return false
    end

    if obj.AbsoluteSize.X < 5 or obj.AbsoluteSize.Y < 5 then
        return false
    end

    local current = obj

    while current and current ~= pg do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end

        if current:IsA("ScreenGui") and not current.Enabled then
            return false
        end

        current = current.Parent
    end

    return true
end

local function findTap2()
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
        status.Text = "Mausfunktionen nicht unterstützt!"
        return
    end

    enabled = not enabled

    toggle.Text = enabled
        and "Auto Click Purple Point: ON"
        or "Auto Click Purple Point: OFF"

    status.Text = enabled
        and "Suche lila Punkt ..."
        or "Pausiert"

    table.clear(clicked)
end)

close.MouseButton1Click:Connect(function()
    enabled = false
    running = false
    gui:Destroy()
end)

task.spawn(function()
    while running do
        if enabled then
            local targets = findTap2()
            local visibleNow = {}

            for _, obj in ipairs(targets) do
                visibleNow[obj] = true

                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize

                local x = math.floor(pos.X + size.X / 2)
                local y = math.floor(pos.Y + size.Y / 2 + 36)

                local signature = x .. ":" .. y

                if clicked[obj] ~= signature then
                    local ok, err = pcall(function()
                        mousemoveabs(x, y)
                        task.wait(0.05)
                        mouse1click()
                    end)

                    if ok then
                        clicked[obj] = signature
                        status.Text = "Geklickt: " .. x .. ", " .. y
                    else
                        status.Text = "Fehler: " .. tostring(err)
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
                status.Text = "Warte auf lila Punkt ..."
            end
        end

        task.wait(0.08)
    end
end)
