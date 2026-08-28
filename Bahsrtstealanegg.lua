-- =================================================================
-- CONFIGURATION: Roblox Steal An Egg Mobile Script
-- =================================================================
local GameName = "Steal An Egg"
local CreatorName = "Badshah"

-- =================================================================
-- 1. SERVICES & VARIABLES
-- =================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local State = {
    AutoSteal = false,
    AutoTreadmill = false,
    AutoHatch = false,
    WalkSpeed = 16,
    InfiniteJump = false
}

local SavedBaseCFrame = nil

-- Helper: Trigger Proximity Prompts
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- =================================================================
-- 2. BACKGROUND FEATURE LOOPS
-- =================================================================

-- 1. Auto Steal & Safe Teleport Engine
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoSteal then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    if not SavedBaseCFrame then
                        SavedBaseCFrame = root.CFrame
                    end

                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoSteal then break end
                        if obj:IsA("ProximityPrompt") then
                            local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                            local actionText = string.lower(obj.ActionText or "")
                            local objText = string.lower(obj.ObjectText or "")

                            if string.find(parentName, "egg") or string.find(actionText, "steal") or string.find(actionText, "take") or string.find(objText, "egg") then
                                local eggPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                if eggPart then
                                    root.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.1)
                                    triggerPrompt(obj)
                                    task.wait(0.1)
                                    if SavedBaseCFrame then
                                        root.CFrame = SavedBaseCFrame
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Treadmill Train Engine
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoTreadmill then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoTreadmill then break end
                        local oName = string.lower(obj.Name)
                        if string.find(oName, "treadmill") or string.find(oName, "train") or string.find(oName, "speedpad") then
                            if obj:IsA("TouchTransmitter") and obj.Parent then
                                if firetouchinterest then
                                    firetouchinterest(obj.Parent, root, 0)
                                    task.wait()
                                    firetouchinterest(obj.Parent, root, 1)
                                end
                            elseif obj:IsA("ProximityPrompt") then
                                triggerPrompt(obj)
                            end
                        end
                    end

                    for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui")}) do
                        if container then
                            for _, remote in ipairs(container:GetDescendants()) do
                                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                    local rName = string.lower(remote.Name)
                                    if string.find(rName, "train") or string.find(rName, "treadmill") or string.find(rName, "addspeed") or string.find(rName, "speed") then
                                        pcall(function()
                                            if remote:IsA("RemoteEvent") then
                                                remote:FireServer()
                                                remote:FireServer(true)
                                            else
                                                remote:InvokeServer()
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Hatch & Place Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoHatch then
            pcall(function()
                for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}) do
                    if container then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if not State.AutoHatch then break end
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "hatch") or string.find(rName, "place") or string.find(rName, "openegg") or string.find(rName, "egghatch") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer(1)
                                        else
                                            remote:InvokeServer()
                                            remote:InvokeServer(true)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoHatch then break end
                    if obj:IsA("ProximityPrompt") then
                        local aText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        if string.find(aText, "hatch") or string.find(aText, "place") or string.find(oText, "hatch") then
                            triggerPrompt(obj)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. WalkSpeed Modifier Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and State.WalkSpeed and State.WalkSpeed ~= 16 then
            hum.WalkSpeed = State.WalkSpeed
        end
    end)
end)

-- 5. Infinite Air Jump System
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

-- =================================================================
-- 3. FEATURES CONFIGURATION TABLE
-- =================================================================
local Features = {
    {
        Type = "Toggle",
        Name = "Auto Steal & Return",
        Default = false,
        Callback = function(state)
            State.AutoSteal = state
            if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Treadmill Train",
        Default = false,
        Callback = function(state)
            State.AutoTreadmill = state
        end
    },
    {
        Type = "Toggle",
        Name = "Auto Hatch & Place",
        Default = false,
        Callback = function(state)
            State.AutoHatch = state
        end
    },
    {
        Type = "Toggle",
        Name = "Infinite Jump",
        Default = false,
        Callback = function(state)
            State.InfiniteJump = state
        end
    },
    {
        Type = "Slider",
        Name = "WalkSpeed",
        Min = 16,
        Max = 150,
        Default = 16,
        Callback = function(val)
            State.WalkSpeed = val
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    }
}

-- =================================================================
-- 4. STARTUP NOTIFICATION
-- =================================================================
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = CreatorName,
        Text = GameName .. " Script Loaded!",
        Duration = 4
    })
end)

-- =================================================================
-- 5. UI GENERATOR ENGINE (Mobile Optimized - 220px Width)
-- =================================================================
if CoreGui:FindFirstChild("RobloxScriptUI_Badshah") then
    CoreGui.RobloxScriptUI_Badshah:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxScriptUI_Badshah"
ScreenGui.ResetOnSpawn = false

local success, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Calculate dynamic container height
local totalContentHeight = 0
for _, feature in ipairs(Features) do
    if feature.Type == "Slider" then
        totalContentHeight = totalContentHeight + 46 + 6
    else
        totalContentHeight = totalContentHeight + 35 + 6
    end
end
if totalContentHeight > 0 then
    totalContentHeight = totalContentHeight - 6
end

local maxContainerHeight = 180
local containerHeight = totalContentHeight
local scrollEnabled = false

if totalContentHeight > maxContainerHeight then
    containerHeight = maxContainerHeight
    scrollEnabled = true
end

local windowHeight = 42 + containerHeight + 16 + 25

local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 220, 0, windowHeight)
MainWindow.Position = UDim2.new(0.5, -110, 0.5, -windowHeight/2)
MainWindow.BackgroundColor3 = Color3.fromRGB(15, 14, 22)
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Active = true
MainWindow.Parent = ScreenGui

local MainWindowCorner = Instance.new("UICorner")
MainWindowCorner.CornerRadius = UDim.new(0, 12)
MainWindowCorner.Parent = MainWindow

local MainWindowStroke = Instance.new("UIStroke")
MainWindowStroke.Thickness = 1
MainWindowStroke.Color = Color3.fromRGB(30, 28, 42)
MainWindowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainWindowStroke.Parent = MainWindow

-- Header Frame
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = MainWindow

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -65, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = GameName
TitleLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
TitleLabel.Parent = Header

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Position = UDim2.new(1, -48, 0.5, -10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.AutoButtonColor = false
MinimizeButton.Text = ""
MinimizeButton.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

local MinimizeText = Instance.new("TextLabel")
MinimizeText.Size = UDim2.new(1, 0, 1, 0)
MinimizeText.BackgroundTransparency = 1
MinimizeText.Text = "-"
MinimizeText.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeText.Font = Enum.Font.GothamBold
MinimizeText.TextSize = 13
MinimizeText.TextXAlignment = Enum.TextXAlignment.Center
MinimizeText.TextYAlignment = Enum.TextYAlignment.Center
MinimizeText.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -24, 0.5, -10)
CloseButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseButton.BorderSizePixel = 0
CloseButton.AutoButtonColor = false
CloseButton.Text = ""
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local CloseText = Instance.new("TextLabel")
CloseText.Size = UDim2.new(1, 0, 1, 0)
CloseText.BackgroundTransparency = 1
CloseText.Text = "\u{00D7}"
CloseText.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseText.Font = Enum.Font.GothamBold
CloseText.TextSize = 13
CloseText.TextXAlignment = Enum.TextXAlignment.Center
CloseText.TextYAlignment = Enum.TextYAlignment.Center
CloseText.Parent = CloseButton

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 41)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(30, 28, 42)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = Header

-- Content Container
local FeaturesContainer = Instance.new("ScrollingFrame")
FeaturesContainer.Name = "FeaturesContainer"
FeaturesContainer.Size = UDim2.new(1, -12, 0, containerHeight)
FeaturesContainer.Position = UDim2.new(0, 6, 0, 44)
FeaturesContainer.BackgroundTransparency = 1
FeaturesContainer.BorderSizePixel = 0
FeaturesContainer.ScrollBarThickness = scrollEnabled and 2 or 0
FeaturesContainer.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
FeaturesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
FeaturesContainer.Parent = MainWindow

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = FeaturesContainer

-- Footer Frame
local FooterFrame = Instance.new("Frame")
FooterFrame.Name = "Footer"
FooterFrame.Size = UDim2.new(1, 0, 0, 25)
FooterFrame.Position = UDim2.new(0, 0, 1, -25)
FooterFrame.BackgroundTransparency = 1
FooterFrame.Parent = MainWindow

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 1, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.RichText = true
FooterLabel.Text = "Made By: <b>" .. CreatorName .. "</b>"
FooterLabel.TextColor3 = Color3.fromRGB(191, 127, 255)
FooterLabel.Font = Enum.Font.GothamBold
FooterLabel.TextSize = 11
FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
FooterLabel.TextYAlignment = Enum.TextYAlignment.Center
FooterLabel.Parent = FooterFrame

-- Draggable Functionality
local function makeDraggable(dragFrame, parentFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        parentFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeDraggable(Header, MainWindow)

-- Minimize Button Logic
local minimized = false
local originalHeight = windowHeight
local headerHeight = 42

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetHeight = minimized and headerHeight or originalHeight
    MinimizeText.Text = minimized and "+" or "-"
    
    if minimized then
        FeaturesContainer.Visible = false
        FooterFrame.Visible = false
    else
        task.delay(0.1, function()
            if not minimized then
                FeaturesContainer.Visible = true
                FooterFrame.Visible = true
            end
        end)
    end
    
    TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 220, 0, targetHeight)
    }):Play()
end)

MinimizeButton.MouseEnter:Connect(function()
    TweenService:Create(MinimizeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(34, 31, 48)
    }):Play()
end)
MinimizeButton.MouseLeave:Connect(function()
    TweenService:Create(MinimizeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(24, 22, 34)
    }):Play()
end)

-- Close Button Logic
CloseButton.MouseButton1Click:Connect(function()
    local collapseTween = TweenService:Create(MainWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(
            MainWindow.Position.X.Scale, 
            MainWindow.Position.X.Offset + (MainWindow.Size.X.Offset / 2), 
            MainWindow.Position.Y.Scale, 
            MainWindow.Position.Y.Offset + (MainWindow.Size.Y.Offset / 2)
        )
    })
    collapseTween:Play()
    collapseTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(250, 80, 80)
    }):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    }):Play()
end)

-- Generate Toggles
local function createToggle(config)
    local Card = Instance.new("TextButton")
    Card.Name = config.Name .. "_Toggle"
    Card.Size = UDim2.new(1, 0, 0, 35)
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
    Card.BorderSizePixel = 0
    Card.AutoButtonColor = false
    Card.Text = ""
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -38, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Parent = Card
    
    local Checkbox = Instance.new("Frame")
    Checkbox.Size = UDim2.new(0, 16, 0, 16)
    Checkbox.Position = UDim2.new(1, -26, 0.5, -8)
    Checkbox.BackgroundColor3 = Color3.fromRGB(34, 31, 48)
    Checkbox.BorderSizePixel = 0
    
    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(0, 5)
    CheckboxCorner.Parent = Checkbox
    
    local Checkmark = Instance.new("TextLabel")
    Checkmark.Size = UDim2.new(1, 0, 1, 0)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Text = "\u{2713}"
    Checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    Checkmark.Font = Enum.Font.GothamBold
    Checkmark.TextSize = 10
    Checkmark.TextXAlignment = Enum.TextXAlignment.Center
    Checkmark.TextYAlignment = Enum.TextYAlignment.Center
    Checkmark.TextTransparency = 1
    Checkmark.Parent = Checkbox
    
    Checkbox.Parent = Card
    Card.Parent = FeaturesContainer
    
    local state = config.Default or false
    
    local function updateVisuals(animate)
        local targetColor = state and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(34, 31, 48)
        local targetTrans = state and 0 or 1
        
        if animate then
            TweenService:Create(Checkbox, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = targetColor
            }):Play()
            TweenService:Create(Checkmark, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = targetTrans
            }):Play()
        else
            Checkbox.BackgroundColor3 = targetColor
            Checkmark.TextTransparency = targetTrans
        end
    end
    
    updateVisuals(false)
    
    Card.MouseButton1Click:Connect(function()
        state = not state
        updateVisuals(true)
        
        local clickTween = TweenService:Create(Card, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(40, 36, 56)
        })
        clickTween:Play()
        clickTween.Completed:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(30, 28, 42)
            }):Play()
        end)
        
        task.spawn(function()
            local ok, err = pcall(config.Callback, state)
            if not ok then
                warn("Error in toggle callback '" .. config.Name .. "': " .. tostring(err))
            end
        end)
    end)
    
    Card.MouseEnter:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(30, 28, 42)
        }):Play()
    end)
    
    Card.MouseLeave:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        }):Play()
    end)
end

-- Generate Sliders
local function createSlider(config)
    local Card = Instance.new("Frame")
    Card.Name = config.Name .. "_Slider"
    Card.Size = UDim2.new(1, 0, 0, 46)
    Card.BackgroundColor3 = Color3.fromRGB(24, 22, 34)
    Card.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name .. ": " .. tostring(config.Default)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Parent = Card
    
    local Track = Instance.new("TextButton")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(34, 31, 48)
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 2)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    Fill.BorderSizePixel = 0
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = Fill
    Fill.Parent = Track
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 8, 0, 8)
    Knob.Position = UDim2.new(1, -4, 0.5, -4)
    Knob.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    Knob.BorderSizePixel = 0
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    Knob.Parent = Fill
    
    Track.Parent = Card
    Card.Parent = FeaturesContainer
    
    local minVal = config.Min or 0
    local maxVal = config.Max or 100
    local currentVal = config.Default or minVal
    
    local function updateValue(val, animate)
        currentVal = math.clamp(val, minVal, maxVal)
        local displayVal = math.round(currentVal)
        
        Label.Text = config.Name .. ": " .. tostring(displayVal)
        
        local percentage = (currentVal - minVal) / (maxVal - minVal)
        local targetSize = UDim2.new(percentage, 0, 1, 0)
        
        if animate then
            TweenService:Create(Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = targetSize
            }):Play()
        else
            Fill.Size = targetSize
        end
        
        task.spawn(function()
            local ok, err = pcall(config.Callback, displayVal)
            if not ok then
                warn("Error in slider callback '" .. config.Name .. "': " .. tostring(err))
            end
        end)
    end
    
    updateValue(currentVal, false)
    
    local isDragging = false
    
    local function processInput(input)
        local trackWidth = Track.AbsoluteSize.X
        if trackWidth > 0 then
            local relativeX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, trackWidth)
            local percentage = relativeX / trackWidth
            local newValue = minVal + (maxVal - minVal) * percentage
            updateValue(newValue, false)
        end
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            processInput(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            processInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    Card.MouseEnter:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(30, 28, 42)
        }):Play()
    end)
    
    Card.MouseLeave:Connect(function()
        TweenService:Create(Card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(24, 22, 34)
        }):Play()
    end)
end

-- =================================================================
-- 6. BUILD UI ELEMENTS & LAUNCH ANIMATION
-- =================================================================
for _, feature in ipairs(Features) do
    if feature.Type == "Toggle" then
        createToggle(feature)
    elseif feature.Type == "Slider" then
        createSlider(feature)
    end
end

-- Smooth Entry Animation
MainWindow.Size = UDim2.new(0, 0, 0, 0)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)

local openTween = TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 220, 0, windowHeight),
    Position = UDim2.new(0.5, -110, 0.5, -windowHeight/2)
})
openTween:Play()
