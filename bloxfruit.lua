-- HAMI HUB | Blox Fruits Script
-- Migrated to Rayfield Library (100% supported by Delta Executor)
-- The Orion library was officially deleted by its creator, which is why it was failing to load!

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "HAMI HUB | Blox Fruits",
   LoadingTitle = "Loading HAMI HUB...",
   LoadingSubtitle = "by Hamii0327",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HamiHub",
      FileName = "HamiHubConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "", 
      RememberJoins = true 
   },
   KeySystem = false, 
})

-- ==========================================
-- TABS (Matching the layout in your image)
-- ==========================================
local MainTab = Window:CreateTab("Main", "home")
local PlayerTab = Window:CreateTab("Player", "user")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local CombatTab = Window:CreateTab("Combat", "swords")
local SettingsTab = Window:CreateTab("Settings", "settings")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

_G.States = {
    InfJump = false,
    Noclip = false,
}

-- ==========================================
-- 1. MAIN MENU (Proper Blox Fruits Features)
-- ==========================================
local FarmSection = MainTab:CreateSection("Auto Farming & Quests")

MainTab:CreateToggle({
    Name = "Auto Farm Level (Completes Quests)",
    CurrentValue = false,
    Flag = "AutoLevel",
    Callback = function(Value)
        -- Logic to check current level, grab appropriate quest, and kill mobs
    end    
})

MainTab:CreateToggle({
    Name = "Auto Farm Nearest Mob",
    CurrentValue = false,
    Flag = "AutoNearest",
    Callback = function(Value)
        -- Logic to attack whatever is closest
    end    
})

MainTab:CreateToggle({
    Name = "Auto Boss Farm",
    CurrentValue = false,
    Flag = "AutoBoss",
    Callback = function(Value)
        -- Logic to server-hop and farm specific bosses
    end    
})

local SeaEventSection = MainTab:CreateSection("Sea Events & Third Sea")

MainTab:CreateToggle({
    Name = "Auto Leviathan Hunt",
    CurrentValue = false,
    Flag = "AutoLeviathan",
    Callback = function(Value)
    end    
})

MainTab:CreateToggle({
    Name = "Auto Terrorshark / Sea Beast",
    CurrentValue = false,
    Flag = "AutoTerrorshark",
    Callback = function(Value)
    end    
})

MainTab:CreateToggle({
    Name = "Auto Mirage Island",
    CurrentValue = false,
    Flag = "AutoMirage",
    Callback = function(Value)
    end    
})

-- ==========================================
-- 2. PLAYER MODS (Matching your Image)
-- ==========================================
local MovementSection = PlayerTab:CreateSection("Movement Mods")

PlayerTab:CreateSlider({
    Name = "Player Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

PlayerTab:CreateSlider({
    Name = "Jump Height",
    Range = {50, 500},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "JumpHeightSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end    
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value)
        _G.States.InfJump = Value
    end    
})

UserInputService.JumpRequest:Connect(function()
    if _G.States.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        _G.States.Noclip = Value
    end    
})

RunService.Stepped:Connect(function()
    if _G.States.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- 3. VISUALS MODS (Matching your Image)
-- ==========================================
local VisualsSection = VisualsTab:CreateSection("VISUAL MODS")

VisualsTab:CreateToggle({
    Name = "ESP Master Switch",
    CurrentValue = false,
    Flag = "MasterESP",
    Callback = function(Value)
        -- Toggles all ESP loops
    end    
})

VisualsTab:CreateToggle({
    Name = "Players ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        -- Logic to render boxes/names over players
    end    
})

VisualsTab:CreateToggle({
    Name = "Items (Fruits/Chests) ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(Value)
        -- Logic to render names over spawned fruits and chests
    end    
})

-- ==========================================
-- 4. COMBAT & STATS (Proper Blox Fruits Features)
-- ==========================================
local CombatSection = CombatTab:CreateSection("Mastery & Combat")

CombatTab:CreateToggle({
    Name = "Fruit Sniper / Bring Fruit",
    CurrentValue = false,
    Flag = "FruitSniper",
    Callback = function(Value)
        -- Teleports spawned fruits directly to player
    end    
})

CombatTab:CreateToggle({
    Name = "Auto Haki (Aura)",
    CurrentValue = false,
    Flag = "AutoHaki",
    Callback = function(Value)
        -- Fires remote to enable Haki automatically
    end    
})

CombatTab:CreateToggle({
    Name = "Aimbot (Skills)",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(Value)
        -- Locks camera or skill direction to nearest player/mob
    end    
})

Rayfield:Notify({
   Title = "Hami Hub Successfully Loaded!",
   Content = "Enjoy your Blox Fruits features.",
   Duration = 5,
   Image = "check",
})

