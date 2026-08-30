-- HAMI HUB | Blox Fruits Script
-- UI Populated, Combat Hooks Restored, Teleports Added

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "HAMI HUB | Blox Fruits",
    SubTitle = "by Hamii0327",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

_G.Settings = {
    AutoAttack = false,
    FastAttack = true,
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedToggle = false,
    JumpToggle = false,
    WalkOnWater = false,
    Noclip = false,
    InfJump = false,
    ESP = false,
}

-- ==========================================
-- COMBAT FRAMEWORK HOOKS (FIXED)
-- ==========================================
local CombatFrameworkR = nil
task.spawn(function()
    pcall(function()
        local CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
        CombatFrameworkR = getupvalues(CombatFramework)[2] or debug.getupvalue(CombatFramework, 2)
    end)
end)

-- Auto Attack Loop (Patched for Modern Updates)
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.AutoAttack and LocalPlayer.Character then
            if _G.Settings.FastAttack then
                -- Fast Attack Bypass: Nullify Cooldowns
                if CombatFrameworkR then
                    local ac = CombatFrameworkR.activeController
                    if ac and ac.equipped then
                        pcall(function()
                            ac.timeToNextAttack = 0
                            ac.attacking = false
                            ac.timeToNextBlock = 0
                            ac.humanoid.AutoRotate = true
                            ac.increment = 3
                            ac.blocking = false
                            ac:attack()
                        end)
                    end
                end
            else
                -- Normal Attack: Virtual Click Simulation
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end
    end
end)

-- ==========================================
-- ISLAND CFRAMES & TELEPORT LOGIC
-- ==========================================
local FirstSeaIslands = {
    ["Starter Marine"] = CFrame.new(-2755, 22, 2125),
    ["Starter Pirate"] = CFrame.new(990, 15, 1425),
    ["Jungle"] = CFrame.new(-1600, 36, 150),
    ["Pirate Village"] = CFrame.new(-1150, 15, 3900),
    ["Desert"] = CFrame.new(900, 15, 4300),
    ["Middle Town"] = CFrame.new(-680, 20, 1500),
    ["Frozen Village"] = CFrame.new(1200, 25, -1200),
    ["Marine Fortress"] = CFrame.new(-4800, 25, 4300)
}

local function SafeTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local HRP = char.HumanoidRootPart
        local distance = (HRP.Position - targetCFrame.Position).Magnitude
        
        -- Speed is approx 300 studs/sec to avoid anti-cheat kicks
        local tweenTime = distance / 300 
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HRP, tweenInfo, {CFrame = targetCFrame})
        
        -- Anti-fall body velocity during teleport
        local BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Parent = HRP
        
        tween:Play()
        tween.Completed:Connect(function()
            BodyVelocity:Destroy()
        end)
    end
end

-- ==========================================
-- BACKGROUND LOOPS (Mods)
-- ==========================================
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(10, 1, 10)
WaterPlatform.Transparency = 1
WaterPlatform.Anchored = true
WaterPlatform.CanCollide = true
WaterPlatform.Parent = workspace

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        if _G.Settings.SpeedToggle and Humanoid then
            Humanoid.WalkSpeed = _G.Settings.WalkSpeed
        end
        if _G.Settings.JumpToggle and Humanoid then
            Humanoid.JumpPower = _G.Settings.JumpPower
        end
        
        if _G.Settings.WalkOnWater then
            WaterPlatform.CFrame = HRP.CFrame * CFrame.new(0, -3.5, 0)
        else
            WaterPlatform.CFrame = CFrame.new(0, 50000, 0)
        end
    end
end)

RunService.Stepped:Connect(function()
    if _G.Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ==========================================
-- TABS & UI CREATION
-- ==========================================
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- [ MAIN & COMBAT TAB ]
Tabs.Main:AddToggle("AutoAttackToggle", {
    Title = "Auto Attack",
    Description = "Automatically triggers attacks.",
    Default = false,
    Callback = function(Value) _G.Settings.AutoAttack = Value end
})

Tabs.Combat:AddToggle("FastAttackToggle", {
    Title = "Fast Attack Mode",
    Description = "Removes attack cooldowns. Turn off for normal click simulation.",
    Default = true,
    Callback = function(Value) _G.Settings.FastAttack = Value end
})

-- [ TELEPORT TAB ]
local islandNames = {}
for name, _ in pairs(FirstSeaIslands) do table.insert(islandNames, name) end

Tabs.Teleport:AddDropdown("IslandDropdown", {
    Title = "Select Island (First Sea)",
    Values = islandNames,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        if FirstSeaIslands[Value] then
            Fluent:Notify({ Title = "Teleporting", Content = "Moving to " .. Value .. "...", Duration = 3 })
            SafeTeleport(FirstSeaIslands[Value])
        end
    end
})

-- [ PLAYER TAB ]
Tabs.Player:AddToggle("SpeedToggle", {
    Title = "Enable Custom Speed",
    Default = false,
    Callback = function(Value) _G.Settings.SpeedToggle = Value end
})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Player Speed",
    Default = 16, Min = 16, Max = 300, Rounding = 0,
    Callback = function(Value) _G.Settings.WalkSpeed = Value end
})

Tabs.Player:AddToggle("JumpToggle", {
    Title = "Enable Custom Jump",
    Default = false,
    Callback = function(Value) _G.Settings.JumpToggle = Value end
})

Tabs.Player:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50, Min = 50, Max = 500, Rounding = 0,
    Callback = function(Value) _G.Settings.JumpPower = Value end
})

Tabs.Player:AddToggle("InfJumpToggle", { Title = "Infinite Jump", Default = false, Callback = function(Value) _G.Settings.InfJump = Value end })
Tabs.Player:AddToggle("NoclipToggle", { Title = "Noclip", Default = false, Callback = function(Value) _G.Settings.Noclip = Value end })
Tabs.Player:AddToggle("WaterToggle", { Title = "Walk on Water", Default = false, Callback = function(Value) _G.Settings.WalkOnWater = Value end })

-- [ VISUALS TAB ]
Tabs.Visuals:AddToggle("ESPToggle", {
    Title = "Player ESP",
    Default = false,
    Callback = function(Value) _G.Settings.ESP = Value end
})

-- Initialize UI
Window:SelectTab(1)
Fluent:Notify({ Title = "HAMI HUB Loaded", Content = "Teleports & Combat Hooks Restored.", Duration = 4 })
