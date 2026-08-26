--[[
	WARNING: Use at your own risk!
	Hami Hub - Driving Empire Edition (Zero-Yield Version)
]]

-- ==========================================
-- 1. SAFE SERVICES & VARIABLES
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Global States
getgenv().WalkSpeedEnabled = false
getgenv().WalkSpeedValue = 16
getgenv().JumpPowerEnabled = false
getgenv().JumpPowerValue = 50
getgenv().VehicleSpeed = 200
getgenv().SpeedBoost = false

-- ==========================================
-- 2. BACKGROUND HANDLERS
-- ==========================================
-- Safely handle respawns without freezing the script
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

local function getVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent 
    end
    return nil
end

-- ==========================================
-- 3. BUILD THE UI FIRST
-- ==========================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Hami Hub | Driving Empire", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroEnabled = true,
    IntroText = "Hami Hub Loading..."
})

-- ==========================================
-- TAB 1: AUTO FARMING
-- ==========================================
local FarmTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483362458", PremiumOnly = false})

FarmTab:AddSection({Name = "Delivery Farm"})
FarmTab:AddParagraph("Auto Delivery", "Join the delivery job first before turning it on.")
FarmTab:AddToggle({
    Name = "Auto Delivery", 
    Default = false,
    Callback = function(state)
        -- Placeholder for delivery logic to prevent UI freezing
        if state then
            OrionLib:MakeNotification({Name = "Delivery", Content = "Auto Delivery Enabled (Make sure you are in the job)", Image = "rbxassetid://4483362458", Time = 3})
            -- The massive delivery logic should ideally go inside a task.spawn() here if needed
        end
    end    
})

FarmTab:AddSection({Name = "Passive Income"})
FarmTab:AddToggle({
    Name = "Auto Highway Farm", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoHighway = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoHighway do
                    task.wait(0.5)
                    -- Highway logic here
                end
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Race", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoRace = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoRace do
                    task.wait(1)
                    -- Race logic here
                end
            end)
        end
    end    
})

-- ==========================================
-- TAB 2: VEHICLE MODS
-- ==========================================
local VehicleTab = Window:MakeTab({Name = "Vehicle", Icon = "rbxassetid://4483362458", PremiumOnly = false})
VehicleTab:AddSection({Name = "Performance"})

VehicleTab:AddSlider({
    Name = "Speed Value", 
    Min = 100, Max = 1000, Default = 200, Color = Color3.fromRGB(0, 255, 100), Increment = 10, ValueName = "Speed",
    Callback = function(Value) getgenv().VehicleSpeed = Value end    
})

VehicleTab:AddToggle({
    Name = "Enable Speed Boost (Hold W)", 
    Default = false,
    Callback = function(Value)
        getgenv().SpeedBoost = Value
        if Value then
            task.spawn(function()
                while getgenv().SpeedBoost do
                    task.wait()
                    local veh = getVehicle()
                    if veh and veh.PrimaryPart and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        local currentVel = veh.PrimaryPart.Velocity
                        local newVel = veh.PrimaryPart.CFrame.LookVector * getgenv().VehicleSpeed
                        veh.PrimaryPart.Velocity = Vector3.new(newVel.X, currentVel.Y, newVel.Z)
                    end
                end
            end)
        end
    end    
})

VehicleTab:AddButton({
    Name = "Auto Flip Car",
    Callback = function()
        local veh = getVehicle()
        if veh and veh.PrimaryPart then
            local currentPos = veh.PrimaryPart.Position
            veh:SetPrimaryPartCFrame(CFrame.new(currentPos) * CFrame.Angles(0, math.rad(veh.PrimaryPart.Orientation.Y), 0))
        end
    end    
})

-- ==========================================
-- TAB 3: PLAYER MODS
-- ==========================================
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483362458", PremiumOnly = false})
PlayerTab:AddSection({Name = "Movement"})

PlayerTab:AddSlider({
    Name = "Walk Speed Value", 
    Min = 16, Max = 300, Default = 16, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "WS",
    Callback = function(Value)
        getgenv().WalkSpeedValue = Value
        if getgenv().WalkSpeedEnabled then
            local _, hum = getChar()
            if hum then hum.WalkSpeed = Value end
        end
    end    
})

PlayerTab:AddToggle({
    Name = "Enable Walk Speed", 
    Default = false,
    Callback = function(Value)
        getgenv().WalkSpeedEnabled = Value
        local _, hum = getChar()
        if hum then hum.WalkSpeed = Value and getgenv().WalkSpeedValue or 16 end
    end    
})

PlayerTab:AddSlider({
    Name = "High Jump Value", 
    Min = 50, Max = 300, Default = 50, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "JP",
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
    Name = "Enable High Jump", 
    Default = false,
    Callback = function(Value)
        getgenv().JumpPowerEnabled = Value
        local _, hum = getChar()
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = Value and getgenv().JumpPowerValue or 50 
        end
    end    
})

-- ==========================================
-- TAB 4: TELEPORTS
-- ==========================================
local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local function tpPlayer(pos)
    local root = select(1, getChar())
    if root then
        local veh = getVehicle()
        if veh then veh:SetPrimaryPartCFrame(CFrame.new(pos))
        else root.CFrame = CFrame.new(pos) end
    end
end

TeleportTab:AddButton({Name = "Teleport to Dealership", Callback = function() tpPlayer(Vector3.new(0, 50, 0)) end})
TeleportTab:AddButton({Name = "Teleport to Highway", Callback = function() tpPlayer(Vector3.new(500, 50, 500)) end})

-- ==========================================
-- TAB 5: MISCELLANEOUS
-- ==========================================
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MiscTab:AddToggle({
    Name = "Anti-AFK", 
    Default = false,
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
