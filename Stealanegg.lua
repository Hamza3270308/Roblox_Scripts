-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Load the Orion Library (Using the working jensonhirst fork for executors like Delta/Fluxus)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Create the Main Window
local Window = OrionLib:MakeWindow({
    Name = "Hami Hub | Steal an Egg", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroEnabled = true,
    IntroText = "Hami Hub Loading..."
})

---------------------------------------------------------
-- TAB 1: MAIN (AUTOMATION)
---------------------------------------------------------
local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

MainTab:AddSection({Name = "Auto Farming"})

MainTab:AddToggle({
	Name = "Auto Place Egg",
	Default = false,
	Callback = function(Value)
        getgenv().AutoPlace = Value
        while getgenv().AutoPlace do
            task.wait(0.5)
            pcall(function()
                -- Replace 'PlaceEgg' with the exact remote name if different
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlaceEgg"):FireServer()
            end)
        end
	end    
})

MainTab:AddToggle({
	Name = "Auto Recover Egg",
	Default = false,
	Callback = function(Value)
        getgenv().AutoRecover = Value
        while getgenv().AutoRecover do
            task.wait(0.5)
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RecoverEgg"):FireServer()
            end)
        end
	end    
})

MainTab:AddToggle({
	Name = "Auto Sell Egg",
	Default = false,
	Callback = function(Value)
        getgenv().AutoSell = Value
        while getgenv().AutoSell do
            task.wait(1)
            pcall(function()
                -- Assuming touching a sell pad or firing a remote
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sell"):FireServer()
            end)
        end
	end    
})

MainTab:AddToggle({
	Name = "Auto Hatch",
	Default = false,
	Callback = function(Value)
        getgenv().AutoHatch = Value
        while getgenv().AutoHatch do
            task.wait(0.2)
            pcall(function()
                -- Standard pet hatching remote structure
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyEgg"):InvokeServer("BasicEgg", 1)
            end)
        end
	end    
})

MainTab:AddSection({Name = "Progression"})

MainTab:AddToggle({
	Name = "Auto Claim Rewards",
	Default = false,
	Callback = function(Value)
        getgenv().AutoClaim = Value
        while getgenv().AutoClaim do
            task.wait(5)
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClaimReward"):FireServer()
            end)
        end
	end    
})

MainTab:AddToggle({
	Name = "Auto Rebirth",
	Default = false,
	Callback = function(Value)
        getgenv().AutoRebirth = Value
        while getgenv().AutoRebirth do
            task.wait(2)
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Rebirth"):FireServer()
            end)
        end
	end    
})

MainTab:AddToggle({
	Name = "Auto Upgrade Treadmill",
	Default = false,
	Callback = function(Value)
        getgenv().AutoUpgradeT = Value
        while getgenv().AutoUpgradeT do
            task.wait(1)
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Upgrade"):FireServer("Treadmill")
            end)
        end
	end    
})

MainTab:AddToggle({
	Name = "Auto Upgrade Base",
	Default = false,
	Callback = function(Value)
        getgenv().AutoUpgradeB = Value
        while getgenv().AutoUpgradeB do
            task.wait(1)
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Upgrade"):FireServer("Base")
            end)
        end
	end    
})

---------------------------------------------------------
-- TAB 2: PLAYER
---------------------------------------------------------
local PlayerTab = Window:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

PlayerTab:AddSection({Name = "Movement Mods"})

PlayerTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 300,
	Default = 16,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
        getgenv().WalkSpeedValue = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
        end
	end    
})

PlayerTab:AddSlider({
	Name = "Jump Power",
	Min = 50,
	Max = 300,
	Default = 50,
	Color = Color3.fromRGB(0, 255, 0),
	Increment = 1,
	ValueName = "Power",
	Callback = function(Value)
        getgenv().JumpPowerValue = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = getgenv().JumpPowerValue
        end
	end    
})

-- Reapply speed/jump on respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    if getgenv().WalkSpeedValue then humanoid.WalkSpeed = getgenv().WalkSpeedValue end
    if getgenv().JumpPowerValue then 
        humanoid.UseJumpPower = true
        humanoid.JumpPower = getgenv().JumpPowerValue 
    end
end)

PlayerTab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Callback = function(Value)
        getgenv().InfJump = Value
	end    
})

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

---------------------------------------------------------
-- TAB 3: VISUALS
---------------------------------------------------------
local VisualsTab = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://4483362458",
	PremiumOnly = false
})

VisualsTab:AddSection({Name = "Visual Enhancements"})

VisualsTab:AddToggle({
	Name = "Egg ESP",
	Default = false,
	Callback = function(Value)
        getgenv().EggESP = Value
        while getgenv().EggESP do
            task.wait(1)
            -- Scans workspace for models named "Egg" and highlights them
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Model") and string.find(string.lower(item.Name), "egg") then
                    if not item:FindFirstChild("EggHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "EggHighlight"
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = item
                    end
                end
            end
        end
        -- Clean up ESP when toggled off
        if not getgenv().EggESP then
            for _, item in pairs(workspace:GetDescendants()) do
                if item:FindFirstChild("EggHighlight") then
                    item.EggHighlight:Destroy()
                end
            end
        end
	end    
})

VisualsTab:AddButton({
	Name = "Boost FPS",
	Callback = function()
        -- FPS Booster: Disables shadows and converts materials to smooth plastic
        local Lighting = game:GetService("Lighting")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        OrionLib:MakeNotification({
            Name = "FPS Boosted",
            Content = "Textures and shadows have been removed.",
            Image = "rbxassetid://4483362458",
            Time = 3
        })
  	end    
})

-- Initialize the UI
OrionLib:Init()
