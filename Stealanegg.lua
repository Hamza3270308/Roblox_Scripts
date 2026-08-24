-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Window Creation with Green Theme
local Window = Rayfield:CreateWindow({
   Name = "Hami Hub | Steal An Egg",
   LoadingTitle = "Loading Hami Hub...",
   LoadingSubtitle = "Automating the Grind",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
   Theme = {
        TextColor = Color3.fromRGB(0, 255, 0),
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(34, 34, 34),
        Shadow = Color3.fromRGB(20, 20, 20),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground = Color3.fromRGB(235, 235, 235),
        TabBackground = Color3.fromRGB(80, 80, 80),
        TabStroke = Color3.fromRGB(85, 85, 85),
        TabBackgroundSelected = Color3.fromRGB(0, 200, 0),
        TabTextColor = Color3.fromRGB(0, 255, 0),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
        SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
        ElementStroke = Color3.fromRGB(50, 50, 50),
        SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
        SliderBackground = Color3.fromRGB(0, 255, 0),
        SliderProgress = Color3.fromRGB(0, 255, 0),
        SliderStroke = Color3.fromRGB(0, 255, 0),
        ToggleBackground = Color3.fromRGB(30, 30, 30),
        ToggleEnabled = Color3.fromRGB(0, 255, 0),
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

-- Variables
_G.AutoSteal = false
_G.AutoBuySpeed = false
_G.InfJump = false
local originalBaseLocation = nil
local speedConnection = nil
local infJumpConnection = nil
local cframeSpeed = 16

-- ==========================================
-- AUTO FARM TAB
-- ==========================================
AutoFarmTab:CreateSection("Egg Stealing")
AutoFarmTab:CreateParagraph({
    Title = "IMPORTANT INSTRUCTION",
    Content = "Stand exactly where you want to drop the eggs off (in your base) BEFORE turning this toggle on. It will save your current location as the return point."
})

-- Dynamic function to find eggs (Supports both Prompt and Touch)
local function getEggTarget()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local txt = string.lower(obj.ActionText .. " " .. obj.ObjectText)
            if string.find(txt, "steal") or string.find(txt, "egg") then
                return obj, "Prompt"
            end
        elseif obj:IsA("TouchTransmitter") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") and (string.find(string.lower(parent.Name), "egg") or string.find(string.lower(parent.Name), "steal") or string.find(string.lower(parent.Name), "nest")) then
                return parent, "Touch"
            end
        end
    end
    return nil, nil
end

AutoFarmTab:CreateToggle({
   Name = "Auto Steal Eggs (Dynamic)",
   CurrentValue = false,
   Flag = "AutoStealToggle",
   Callback = function(Value)
        _G.AutoSteal = Value
        local char = LocalPlayer.Character
        
        if _G.AutoSteal and char and char:FindFirstChild("HumanoidRootPart") then
            originalBaseLocation = char.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Location Saved", Content = "Return location set to your base.", Duration = 3})
        end
        
        if _G.AutoSteal then
            task.spawn(function()
                while _G.AutoSteal do
                    task.wait(0.5)
                    local currentCharacter = LocalPlayer.Character
                    if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then continue end
                    
                    local target, interactType = getEggTarget()
                    
                    if target then
                        if interactType == "Prompt" and target.Parent and target.Parent:IsA("BasePart") then
                            -- Teleport and prompt
                            currentCharacter.HumanoidRootPart.CFrame = target.Parent.CFrame
                            task.wait(0.5)
                            fireproximityprompt(target)
                        elseif interactType == "Touch" then
                            -- Teleport and touch
                            currentCharacter.HumanoidRootPart.CFrame = target.CFrame
                            task.wait(0.5)
                            firetouchinterest(currentCharacter.HumanoidRootPart, target, 0)
                            task.wait(0.1)
                            firetouchinterest(currentCharacter.HumanoidRootPart, target, 1)
                        end
                        
                        task.wait(0.5)
                        
                        -- Return home to drop off
                        if originalBaseLocation then
                            currentCharacter.HumanoidRootPart.CFrame = originalBaseLocation
                            task.wait(1.5) -- Wait to hatch/deposit
                        end
                    else
                        task.wait(2)
                    end
                end
            end)
        end
   end,
})

-- ==========================================
-- UPGRADES TAB
-- ==========================================
UpgradesTab:CreateSection("Auto Upgrades")
UpgradesTab:CreateToggle({
   Name = "Auto Buy Speed",
   CurrentValue = false,
   Flag = "AutoBuySpeed",
   Callback = function(Value)
        _G.AutoBuySpeed = Value
        if _G.AutoBuySpeed then
            task.spawn(function()
                while _G.AutoBuySpeed do
                    task.wait(1)
                    -- Dynamic remote finding for upgrades
                    local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
                    for _, remote in pairs(remotes) do
                        if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "buy") or string.find(string.lower(remote.Name), "upgrade")) then
                            pcall(function() remote:FireServer("Speed") end)
                            pcall(function() remote:FireServer("WalkSpeed") end)
                        end
                    end
                end
            end)
        end
   end,
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
PlayerTab:CreateSection("Movement Bypasses")

PlayerTab:CreateSlider({
   Name = "CFrame Speed Hack",
   Range = {16, 150},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "CFrameSpeed",
   Callback = function(Value)
        cframeSpeed = Value
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        
        if cframeSpeed > 16 then
            speedConnection = RunService.RenderStepped:Connect(function(deltaTime)
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    local hum = char.Humanoid
                    if hum.MoveDirection.Magnitude > 0 then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (hum.MoveDirection * (cframeSpeed - 16) * deltaTime)
                    end
                end
            end)
        end
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump (High Jump Bypass)",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
        _G.InfJump = Value
        if _G.InfJump then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection = nil end
        end
   end,
})

PlayerTab:CreateSection("Teleportation")

PlayerTab:CreateButton({
   Name = "Get 'Click to Teleport' Tool",
   Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "Click to TP"
        tool.RequiresHandle = false
        tool.Parent = LocalPlayer.Backpack
        
        local mouse = LocalPlayer:GetMouse()
        tool.Activated:Connect(function()
            if mouse.Hit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Teleports you exactly where your mouse clicks
                LocalPlayer.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
            end
        end)
        Rayfield:Notify({Title = "Tool Given!", Content = "Check your inventory for the 'Click to TP' tool.", Duration = 4})
   end,
})
