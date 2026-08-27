--[[
	WARNING: Use at your own risk!
	Hami Hub - Clean All The Leaves Edition (Zero-Yield Version)
]]

-- ==========================================
-- 1. SAFE SERVICES & VARIABLES
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Global States
getgenv().WalkSpeedEnabled = false
getgenv().WalkSpeedValue = 16
getgenv().JumpPowerEnabled = false
getgenv().JumpPowerValue = 50
getgenv().NoClip = false
getgenv().InfJump = false
getgenv().CtrlClickTP = false

-- ==========================================
-- 2. BACKGROUND HANDLERS
-- ==========================================
-- Safely handle respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then
            task.wait(0.5)
            if getgenv().WalkSpeedEnabled then hum.WalkSpeed = getgenv().WalkSpeedValue end
            if getgenv().JumpPowerEnabled then 
                hum.UseJumpPower = true
                hum.JumpPower = getgenv().JumpPowerValue 
            end
        end
    end)
end)

local function getChar()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid") end
    return nil, nil
end

-- Universal Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfJump then
        local _, hum = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Universal NoClip
RunService.Stepped:Connect(function()
    if getgenv().NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- Universal Ctrl + Click Teleport
Mouse.Button1Down:Connect(function()
    if getgenv().CtrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local root, _ = getChar()
        if root and Mouse.Hit then
            -- Teleports slightly above the mouse location so you don't get stuck in the floor
            root.CFrame = CFrame.new(Mouse.Hit.X, Mouse.Hit.Y + 3, Mouse.Hit.Z)
        end
    end
end)

-- ==========================================
-- 3. BUILD THE UI FIRST
-- ==========================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Hami Hub | Clean All The Leaves", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroEnabled = true,
    IntroText = "Hami Hub Loading..."
})

-- ==========================================
-- TAB 1: AUTO FARMING (Requires SimpleSpy Setup)
-- ==========================================
local FarmTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483362458", PremiumOnly = false})
FarmTab:AddSection({Name = "Leaf Automation (Needs Setup)"})

FarmTab:AddToggle({
    Name = "Auto Collect Leaves", Default = false,
    Callback = function(Value)
        getgenv().AutoCollect = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoCollect do
                    task.wait(0.1)
                    pcall(function()
                        -- [PLACEHOLDER] Replace with exact RemoteEvent from SimpleSpy
                    end)
                end
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Vent / Sell", Default = false,
    Callback = function(Value)
        getgenv().AutoSell = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoSell do
                    task.wait(2)
                    pcall(function()
                        -- [PLACEHOLDER] Replace with exact Sell RemoteEvent from SimpleSpy
                    end)
                end
            end)
        end
    end    
})

-- ==========================================
-- TAB 2: UNIVERSAL PLAYER MODS
-- ==========================================
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483362458", PremiumOnly = false})
PlayerTab:AddSection({Name = "Movement Overrides"})

PlayerTab:AddToggle({
    Name = "NoClip (Walk Through Walls)", Default = false,
    Callback = function(Value) getgenv().NoClip = Value end    
})

PlayerTab:AddToggle({
    Name = "Infinite Jump", Default = false,
    Callback = function(Value) getgenv().InfJump = Value end    
})

PlayerTab:AddToggle({
    Name = "Ctrl + Click Teleport", Default = false,
    Callback = function(Value) getgenv().CtrlClickTP = Value end    
})

PlayerTab:AddSection({Name = "Stat Modifiers"})

PlayerTab:AddSlider({
    Name = "Walk Speed", Min = 16, Max = 300, Default = 16, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "WS",
    Callback = function(Value)
        getgenv().WalkSpeedValue = Value
        if getgenv().WalkSpeedEnabled then
            local _, hum = getChar()
            if hum then hum.WalkSpeed = Value end
        end
    end    
})
PlayerTab:AddToggle({
    Name = "Enable Walk Speed", Default = false,
    Callback = function(Value)
        getgenv().WalkSpeedEnabled = Value
        local _, hum = getChar()
        if hum then hum.WalkSpeed = Value and getgenv().WalkSpeedValue or 16 end
    end    
})

PlayerTab:AddSlider({
    Name = "Jump Power", Min = 50, Max = 300, Default = 50, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "JP",
    Callback = function(Value)
        getgenv().JumpPowerValue = Value
        if getgenv().JumpPowerEnabled then
            local _, hum = getChar()
            if hum then 
                hum.UseJumpPower = true
                hum.JumpPower = Value 
            end
        end
    end    
})
PlayerTab:AddToggle({
    Name = "Enable Jump Power", Default = false,
    Callback = function(Value)
        getgenv().JumpPowerEnabled = Value
        local _, hum = getChar()
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = Value and getgenv().JumpPowerValue or 50 
        end
    end    
})

PlayerTab:AddSlider({
    Name = "Gravity Modifier", Min = 0, Max = 196, Default = 196, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "Grav",
    Callback = function(Value)
        workspace.Gravity = Value
    end    
})

-- ==========================================
-- TAB 3: UNIVERSAL VISUALS
-- ==========================================
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483362458", PremiumOnly = false})

VisualsTab:AddButton({
    Name = "Enable Fullbright",
    Callback = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end    
})

VisualsTab:AddButton({
    Name = "Boost FPS (Removes Textures)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.CastShadow = false
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        OrionLib:MakeNotification({Name = "FPS Boosted", Content = "All lag-causing textures and particles removed.", Image = "rbxassetid://4483362458", Time = 3})
    end    
})

-- ==========================================
-- TAB 4: MISCELLANEOUS
-- ==========================================
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MiscTab:AddToggle({
    Name = "Anti-AFK", Default = false,
    Callback = function(Value)
        getgenv().AntiAFK = Value
        if Value then
            task.spawn(function()
                LocalPlayer.Idled:Connect(function()
                    if getgenv().AntiAFK then VirtualUser:ClickButton2(Vector2.new()) end
                end)
            end)
            OrionLib:MakeNotification({Name = "Anti-AFK", Content = "You will no longer be kicked.", Image = "rbxassetid://4483362458", Time = 3})
        end
    end    
})

-- Initialize UI
OrionLib:Init()
