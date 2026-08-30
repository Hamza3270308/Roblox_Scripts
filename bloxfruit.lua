-- HAMI HUB | Blox Fruits Script
-- UI Populated, Combat Hooks Restored, Missing Mods Added

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

_G.Settings = {
    AutoAttack = false,
    FastAttack = true,
    AttackType = "Fast",
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
-- COMBAT FRAMEWORK HOOKS
-- ==========================================
local CombatFrameworkR = nil
task.spawn(function()
    pcall(function()
        local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
        CombatFrameworkR = getupvalues(CombatFramework)[2] or debug.getupvalue(CombatFramework, 2)
    end)
end)

function getAllBladeHits(Sizes)
    local Hits = {}
    local Enemies = workspace.Enemies:GetChildren()
    for i=1,#Enemies do 
        local v = Enemies[i]
        local Human = v:FindFirstChildOfClass("Humanoid")
        if Human and Human.RootPart and Human.Health > 0 and LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
            table.insert(Hits, Human.RootPart)
        end
    end
    return Hits
end

function CurrentWeapon()
    if not CombatFrameworkR then return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    local ac = CombatFrameworkR.activeController
    if not ac then return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    local ret = ac.blades[1]
    if not ret then return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    pcall(function()
        while ret.Parent ~= LocalPlayer.Character do ret = ret.Parent end
    end)
    if not ret then return LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    return ret
end

function AttackFunction()
    if not CombatFrameworkR then return end
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        for indexincrement = 1, 1 do
            local bladehit = getAllBladeHits(60)
            if #bladehit > 0 then
                pcall(function()
                    local AcAttack8 = debug.getupvalue(ac.attack, 5)
                    local AcAttack9 = debug.getupvalue(ac.attack, 6)
                    local AcAttack7 = debug.getupvalue(ac.attack, 4)
                    local AcAttack10 = debug.getupvalue(ac.attack, 7)
                    local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
                    local NumberAc13 = AcAttack7 * 798405
                    (function()
                        NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
                        AcAttack8 = math.floor(NumberAc12 / AcAttack9)
                        AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
                    end)()
                    AcAttack10 = AcAttack10 + 1
                    debug.setupvalue(ac.attack, 5, AcAttack8)
                    debug.setupvalue(ac.attack, 6, AcAttack9)
                    debug.setupvalue(ac.attack, 4, AcAttack7)
                    debug.setupvalue(ac.attack, 7, AcAttack10)
                    for k, v in pairs(ac.animator.anims.basic) do
                        v:Play(0.01,0.01,0.01)
                    end                  
                    if LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
                        game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
                        game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
                        game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
                    end
                end)
            end
        end
    end
end

-- ==========================================
-- BACKGROUND LOOPS (Mods & Combat)
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
        
        -- WalkSpeed & JumpPower Enforcer
        if _G.Settings.SpeedToggle and Humanoid then
            Humanoid.WalkSpeed = _G.Settings.WalkSpeed
        end
        if _G.Settings.JumpToggle and Humanoid then
            Humanoid.JumpPower = _G.Settings.JumpPower
        end
        
        -- Walk on Water
        if _G.Settings.WalkOnWater then
            WaterPlatform.CFrame = HRP.CFrame * CFrame.new(0, -3.5, 0)
        else
            WaterPlatform.CFrame = CFrame.new(0, 50000, 0)
        end
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if _G.Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump Hook
UserInputService.JumpRequest:Connect(function()
    if _G.Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Auto Attack Loop
local cooldownfastattack = tick()
task.spawn(function()
    while task.wait(.1) do
        if _G.Settings.AutoAttack and CombatFrameworkR then
            local ac = CombatFrameworkR.activeController
            if ac and ac.equipped then
                if _G.Settings.FastAttack then
                    AttackFunction()
                    if _G.Settings.AttackType == "Normal" and tick() - cooldownfastattack > .9 then 
                        task.wait(.1); cooldownfastattack = tick() 
                    elseif _G.Settings.AttackType == "Fast" and tick() - cooldownfastattack > 1.5 then 
                        task.wait(.01); cooldownfastattack = tick() 
                    elseif _G.Settings.AttackType == "Slow" and tick() - cooldownfastattack > .3 then 
                        task.wait(.7); cooldownfastattack = tick() 
                    end
                else
                    if ac.hitboxMagnitude ~= 55 then ac.hitboxMagnitude = 55 end
                    pcall(function() ac:attack() end)
                end
            end
        end
    end
end)

-- ==========================================
-- TABS & UI CREATION
-- ==========================================
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" })
}

-- [ MAIN TAB ]
Tabs.Main:AddToggle("AutoAttackToggle", {
    Title = "Auto Attack",
    Description = "Automatically attacks nearby mobs.",
    Default = false,
    Callback = function(Value)
        _G.Settings.AutoAttack = Value
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

Tabs.Player:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Description = "Jump in mid-air infinitely.",
    Default = false,
    Callback = function(Value) _G.Settings.InfJump = Value end
})

Tabs.Player:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Description = "Walk through walls.",
    Default = false,
    Callback = function(Value) _G.Settings.Noclip = Value end
})

Tabs.Player:AddToggle("WaterToggle", {
    Title = "Walk on Water",
    Default = false,
    Callback = function(Value) _G.Settings.WalkOnWater = Value end
})

-- [ VISUALS TAB ]
local function createESP(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if not player.Character.HumanoidRootPart:FindFirstChild("ESP_BOX") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESP_BOX"
            box.Size = player.Character.HumanoidRootPart.Size + Vector3.new(2, 3, 2)
            box.Adornee = player.Character.HumanoidRootPart
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Transparency = 0.5
            box.Color3 = Color3.fromRGB(255, 0, 0)
            box.Parent = player.Character.HumanoidRootPart
        end
    end
end

Tabs.Visuals:AddToggle("ESPToggle", {
    Title = "Player ESP",
    Description = "Draws boxes around players.",
    Default = false,
    Callback = function(Value)
        _G.Settings.ESP = Value
        if not Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local esp = player.Character.HumanoidRootPart:FindFirstChild("ESP_BOX")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
})

task.spawn(function()
    while task.wait(1) do
        if _G.Settings.ESP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function() createESP(player) end)
                end
            end
        end
    end
end)

-- [ COMBAT TAB ]
Tabs.Combat:AddToggle("FastAttackToggle", {
    Title = "Fast Attack",
    Default = true,
    Callback = function(Value) _G.Settings.FastAttack = Value end
})

Tabs.Combat:AddDropdown("AttackTypeDrop", {
    Title = "Fast Attack Type",
    Values = {"Fast", "Normal", "Slow"},
    Multi = false,
    Default = 1,
    Callback = function(Value) _G.Settings.AttackType = Value end
})

Window:SelectTab(1)
Fluent:Notify({ Title = "HAMI HUB Fixed", Content = "Tabs populated and features restored.", Duration = 4 })
