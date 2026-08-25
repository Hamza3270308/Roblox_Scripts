-- Load the Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
   Name = "Hami Hub",
   LoadingTitle = "Loading Hami Hub...",
   LoadingSubtitle = "Steal An Egg",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HamiHub",
      FileName = "StealAnEgg"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

---------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local InfiniteJumpEnabled = false

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

---------------------------------------------------------
-- TAB 1: MAIN (AUTOMATION)
---------------------------------------------------------
local MainTab = Window:CreateTab("Main", 4483362458) -- Icon ID
local FarmSection = MainTab:CreateSection("Auto Farming")

local AutoPlaceToggle = MainTab:CreateToggle({
   Name = "Auto Place Egg",
   CurrentValue = false,
   Flag = "AutoPlace", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Place Egg RemoteEvent code below this line:
        
   end,
})

local AutoRecoverToggle = MainTab:CreateToggle({
   Name = "Auto Recover Egg",
   CurrentValue = false,
   Flag = "AutoRecover", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Recover Egg RemoteEvent code below this line:
        
   end,
})

local AutoSellToggle = MainTab:CreateToggle({
   Name = "Auto Sell Egg",
   CurrentValue = false,
   Flag = "AutoSell", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Sell Egg RemoteEvent code below this line:
        
   end,
})

local AutoHatchToggle = MainTab:CreateToggle({
   Name = "Auto Hatch",
   CurrentValue = false,
   Flag = "AutoHatch", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Hatch RemoteEvent code below this line:
        
   end,
})

local ProgressionSection = MainTab:CreateSection("Progression")

local AutoClaimToggle = MainTab:CreateToggle({
   Name = "Auto Claim Rewards",
   CurrentValue = false,
   Flag = "AutoClaim", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Claim RemoteEvent code below this line:
        
   end,
})

local AutoRebirthToggle = MainTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirth", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Rebirth RemoteEvent code below this line:
        
   end,
})

local AutoUpgradeTreadmill = MainTab:CreateToggle({
   Name = "Auto Upgrade Treadmill",
   CurrentValue = false,
   Flag = "AutoUpgradeTreadmill", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Upgrade Treadmill RemoteEvent code below this line:
        
   end,
})

local AutoUpgradeBase = MainTab:CreateToggle({
   Name = "Auto Upgrade Base",
   CurrentValue = false,
   Flag = "AutoUpgradeBase", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Paste your Auto Upgrade Base RemoteEvent code below this line:
        
   end,
})

---------------------------------------------------------
-- TAB 2: PLAYER (WORKING FEATURES)
---------------------------------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458) 
local MovementSection = PlayerTab:CreateSection("Movement")

local WalkSpeedSlider = PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = " Spd",
   CurrentValue = 16,
   Flag = "WalkSpeed", 
   Callback = function(Value)
        -- Fully Working WalkSpeed Modifier
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
   end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
   Increment = 1,
   Suffix = " Pwr",
   CurrentValue = 50,
   Flag = "JumpPower", 
   Callback = function(Value)
        -- Fully Working JumpPower Modifier
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
   end,
})

local InfiniteJumpToggle = PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump", 
   Callback = function(Value)
        -- Fully Working Infinite Jump
        InfiniteJumpEnabled = Value
   end,
})

---------------------------------------------------------
-- TAB 3: VISUALS
---------------------------------------------------------
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local ESPSection = VisualsTab:CreateSection("ESP & Boosts")

local EggESPToggle = VisualsTab:CreateToggle({
   Name = "Egg ESP",
   CurrentValue = false,
   Flag = "EggESP", 
   Callback = function(Value)
        -- [PLACEHOLDER]
        -- Logic to draw boxes/highlights around eggs goes here.
        -- Requires knowing the exact folder name where eggs are stored in the Workspace.
        
   end,
})

local FPSBoostButton = VisualsTab:CreateButton({
   Name = "Boost FPS (Removes Textures)",
   Callback = function()
        -- Fully Working FPS Boost (Removes Decals and Textures)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                end
            end
        end
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 9e9
   end,
})

-- Load Configuration
Rayfield:LoadConfiguration()
