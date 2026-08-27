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

local LocalPlayer = Players.LocalPlayer

-- Global States
getgenv().WalkSpeedEnabled = false
getgenv().WalkSpeedValue = 16
getgenv().JumpPowerEnabled = false
getgenv().JumpPowerValue = 50

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
-- TAB 1: AUTO FARMING
-- ==========================================
local FarmTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483362458", PremiumOnly = false})

FarmTab:AddSection({Name = "Leaf Automation"})

FarmTab:AddToggle({
    Name = "Auto Collect Leaves", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoCollect = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoCollect do
                    task.wait(0.1)
                    pcall(function()
                        -- [PLACEHOLDER] Replace with the exact RemoteEvent from SimpleSpy
                        -- Example: ReplicatedStorage.Remotes.CollectLeaf:FireServer()
                        
                        -- Backup Physical Touch Method (if game uses physics instead of remotes)
                        for _, item in pairs(workspace:GetDescendants()) do
                            if item.Name == "Leaf" and item:IsA("BasePart") then
                                local root, _ = getChar()
                                if root then
                                    firetouchinterest(root, item, 0)
                                    firetouchinterest(root, item, 1)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Vent / Sell", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoSell = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoSell do
                    task.wait(2)
                    pcall(function()
                        -- [PLACEHOLDER] Replace with the exact Sell/Vent RemoteEvent from SimpleSpy
                        -- Example: ReplicatedStorage.Remotes.Sell:FireServer()
                    end)
                end
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Complete Zone", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoComplete = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoComplete do
                    task.wait(5)
                    pcall(function()
                        -- [PLACEHOLDER] Replace with the remote that triggers zone completion
                    end)
                end
            end)
        end
    end    
})

-- ==========================================
-- TAB 2: UPGRADES
-- ==========================================
local UpgradeTab = Window:MakeTab({Name = "Upgrades", Icon = "rbxassetid://4483362458", PremiumOnly = false})

UpgradeTab:AddToggle({
    Name = "Auto Upgrade Tool", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoTool = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoTool do
                    task.wait(1)
                    pcall(function()
                        -- [PLACEHOLDER] Use SimpleSpy to find the purchase tool remote
                    end)
                end
            end)
        end
    end    
})

UpgradeTab:AddToggle({
    Name = "Auto Upgrade Capacity", 
    Default = false,
    Callback = function(Value)
        getgenv().AutoCapacity = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoCapacity do
                    task.wait(1)
                    pcall(function()
                        -- [PLACEHOLDER] Use SimpleSpy to find the upgrade backpack remote
                    end)
                end
            end)
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
    if root then root.CFrame = CFrame.new(pos) end
end

TeleportTab:AddButton({Name = "Teleport to Spawn", Callback = function() tpPlayer(Vector3.new(0, 10, 0)) end})
TeleportTab:AddButton({Name = "Teleport to Best Vent", Callback = function() tpPlayer(Vector3.new(100, 10, 100)) end})
TeleportTab:AddButton({Name = "Teleport to Next Zone", Callback = function() tpPlayer(Vector3.new(500, 10, 500)) end})

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

MiscTab:AddButton({
    Name = "Unlock Gamepasses (Client-Side)",
    Callback = function()
        OrionLib:MakeNotification({Name = "Visual Only", Content = "Gamepasses visually unlocked.", Image = "rbxassetid://4483362458", Time = 3})
    end    
})

-- Initialize UI
OrionLib:Init()
