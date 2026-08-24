-- Hami Hub - Delta/Emulator Optimized
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wrap the UI loader in a pcall so Delta doesn't crash if the request fails
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
end)

if not success or not OrionLib then
    warn("Hami Hub Error: Delta failed to fetch the UI library.")
    return
end

local Window = OrionLib:MakeWindow({
    Name = "Hami Hub - Steal An Egg",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "Hami Hub Loading...",
    Color = Color3.fromRGB(0, 255, 0)
})

local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local FarmTab = Window:MakeTab({ Name = "Egg Farming", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- ==========================================
-- 1. PLAYER TAB
-- ==========================================

PlayerTab:AddSlider({
    Name = "Walkspeed Bypass",
    Min = 16,
    Max = 300,
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

-- ==========================================
-- 2. EGG FARMING TAB (Optimized for Emulators)
-- ==========================================

local eggCache = {}
local autoFarm = false

-- Function to safely locate eggs without crashing Delta
local function refreshEggCache()
    table.clear(eggCache)
    for _, item in pairs(workspace:GetDescendants()) do
        -- Looks for models or parts named "Egg" or "Nest"
        if string.find(string.lower(item.Name), "egg") or string.find(string.lower(item.Name), "nest") then
            if item:IsA("Model") and item.PrimaryPart then
                table.insert(eggCache, item.PrimaryPart)
            elseif item:IsA("BasePart") then
                table.insert(eggCache, item)
            end
        end
    end
    OrionLib:MakeNotification({Name = "Cache Updated", Content = "Found " .. #eggCache .. " egg locations.", Time = 3})
end

FarmTab:AddButton({
    Name = "Refresh Map Egg Locations",
    Callback = function()
        refreshEggCache()
    end    
})

FarmTab:AddToggle({
    Name = "Auto Steal & Return (Requires Cache)",
    Default = false,
    Callback = function(Value)
        autoFarm = Value
        
        if autoFarm then
            if #eggCache == 0 then
                refreshEggCache()
            end
            
            -- Runs in a separate thread so Delta's UI doesn't freeze
            task.spawn(function()
                while autoFarm do
                    for _, targetPart in pairs(eggCache) do
                        if not autoFarm then break end
                        
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and targetPart and targetPart.Parent then
                            
                            -- 1. Teleport to the Egg/Nest
                            char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0)
                            task.wait(1) -- Wait for pickup
                            
                            -- 2. Teleport back to Base (Pen)
                            local spawnPoint = workspace:FindFirstChild("SpawnLocation", true) 
                            if spawnPoint then
                                char.HumanoidRootPart.CFrame = spawnPoint.CFrame * CFrame.new(0, 3, 0)
                                task.wait(1) -- Wait for drop-off / hatch
                            end
                        end
                    end
                    task.wait(2) -- Pause before restarting the loop
                end
            end)
        end
    end    
})

OrionLib:Init()
