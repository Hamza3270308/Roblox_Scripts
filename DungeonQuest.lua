-- Custom Hub Framework (UI Template)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cleanup previous interface instances
if CoreGui:FindFirstChild("CustomGameHub") then
    CoreGui.CustomGameHub:Destroy()
end

local Screen = Instance.new("ScreenGui")
Screen.Name = "CustomGameHub"
Screen.ResetOnSpawn = false
Screen.Parent = CoreGui

-- Floating Toggle Button
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingBtn.Position = UDim2.new(0, 15, 0.5, -22)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Text = "⚙️"
FloatingBtn.TextSize = 20
FloatingBtn.Active = true
FloatingBtn.Parent = Screen
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(30, 237, 93)
FloatStroke.Thickness = 2

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = Screen
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Draggable Logic Implementation
local function enableDrag(dragHandle, targetFrame)
    targetFrame = targetFrame or dragHandle
    local dragging, dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

enableDrag(FloatingBtn)

-- Navigation Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "  Hub Interface"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Active = true
TitleLabel.Parent = Sidebar

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -130, 0, 35)
TopBar.Position = UDim2.new(0, 130, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Active = true
TopBar.Parent = MainFrame

enableDrag(TopBar, MainFrame)
enableDrag(TitleLabel, MainFrame)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local ProfileLabel = Instance.new("TextLabel")
ProfileLabel.Size = UDim2.new(0, 150, 1, 0)
ProfileLabel.Position = UDim2.new(1, -190, 0, 0)
ProfileLabel.BackgroundTransparency = 1
ProfileLabel.Text = LocalPlayer.Name
ProfileLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfileLabel.Font = Enum.Font.Gotham
ProfileLabel.TextSize = 12
ProfileLabel.TextXAlignment = Enum.TextXAlignment.Right
ProfileLabel.Parent = TopBar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -45)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Tab System
local Tabs = {}
local TabButtons = {}

local function CreateTab(name, isDefault)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = isDefault
    TabFrame.Parent = ContentArea

    local Left = Instance.new("Frame", TabFrame)
    Left.Size = UDim2.new(0.5, -4, 1, 0)
    Left.BackgroundTransparency = 1
    local LeftLayout = Instance.new("UIListLayout", Left)
    LeftLayout.Padding = UDim.new(0, 6)

    local Right = Instance.new("Frame", TabFrame)
    Right.Size = UDim2.new(0.5, -4, 1, 0)
    Right.Position = UDim2.new(0.5, 4, 0, 0)
    Right.BackgroundTransparency = 1
    local RightLayout = Instance.new("UIListLayout", Right)
    RightLayout.Padding = UDim.new(0, 6)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -16, 0, 28)
    TabBtn.Position = UDim2.new(0, 8, 0, 50 + (#TabButtons * 34))
    TabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(25, 25, 25)
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = isDefault and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    table.insert(Tabs, TabFrame)
    table.insert(TabButtons, TabBtn)

    TabBtn.MouseButton1Click:Connect(function()
        for i, t in ipairs(Tabs) do
            t.Visible = (t == TabFrame)
            TabButtons[i].BackgroundColor3 = (t == TabFrame) and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(25, 25, 25)
            TabButtons[i].TextColor3 = (t == TabFrame) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        end
    end)

    return Left, Right
end

-- Component Factories
local function CreateToggle(parent, title, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 20)
    Btn.Position = UDim2.new(1, -48, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(50, 50, 50)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = default and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(30, 237, 93) or Color3.fromRGB(50, 50, 50)
        Btn.Text = state and "ON" or "OFF"
        Btn.TextColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

local function CreateSlider(parent, title, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0.5, 0)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0.5, 0)
    ValueLabel.Position = UDim2.new(1, -58, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 0.7, 2)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(30, 237, 93)
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 10)
    SliderBtn.Position = UDim2.new(0, 0, 0, -5)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = Track

    local dragging = false
    SliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = UIS:GetMouseLocation().X
            local trackX = Track.AbsolutePosition.X
            local trackWidth = Track.AbsoluteSize.X
            local percent = math.clamp((mouseX - trackX) / trackWidth, 0, 1)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(min + (max - min) * percent)
            ValueLabel.Text = tostring(value)
            callback(value)
        end
    end)
end

-- Example Setup
local Tab1Left, Tab1Right = CreateTab("General", true)
local Tab2Left, Tab2Right = CreateTab("Settings", false)

CreateToggle(Tab1Left, "Option A", false, function(state)
    print("Option A:", state)
end)

CreateSlider(Tab1Right, "Scale Factor", 1, 100, 50, function(value)
    print("Scale Factor:", value)
end)
