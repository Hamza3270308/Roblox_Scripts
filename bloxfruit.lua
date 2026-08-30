local Rayfield = loadstring(game:HttpGet('https://sirblood.github.io/Rayfield/'))()

local Window = Rayfield:CreateWindow({
   Name = "Hami Hub | Clean All The Leaves",
   LoadingTitle = "Loading Hami Hub...",
   LoadingSubtitle = "by Hamii0327",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "HamiHub"
   },
   Discord = {
      Enabled = false,
      Invite = "", 
      RememberJoins = true 
   },
   KeySystem = false,
})

-- ==========================================
-- TABS
-- ==========================================
local FarmTab = Window:CreateTab("Auto Farm", "swords")
local StatsTab = Window:CreateTab("Auto Stats", "trending-up")
local TeleportTab = Window:CreateTab("Teleports", "map-pin")
local ESPTab = Window:CreateTab("Visuals", "eye")
local PlayerTab = Window:CreateTab("Player", "user")

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ==========================================
-- AUTO FARM TAB (Structure)
-- ==========================================
-- NOTE: Fully functional Auto-Farms require specific RemoteEvents (like claiming quests and dealing damage). 
-- These remotes change frequently to prevent cheating. This is the theoretical structure.

local _G = {
    AutoFarm = false,
    SelectedMob = "Bandit",
    AutoStats = false,
    StatPoints = "Melee"
}

FarmTab:CreateSection("Farming Configuration")

FarmTab:CreateDropdown({
   Name = "Select Monster",
   Options = {"Bandit", "Monkey", "Gorilla", "Pirate"},
   CurrentOption = {"Bandit"},
   MultipleOptions = false,
   Flag = "MobSelect",
   Callback = function(Option)
       _G.SelectedMob = Option[1]
   end,
})

FarmTab:CreateToggle({
   Name = "Enable Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       _G.AutoFarm = Value
       
       -- Generic Auto Farm Loop
       spawn(function()
           while _G.AutoFarm do
               task.wait()
               -- 1. Find Mob
               -- 2. Teleport behind mob using LocalPlayer.Character.HumanoidRootPart.CFrame
               -- 3. Trigger Mouse1 click or fire Damage RemoteEvent
               -- (Actual RemoteEvents are obfuscated by the game developers)
           end
       end)
   end,
})

-- ==========================================
-- AUTO STATS TAB
-- ==========================================
StatsTab:CreateSection("Stat Upgrades")

StatsTab:CreateDropdown({
   Name = "Select Stat to Upgrade",
   Options = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
   CurrentOption = {"Melee"},
   MultipleOptions = false,
   Flag = "StatSelect",
   Callback = function(Option)
       _G.StatPoints = Option[1]
   end,
})

StatsTab:CreateToggle({
   Name = "Auto Upgrade Stats",
   CurrentValue = false,
   Flag = "AutoStatsToggle",
   Callback = function(Value)
       _G.AutoStats = Value
       spawn(function()
           while _G.AutoStats do
               task.wait(1)
               -- In Blox Fruits, stat upgrades are usually handled by a remote named "AddPoint"
               -- Example: game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", _G.StatPoints, 1)
           end
       end)
   end,
})


-- ==========================================
-- TELEPORTS TAB
-- ==========================================
TeleportTab:CreateSection("Islands")

-- Generic tween teleport function to bypass standard anti-cheat
local function TweenTeleport(targetCFrame)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
        local speed = 300 -- Studs per second
        
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        -- Prevent falling while teleporting
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Parent = LocalPlayer.Character.HumanoidRootPart
        
        tween:Play()
        tween.Completed:Wait()
        bv:Destroy()
    end
end

TeleportTab:CreateButton({
   Name = "Teleport to Starter Island",
   Callback = function()
       TweenTeleport(CFrame.new(979, 16, 1419)) -- Generic coordinates
   end,
})

TeleportTab:CreateButton({
   Name = "Teleport to Jungle",
   Callback = function()
       TweenTeleport(CFrame.new(-1252, 11, 235))
   end,
})

-- ==========================================
-- VISUALS (ESP) TAB
-- ==========================================
ESPTab:CreateSection("Player ESP")

local ESP_Enabled = false
ESPTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
       ESP_Enabled = Value
       
       if ESP_Enabled then
           for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("ESP_Highlight") then
                   local highlight = Instance.new("Highlight")
                   highlight.Name = "ESP_Highlight"
                   highlight.FillColor = Color3.fromRGB(255, 0, 0)
                   highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                   highlight.Parent = player.Character
               end
           end
       else
           for _, player in pairs(Players:GetPlayers()) do
               if player.Character and player.Character:FindFirstChild("ESP_Highlight") then
                   player.Character.ESP_Highlight:Destroy()
               end
           end
       end
   end,
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
PlayerTab:CreateSection("Local Player Modifications")

PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end
   end,
})

local Noclip = false
PlayerTab:CreateToggle({
   Name = "NoClip (Walk through walls)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
       Noclip = Value
   end,
})

RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

Rayfield:Notify({
   Title = "Hub Loaded",
   Content = "Blox Fruits Hub has successfully loaded.",
   Duration = 5,
   Image = "check",
})
