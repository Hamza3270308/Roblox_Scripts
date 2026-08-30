-- HAMI HUB | Blox Fruits Script
-- Migrated to Fluent Library (Vertical Layout)

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
local TweenService = game:GetService("TweenService")

_G.Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedToggle = false,
    JumpToggle = false,
    WalkOnWater = false,
    ESP = false,
}

-- ==========================================
-- CORE FUNCTIONS
-- ==========================================

-- Tween Teleportation
local function TweenTeleport(TargetCFrame, Speed)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = LocalPlayer.Character.HumanoidRootPart
    local Distance = (HRP.Position - TargetCFrame.Position).Magnitude
    local TweenInfoData = TweenInfo.new(Distance / (Speed or 300), Enum.EasingStyle.Linear)
    
    local Tween = TweenService:Create(HRP, TweenInfoData, {CFrame = TargetCFrame})
    Tween:Play()
    return Tween
end

-- Walk on Water Platform
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
        
        -- Force Movement Stats
        if _G.Settings.SpeedToggle and Humanoid then
            Humanoid.WalkSpeed = _G.Settings.WalkSpeed
        end
        if _G.Settings.JumpToggle and Humanoid then
            Humanoid.JumpPower = _G.Settings.JumpPower
        end
        
        -- Walk on Water Logic
        if _G.Settings.WalkOnWater then
            WaterPlatform.CFrame = HRP.CFrame * CFrame.new(0, -3.5, 0)
        else
            WaterPlatform.CFrame = CFrame.new(0, 50000, 0) -- Move away when disabled
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

-- PLAYER TAB
Tabs.Player:AddToggle("SpeedToggle", {
    Title = "Enable Custom Speed",
    Default = false,
    Callback = function(Value)
        _G.Settings.SpeedToggle = Value
    end
})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "Player Speed",
    Description = "Overrides default speed.",
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        _G.Settings.WalkSpeed = Value
    end
})

Tabs.Player:AddToggle("WaterToggle", {
    Title = "Walk on Water",
    Description = "Prevents ocean damage.",
    Default = false,
    Callback = function(Value)
        _G.Settings.WalkOnWater = Value
    end
})

-- VISUALS TAB
Tabs.Visuals:AddToggle("ESP", {
    Title = "Player ESP",
    Default = false,
    Callback = function(Value)
        _G.Settings.ESP = Value
        if not Value then
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name == "ESP_Highlight" then v:Destroy() end
            end
        end
    end
})

RunService.RenderStepped:Connect(function()
    if _G.Settings.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not player.Character:FindFirstChild("ESP_Highlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Highlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.Parent = player.Character
                end
            end
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({
    Title = "HAMI HUB Loaded",
    Content = "Fluent UI and core modules activated.",
    Duration = 5
})
