-- Save The Egg: GUI Scanner V6
-- Diagnostic only: no clicks or mouse movement.
local Players = game:GetService('Players')
local player = Players.LocalPlayer
local gui = Instance.new('ScreenGui')
gui.Name = 'PurpleScannerV6'
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild('PlayerGui')
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(420, 350)
frame.Position = UDim2.new(0.5,-210,0.5,-175)
frame.BackgroundColor3 = Color3.fromRGB(29,29,39)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
local title = Instance.new('TextLabel')
title.Size = UDim2.new(1,-45,0,36)
title.BackgroundTransparency = 1
title.Text = 'PURPLE POINT SCANNER V6'
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 17
title.Parent = frame
local close = Instance.new('TextButton')
close.Size = UDim2.fromOffset(35,30)
close.Position = UDim2.new(1,-38,0,3)
close.Text = 'X'
close.Parent = frame
local scan = Instance.new('TextButton')
scan.Size = UDim2.new(1,-20,0,38)
scan.Position = UDim2.fromOffset(10,43)
scan.Text = 'SCAN WHEN PURPLE CIRCLE IS VISIBLE'
scan.BackgroundColor3 = Color3.fromRGB(116,71,186)
scan.TextColor3 = Color3.new(1,1,1)
scan.Parent = frame
local output = Instance.new('TextBox')
output.Position = UDim2.fromOffset(10,90)
output.Size = UDim2.new(1,-20,1,-100)
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextYAlignment = Enum.TextYAlignment.Top
output.TextWrapped = false
output.MultiLine = true
output.ClearTextOnFocus = false
output.TextEditable = false
output.TextSize = 12
output.Font = Enum.Font.Code
output.Text = 'Wait for a purple circle, then press SCAN.\nScreenshot the results.'
output.Parent = frame
local function scanGui()
 local rows = {}
 local total = 0
 for _,root in ipairs({player:FindFirstChildOfClass('PlayerGui'),game:GetService('CoreGui')}) do
  if root then
   for _,obj in ipairs(root:GetDescendants()) do
    if obj:IsA('GuiObject') and obj.Visible and obj.AbsoluteSize.X > 5 and obj.AbsoluteSize.Y > 5 then
     total += 1
     local c = obj.BackgroundColor3
     local purple = c.R > 0.25 and c.B > c.G * 1.25 and c.B > c.R * 0.8
     local label = string.lower(obj.Name)
     local candidate = purple or label:find('click') or label:find('tap') or label:find('point') or label:find('purple')
     if candidate and #rows < 35 then
      local p = obj.AbsolutePosition
      table.insert(rows,string.format('%s [%s] (%d,%d) %s',obj.Name,obj.ClassName,p.X,p.Y,obj.Parent and obj.Parent.Name or '?'))
     end
    end
   end
  end
 end
 output.Text = 'Visible GUI elements: '..total..'\nCandidates: '..#rows..'\n'..table.concat(rows,'\n')
 if #rows == 0 then output.Text ..= '\nNo candidates. Circle may not be a standard GUI object.' end
end
scan.MouseButton1Click:Connect(scanGui)
close.MouseButton1Click:Connect(function() gui:Destroy() end)
