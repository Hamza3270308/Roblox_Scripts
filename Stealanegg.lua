local p = game:GetService("Players").LocalPlayer
local rs = game:GetService("RunService")
-- Bypassing CoreGui and putting the menu directly into your screen
local guiParent = p:WaitForChild("PlayerGui") 

if guiParent:FindFirstChild("HH") then guiParent.HH:Destroy() end

local s = Instance.new("ScreenGui", guiParent)
s.Name = "HH"
s.ResetOnSpawn = false -- Prevents the menu from disappearing if you die

local f = Instance.new("Frame", s)
f.Size = UDim2.new(0, 200, 0, 200)
f.Position = UDim2.new(0.5, -100, 0.5, -100)
f.BackgroundColor3 = Color3.new(0, 0, 0)
f.Active = true
f.Draggable = true

local function b(y, t)
    local x = Instance.new("TextButton", f)
    x.Size = UDim2.new(1, 0, 0, 40)
    x.Position = UDim2.new(0, 0, 0, y)
    x.Text = t
    x.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    x.TextColor3 = Color3.new(0, 1, 0)
    x.Font = Enum.Font.Code
    x.TextSize = 14
    return x
end

b(0, "Hami Hub").Active = false

-- 1. Force Speed Bypass
local spd, sOn = nil, false
local sb = b(40, "1. Force Speed: OFF")
sb.MouseButton1Click:Connect(function()
    sOn = not sOn
    sb.Text = "1. Force Speed: " .. (sOn and "ON" or "OFF")
    if sOn then
        spd = rs.RenderStepped:Connect(function()
            if p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.WalkSpeed = 100 end
        end)
    else
        if spd then spd:Disconnect() end
        if p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.WalkSpeed = 16 end
    end
end)

-- 2. Force High Jump Bypass
local jmp, jOn = nil, false
local jb = b(80, "2. High Jump: OFF")
jb.MouseButton1Click:Connect(function()
    jOn = not jOn
    jb.Text = "2. High Jump: " .. (jOn and "ON" or "OFF")
    if jOn then
        jmp = rs.RenderStepped:Connect(function()
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                p.Character.Humanoid.UseJumpPower = true
                p.Character.Humanoid.JumpPower = 100
            end
        end)
    else
        if jmp then jmp:Disconnect() end
        if p.Character and p.Character:FindFirstChild("Humanoid") then p.Character.Humanoid.JumpPower = 50 end
    end
end)

-- 3. Click Teleport Tool
local tb = b(120, "3. Get Teleport Tool")
tb.MouseButton1Click:Connect(function()
    local tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "Click TP"
    tool.Activated:Connect(function()
        local m = p:GetMouse()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = m.Hit + Vector3.new(0, 3, 0)
        end
    end)
    tool.Parent = p.Backpack
    tb.Text = "Tool Added to Backpack!"
    task.wait(2)
    tb.Text = "3. Get Teleport Tool"
end)

b(160, "Close Hub").MouseButton1Click:Connect(function() s:Destroy() end)
