-- HAMI HUB | Blox Fruits Script
-- UI Populated, Teleports Added, Movement/Visuals Added
-- FIXED: Auto Attack & Fast Attack using VirtualInputManager & Dynamic Upvalues

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "HAMI HUB | Blox Fruits",
    SubTitle = "by Hamii0327",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

_G.Settings = {
    -- Combat
    AutoAttack = false,
    FastAttack = true,
    AutoClick = false,
    AutoEquip = false,
    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedToggle = false,
    JumpToggle = false,
    WalkOnWater = false,
    Noclip = false,
    InfJump = false,
    Fly = false,
    FlySpeed = 50,
    AntiSit = false,
    -- Visuals
    ESP = false,
    RemoveFog = false,
    FPSSaver = false,
}

-- ==========================================
-- COMBAT FRAMEWORK HOOKS (FIXED)
-- ==========================================
local CombatFrameworkR = nil

task.spawn(function()
    pcall(function()
        local CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
        -- Dynamically search for activeController to prevent update patches
        for i, v in pairs(getupvalues(CombatFramework) or debug.getupvalues(CombatFramework)) do
            if type(v) == "table" and v.activeController ~= nil then
                CombatFrameworkR = v
                break
            end
        end
        -- Fallback if not found instantly
        if not CombatFrameworkR then
            CombatFrameworkR = (getupvalues(CombatFramework) or debug.getupvalues(CombatFramework))[2]
        end
    end)
end)

-- Auto Attack / Auto Click / Auto Equip Loops
task.spawn(function()
    while task.wait(0.1) do
        -- Auto Equip First Tool
        if _G.Settings.AutoEquip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
            end
        end

        -- Safe Auto Click (Engine-Level Simulation)
        if _G.Settings.AutoClick or (_G.Settings.AutoAttack and not _G.Settings.FastAttack) then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end

        -- Fast Attack (Client Cooldown Bypass + Redundant VIM Click)
        if _G.Settings.AutoAttack and _G.Settings.FastAttack and LocalPlayer.Character then
            if CombatFrameworkR and CombatFrameworkR.activeController then
                local ac = CombatFrameworkR.activeController
                if ac and ac.equipped then
                    pcall(function()
                        ac.timeToNextAttack = 0
                        ac.timeToNextBlock = 0
                        ac.increment = 3
                        ac:attack()
                        
                        -- Redundancy check to ensure hit registers
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                end
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
        local tweenTime = distance / 300 
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(HRP, tweenInfo, {CFrame = targetCFrame})
        
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
-- BACKGROUND LOOPS (Mods, Movement, Visuals)
-- ==========================================
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(10, 1, 10)
WaterPlatform.Transparency = 1
WaterPlatform.Anchored = true
WaterPlatform.CanCollide = true
WaterPlatform.Parent = workspace

local bodyVelocity = nil
local bodyGyro = nil
local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local HRP = char.HumanoidRootPart
        local Humanoid = char.Humanoid
        
        -- Speed & Jump
        if _G.Settings.SpeedToggle then Humanoid.WalkSpeed = _G.Settings.WalkSpeed end
        if _G.Settings.JumpToggle then Humanoid.JumpPower = _G.Settings.JumpPower end
        
        -- Anti Sit
        if _G.Settings.AntiSit and Humanoid.Sit then Humanoid.Sit = false end

        -- Walk on Water
        if _G.Settings.WalkOnWater then
            WaterPlatform.CFrame = HRP.CFrame * CFrame.new(0, -3.5, 0)
        else
            WaterPlatform.CFrame = CFrame.new(0, 50000, 0)
        end

        -- Fly Logic
        if _G.Settings.Fly then
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bodyVelocity.Parent = HRP
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyGyro.P = 9e4
                bodyGyro.Parent = HRP
            end
            
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            bodyVelocity.Velocity = moveDir * _G.Settings.FlySpeed
            bodyGyro.CFrame = camera.CFrame
        else
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        end
    end

    -- Remove Fog
    if _G.Settings.RemoveFog then
        Lighting.FogEnd = 100000
        if Lighting:FindFirstChildOfClass("Atmosphere") then
            Lighting:FindFirstChildOfClass("Atmosphere").Density = 0
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

-- [ COMBAT TAB ]
Tabs.Combat:AddToggle("AutoAttackToggle", { Title = "Auto Attack", Default = false, Callback = function(Value) _G.Settings.AutoAttack = Value end })
Tabs.Combat:AddToggle("FastAttackToggle", { Title = "Fast Attack Mode", Default = true, Callback = function(Value) _G.Settings.FastAttack = Value end })
Tabs.Combat:AddToggle("AutoClickToggle", { Title = "Auto Click (Normal)", Default = false, Callback = function(Value) _G.Settings.AutoClick = Value end })
Tabs.Combat:AddToggle("AutoEquipToggle", { Title = "Auto Equip Weapon", Default = false, Callback = function(Value) _G.Settings.AutoEquip = Value end })

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
Tabs.Player:AddToggle("SpeedToggle", { Title = "Enable Custom Speed", Default = false, Callback = function(Value) _G.Settings.SpeedToggle = Value end })
Tabs.Player:AddSlider("WalkSpeed", { Title = "Player Speed", Default = 16, Min = 16, Max = 300, Rounding = 0, Callback = function(Value) _G.Settings.WalkSpeed = Value end })
Tabs.Player:AddToggle("JumpToggle", { Title = "Enable Custom Jump", Default = false, Callback = function(Value) _G.Settings.JumpToggle = Value end })
Tabs.Player:AddSlider("JumpPower", { Title = "Jump Power", Default = 50, Min = 50, Max = 500, Rounding = 0, Callback = function(Value) _G.Settings.JumpPower = Value end })
Tabs.Player:AddToggle("InfJumpToggle", { Title = "Infinite Jump", Default = false, Callback = function(Value) _G.Settings.InfJump = Value end })
Tabs.Player:AddToggle("NoclipToggle", { Title = "Noclip", Default = false, Callback = function(Value) _G.Settings.Noclip = Value end })
Tabs.Player:AddToggle("WaterToggle", { Title = "Walk on Water", Default = false, Callback = function(Value) _G.Settings.WalkOnWater = Value end })
Tabs.Player:AddToggle("AntiSitToggle", { Title = "Anti Sit", Default = false, Callback = function(Value) _G.Settings.AntiSit = Value end })

Tabs.Player:AddToggle("FlyToggle", { Title = "Fly", Description = "Use WASD + Space/Shift to fly", Default = false, Callback = function(Value) _G.Settings.Fly = Value end })
Tabs.Player:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 50, Min = 16, Max = 300, Rounding = 0, Callback = function(Value) _G.Settings.FlySpeed = Value end })

-- [ VISUALS TAB ]
Tabs.Visuals:AddToggle("ESPToggle", { Title = "Player ESP", Default = false, Callback = function(Value) _G.Settings.ESP = Value end })
Tabs.Visuals:AddToggle("RemoveFogToggle", { Title = "Remove Fog", Default = false, Callback = function(Value) _G.Settings.RemoveFog = Value end })
Tabs.Visuals:AddToggle("FPSSaverToggle", {
    Title = "FPS Saver",
    Description = "Removes textures & materials to boost FPS",
    Default = false,
    Callback = function(Value)
        _G.Settings.FPSSaver = Value
        if Value then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end
    end
})

-- Initialize UI
Window:SelectTab(1)
Fluent:Notify({ Title = "HAMI HUB V2", Content = "Combat Hooks Fixed & Ready.", Duration = 4 })
