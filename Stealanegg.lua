-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create Window with Custom Green Theme
local Window = Rayfield:CreateWindow({
   Name = "Hami Hub | Steal An Egg",
   LoadingTitle = "Loading Hami Hub...",
   LoadingSubtitle = "Automating the Grind",
   ConfigurationSaving = {
      Enabled = false,
      FileName = "HamiHub"
   },
   KeySystem = false,
   -- Custom Green Theme Injection
   Theme = {
        TextColor = Color3.fromRGB(0, 255, 0), -- Green Text
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(34, 34, 34),
        Shadow = Color3.fromRGB(20, 20, 20),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground = Color3.fromRGB(235, 235, 235),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(0, 200, 0), -- Green Selected Tab
        TabTextColor = Color3.fromRGB(0, 255, 0), -- Green Tab Text
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
        SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
        ElementStroke = Color3.fromRGB(50, 50, 50),
        SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
        SliderBackground = Color3.fromRGB(0, 255, 0), -- Green Slider
        SliderProgress = Color3.fromRGB(0, 255, 0),
        SliderStroke = Color3.fromRGB(0, 255, 0),
        ToggleBackground = Color3.fromRGB(30, 30, 30),
        ToggleEnabled = Color3.fromRGB(0, 255, 0), -- Green Toggle
        ToggleBorders = Color3.fromRGB(50, 50, 50),
        DropdownSelected = Color3.fromRGB(40, 40, 40),
        DropdownUnselected = Color3.fromRGB(30, 30, 30),
        InputBackground = Color3.fromRGB(30, 30, 30),
        InputStroke = Color3.fromRGB(65, 65, 65),
        PlaceholderColor = Color3.fromRGB(0, 200, 0)
    }
})

-- Create Tabs
local AutoFarmTab = Window:CreateTab("Auto Farm", "shopping-cart")
local UpgradesTab = Window:CreateTab("Upgrades", "trending-up")
local PlayerTab = Window:CreateTab("Player", "user")

-- Global Variables
_G.AutoSteal = false
_G.AutoCollect = false
local originalBaseLocation = nil
local speedConnection = nil
local cframeSpeed = 16

-- ==========================================
-- AUTO FARM TAB
-- ==========================================

AutoFarmTab:CreateSection("Dynamic Egg Stealing")
AutoFarmTab:CreateParagraph({
    Title = "IMPORTANT INSTRUCTION",
    Content = "Stand exactly where you want to drop the eggs off (in your base) BEFORE turning this toggle on. It will save your current location as the return point."
})

local function findEggPrompt()
    -- Dynamically search the entire map for interactable Egg prompts
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local actionText = string.lower(obj.ActionText)
            local objectText = string.lower(obj.ObjectText)
            
            -- If the prompt says "Steal" or "Egg", it's what we want
            if string.find(actionText, "steal") or string.find(objectText, "egg") or string.find(actionText, "egg") then
                return obj
            end
        end
    end
    return nil
end

local AutoStealToggle = AutoFarmTab:CreateToggle({
   Name = "Auto Steal Eggs",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
        _G.AutoSteal = Value
        
        local character = LocalPlayer.Character
        if _G.AutoSteal and character and character:FindFirstChild("HumanoidRootPart") then
            -- Save the player's base location when they toggle it on
            originalBaseLocation = character.HumanoidRootPart.CFrame
            Rayfield:Notify({
               Title = "Location Saved",
               Content = "Return location set to your current spot.",
               Duration = 3,
               Image = 4483362458,
            })
        end
        
        if _G.AutoSteal then
            task.spawn(function()
                while _G.AutoSteal do
                    task.wait(1)
                    local char = LocalPlayer.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
                    
                    local eggPrompt = findEggPrompt()
                    
                    if eggPrompt and eggPrompt.Parent and eggPrompt.Parent:IsA("BasePart") then
                        local eggPart = eggPrompt.Parent
                        
                        -- 1. Teleport to Egg
                        char.HumanoidRootPart.CFrame = eggPart.CFrame
                        task.wait(0.5) -- Wait for server to register you are there
                        
                        -- 2. Fire Prompt to steal
                        fireproximityprompt(eggPrompt)
                        task.wait(0.5)
                        
                        -- 3. Teleport back to saved Base location
                        if originalBaseLocation then
                            char.HumanoidRootPart.CFrame = originalBaseLocation
                            task.wait(1) -- Wait to hatch/deposit before looping again
                        end
                    end
                end
            end)
        end
   end,
})


-- ==========================================
-- PLAYER TAB (Anti-Cheat Bypasses)
-- ==========================================
PlayerTab:CreateSection("Bypass Movement")

local WalkSpeedSlider = PlayerTab:CreateSlider({
   Name = "CFrame Speed Hack (Bypasses Rubberband)",
   Range = {16, 150},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "CFrameSpeed",
   Callback = function(Value)
        cframeSpeed = Value
        
        -- Clean up existing connection if there is one
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        
        -- If slider is above default speed, start the CFrame bypass
        if cframeSpeed > 16 then
            speedConnection = RunService.RenderStepped:Connect(function(deltaTime)
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = character.Humanoid
                    local rootPart = character.HumanoidRootPart
                    
                    -- Only boost speed if the player is actually trying to move (using WASD or Joystick)
                    if humanoid.MoveDirection.Magnitude > 0 then
                        -- Calculate extra distance to move this frame
                        local extraSpeed = (cframeSpeed - 16)
                        local displacement = humanoid.MoveDirection * extraSpeed * deltaTime
                        
                        -- Push the character forward
                        rootPart.CFrame = rootPart.CFrame + displacement
                    end
                end
            end)
        end
   end,
})
