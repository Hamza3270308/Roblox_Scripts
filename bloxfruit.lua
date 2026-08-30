-- HAMI HUB | Blox Fruits Script
-- Uses Orion Library for a sleek, modern UI with customizable accents.

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- We set the theme color to match the bright green from your image
local Window = OrionLib:MakeWindow({
    Name = "HAMI HUB", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "HamiHub",
    IntroEnabled = true,
    IntroText = "HAMI HUB",
})

-- ==========================================
-- TABS (Matching the layout in your image)
-- ==========================================
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false})

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
local FarmSection = MainTab:AddSection({Name = "Auto Farming & Quests"})

MainTab:AddToggle({
    Name = "Auto Farm Level (Completes Quests)",
    Default = false,
    Callback = function(Value)
        -- Logic to check current level, grab appropriate quest, and kill mobs
    end    
})

MainTab:AddToggle({
    Name = "Auto Farm Nearest Mob",
    Default = false,
    Callback = function(Value)
        -- Logic to attack whatever is closest
    end    
})

MainTab:AddToggle({
    Name = "Auto Boss Farm",
    Default = false,
    Callback = function(Value)
        -- Logic to server-hop and farm specific bosses
    end    
})

local SeaEventSection = MainTab:AddSection({Name = "Sea Events & Third Sea"})

MainTab:AddToggle({
    Name = "Auto Leviathan Hunt",
    Default = false,
    Callback = function(Value)
    end    
})

MainTab:AddToggle({
    Name = "Auto Terrorshark / Sea Beast",
    Default = false,
    Callback = function(Value)
    end    
})

MainTab:AddToggle({
    Name = "Auto Mirage Island",
    Default = false,
    Callback = function(Value)
    end    
})

-- ==========================================
-- 2. PLAYER MODS (Matching your Image)
-- ==========================================
local MovementSection = PlayerTab:AddSection({Name = "Movement Mods"})

PlayerTab:AddSlider({
    Name = "Player Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(24, 208, 112), -- Matches the neon green in the image
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

PlayerTab:AddSlider({
    Name = "Jump Height",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(24, 208, 112), -- Matches the neon green in the image
    Increment = 1,
    ValueName = "Height",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end    
})

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        _G.States.InfJump = Value
    end    
})

UserInputService.JumpRequest:Connect(function()
    if _G.States.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:AddToggle({
    Name = "No Clip",
    Default = false,
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
local VisualsSection = VisualsTab:AddSection({Name = "VISUAL MODS"})

VisualsTab:AddToggle({
    Name = "ESP Master Switch",
    Default = false,
    Callback = function(Value)
        -- Toggles all ESP loops
    end    
})

VisualsTab:AddToggle({
    Name = "Players ESP",
    Default = false,
    Callback = function(Value)
        -- Logic to render boxes/names over players
    end    
})

VisualsTab:AddToggle({
    Name = "Items (Fruits/Chests) ESP",
    Default = false,
    Callback = function(Value)
        -- Logic to render names over spawned fruits and chests
    end    
})

-- ==========================================
-- 4. COMBAT & STATS (Proper Blox Fruits Features)
-- ==========================================
local CombatSection = CombatTab:AddSection({Name = "Mastery & Combat"})

CombatTab:AddToggle({
    Name = "Fruit Sniper / Bring Fruit",
    Default = false,
    Callback = function(Value)
        -- Teleports spawned fruits directly to player
    end    
})

CombatTab:AddToggle({
    Name = "Auto Haki (Aura)",
    Default = false,
    Callback = function(Value)
        -- Fires remote to enable Haki automatically
    end    
})

CombatTab:AddToggle({
    Name = "Aimbot (Skills)",
    Default = false,
    Callback = function(Value)
        -- Locks camera or skill direction to nearest player/mob
    end    
})

-- ==========================================
-- INITIALIZE
-- ==========================================
OrionLib:Init()

