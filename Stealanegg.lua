-- Load Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variables for LocalPlayer
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create Main Window: Black background (default Orion dark mode) with Electric Green accents
local Window = OrionLib:MakeWindow({
    Name = "Hami Hub",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "Hami Hub Loading...",
    Color = Color3.fromRGB(0, 255, 0) -- Electric Green (#00FF00)
})

-- ==========================================
-- TABS
-- ==========================================
local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local FarmTab = Window:MakeTab({ Name = "Farming", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local TeleportTab = Window:MakeTab({ Name = "Raiding", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- ==========================================
-- 1. PLAYER TAB (Mobility & God Mode)
-- ==========================================

PlayerTab:AddSlider({
    Name = "Walkspeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end    
})

PlayerTab:AddSlider({
    Name = "High Jump",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Jump Power",
    Callback = function(Value)
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            char:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end    
})

PlayerTab:AddButton({
    Name = "Enable Invulnerability (God Mode)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").MaxHealth = math.huge
            char:FindFirstChildOfClass("Humanoid").Health = math.huge
            OrionLib:MakeNotification({
                Name = "God Mode Enabled",
                Content = "You are now invulnerable.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

-- ==========================================
-- 2. FARMING TAB (Eggs)
-- ==========================================

local autoCollect = false
FarmTab:AddToggle({
    Name = "Auto Collect Eggs",
    Default = false,
    Callback = function(Value)
        autoCollect = Value
        
        -- Wrap the loop in task.spawn so it doesn't freeze the UI
        if autoCollect then
            task.spawn(function()
                while autoCollect do
                    task.wait(0.5)
                    
                    -- It is highly recommended to replace 'workspace' with the specific folder 
                    -- if the game uses one, e.g., workspace.Eggs:GetChildren()
                    for _, item in pairs(workspace:GetDescendants()) do
                        if not autoCollect then break end -- Exit immediately if toggled off
                        
                        if item.Name == "Egg" and item:IsA("BasePart") then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = item.CFrame
                                task.wait(0.1) -- Yield slightly to allow server to register the touch
                            end
                        end
                    end
                end
            end)
        end
    end    
})

-- ==========================================
-- 3. RAIDING TAB (Teleports & Base Infiltration)
-- ==========================================

TeleportTab:AddTextbox({
    Name = "Teleport to Enemy Base",
    Default = "Enter Base Name Here",
    TextDisappear = true,
    Callback = function(Value)
        -- Attempt to find the base in the workspace by name
        local enemyBase = workspace:FindFirstChild(Value)
        local char = LocalPlayer.Character
        
        if enemyBase and char and char:FindFirstChild("HumanoidRootPart") then
            -- Teleport to the primary part of the base, slightly elevated
            local targetPart = enemyBase.PrimaryPart or enemyBase:FindFirstChildOfClass("BasePart")
            if targetPart then
                char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 10, 0)
                OrionLib:MakeNotification({Name = "Raid Initiated", Content = "Teleported to " .. Value, Time = 3})
            end
        else
            OrionLib:MakeNotification({Name = "Error", Content = "Base not found!", Time = 3})
        end
    end	
})

TeleportTab:AddButton({
    Name = "Teleport to Home Base (Defend)",
    Callback = function()
        -- Logic to return to your own spawn location
        local char = LocalPlayer.Character
        local spawnLocation = workspace:FindFirstChild("SpawnLocation") -- Standard Roblox spawn point
        if char and char:FindFirstChild("HumanoidRootPart") and spawnLocation then
            char.HumanoidRootPart.CFrame = spawnLocation.CFrame * CFrame.new(0, 5, 0)
        end
    end    
})

-- Initialize the UI
OrionLib:Init()
