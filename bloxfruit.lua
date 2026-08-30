-- HAMI HUB | Blox Fruits Script (Custom UI Edition)
-- FINAL FIX: Fast Attack completely removed. Auto Attack reverted to the exact working TriggerAttack() logic.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

_G.Settings = {
    -- Combat
    AutoAttack = false,
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
-- 1. CORE LOGIC & COMBAT HOOKS
-- ==========================================
local function TriggerAttack()
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end
end

-- Kept the framework hook loaded in memory just in case, but it no longer interferes with Auto Attack
local CombatFrameworkR = nil
task.spawn(function()
    pcall(function()
        local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
        local CombatFramework = require(PlayerScripts:WaitForChild("CombatFramework"))
        for _, v in pairs(getupvalues(CombatFramework) or debug.getupvalues(CombatFramework)) do
            if type(v) == "table" and v.activeController ~= nil then
                CombatFrameworkR = v
                break
            end
        end
        if not CombatFrameworkR then
            CombatFrameworkR = (getupvalues(CombatFramework) or debug.getupvalues(CombatFramework))[2]
        end
    end)
end)

-- The EXACT working loop logic you provided
task.spawn(function()
    while task.wait(0.1) do
        -- Auto Equip
        if _G.Settings.AutoEquip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
            end
        end

        -- Safe Auto Click
        if _G.Settings.AutoClick then
            TriggerAttack()
        end

        -- Auto Attack (Restored to working native tool activation)
        if _G.Settings.AutoAttack and LocalPlayer.Character then
            TriggerAttack()
        end
    end
end)

-- ==========================================
-- 2. TELEPORTS & BACKGROUND LOOPS
-- ==========================================
local FirstSeaIslands = {
    ["Starter Marine"] = CFrame.new(-2755, 22, 2125), ["Starter Pirate"] = CFrame.new(990, 15, 1425),
    ["Jungle"] = CFrame.new(-1600, 36, 150), ["Pirate Village"] = CFrame.new(-1150, 15, 3900),
    ["Desert"] = CFrame.new(900, 15, 4300), ["Middle Town"] = CFrame.new(-680, 20, 1500),
    ["Frozen Village"] = CFrame.new(1200, 25, -1200), ["Marine Fortress"] = CFrame.new(-4800, 25, 4300)
}

local currentTween = nil
local function SafeTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local HRP = char.HumanoidRootPart
        local distance = (HRP.Position - targetCFrame.Position).Magnitude
        local tweenTime = distance / 300 
        
        if currentTween then currentTween:Cancel() end

        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        currentTween = TweenService:Create(HRP, tweenInfo, {CFrame = targetCFrame})
        
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Parent = HRP
        
        currentTween:Play()
        currentTween.Completed:Connect(function() bodyVel:Destroy(); currentTween = nil end)
    end
end

local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(30, 1, 30)
WaterPlatform.Transparency = 1
WaterPlatform.Anchored = true
WaterPlatform.CanCollide = false
WaterPlatform.Parent = workspace

local bodyVelocity, bodyGyro
local camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local HRP = char.HumanoidRootPart
        local Humanoid = char.Humanoid
        
        if _G.Settings.SpeedToggle then Humanoid.WalkSpeed = _G.Settings.WalkSpeed end
        if _G.Settings.JumpToggle then Humanoid.JumpPower = _G.Settings.JumpPower end
        if _G.Settings.AntiSit and Humanoid.Sit then Humanoid.Sit = false end

        if _G.Settings.WalkOnWater then
            WaterPlatform.CanCollide = true
            WaterPlatform.CFrame = CFrame.new(HRP.Position.X, 0, HRP.Position.Z)
        else
            WaterPlatform.CanCollide = false
            WaterPlatform.CFrame = CFrame.new(0, -500, 0)
        end

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
-- 3. CUSTOM UI CREATION ENGINE
-- ==========================================
local AccentColor = Color3.fromRGB(0, 255, 127) 
local DarkBG = Color3.fromRGB(15, 15, 15)
local CardBG = Color3.fromRGB(25, 25, 25)
local TextColor = Color3.fromRGB(240, 240, 240)
local SubTextColor = Color3.fromRGB(150, 150, 150)

if CoreGui:FindFirstChild("HamiHubCustom") then CoreGui.HamiHubCustom:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HamiHubCustom"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 750, 0, 480)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -240)
MainFrame.BackgroundColor3 = DarkBG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- *** DRAGGABLE UI LOGIC ***
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- *** RESIZABLE UI LOGIC ***
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "↘"
ResizeHandle.TextColor3 = SubTextColor
ResizeHandle.TextSize = 14
ResizeHandle.Parent = MainFrame

local resizing, rsDragStart, rsStartSize
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        rsDragStart = input.Position
        rsStartSize = MainFrame.Size
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizing = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - rsDragStart
        local newWidth = math.clamp(rsStartSize.X.Offset + delta.X, 450, 1200)
        local newHeight = math.clamp(rsStartSize.Y.Offset + delta.Y, 300, 900)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 220, 1, 0)
Sidebar.BackgroundColor3 = CardBG
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarCover = Instance.new("Frame")
SidebarCover.Size = UDim2.new(0, 10, 1, 0)
SidebarCover.Position = UDim2.new(1, -10, 0, 0)
SidebarCover.BackgroundColor3 = CardBG
SidebarCover.BorderSizePixel = 0
SidebarCover.Parent = Sidebar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -20, 0, 60)
Logo.Position = UDim2.new(0, 20, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "HAMI HUB"
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 20
Logo.TextColor3 = TextColor
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 1, -80)
TabContainer.Position = UDim2.new(0, 10, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 10)
TabList.Parent = TabContainer

-- Window Controls (Minimize & Close)
local WindowControls = Instance.new("Frame")
WindowControls.Size = UDim2.new(0, 70, 0, 30)
WindowControls.Position = UDim2.new(1, -80, 0, 15)
WindowControls.BackgroundTransparency = 1
WindowControls.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = CardBG
MinimizeBtn.Text = "-"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.TextColor3 = TextColor
MinimizeBtn.Parent = WindowControls
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0, 40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = WindowControls
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content Area 
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -240, 1, -60)
ContentArea.Position = UDim2.new(0, 230, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- UI Construction Helpers
local Tabs = {}
local Pages = {}

local function CreateTab(name, icon, isFirst)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = isFirst and AccentColor or CardBG
    btn.BackgroundTransparency = isFirst and 0 or 1
    btn.Text = "  " .. name
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = isFirst and DarkBG or TextColor
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.Visible = isFirst
    page.Parent = ContentArea

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.48, 0, 0, 45)
    grid.CellPadding = UDim2.new(0.04, 0, 0, 10)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = page

    Tabs[name] = btn
    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for tName, tBtn in pairs(Tabs) do
            tBtn.BackgroundColor3 = CardBG
            tBtn.BackgroundTransparency = 1
            tBtn.TextColor3 = TextColor
            Pages[tName].Visible = false
        end
        btn.BackgroundColor3 = AccentColor
        btn.BackgroundTransparency = 0
        btn.TextColor3 = DarkBG
        page.Visible = true
    end)

    return page
end

local function CreateToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = CardBG
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = TextColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -65, 0.5, -12)
    btn.BackgroundColor3 = defaultState and AccentColor or Color3.fromRGB(40, 40, 40)
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = defaultState and DarkBG or SubTextColor
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = defaultState and "ON" or "OFF"
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 10
    txt.TextColor3 = defaultState and DarkBG or SubTextColor
    txt.TextXAlignment = defaultState and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    txt.Position = defaultState and UDim2.new(0, 8, 0, 0) or UDim2.new(0, -8, 0, 0)
    txt.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = state and DarkBG or SubTextColor}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and AccentColor or Color3.fromRGB(40, 40, 40)}):Play()
        txt.Text = state and "ON" or "OFF"
        txt.TextColor3 = state and DarkBG or SubTextColor
        txt.TextXAlignment = state and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        txt.Position = state and UDim2.new(0, 8, 0, 0) or UDim2.new(0, -8, 0, 0)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = CardBG
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0, 20)
    lbl.Position = UDim2.new(0, 15, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextColor3 = TextColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.5, -15, 0, 20)
    valLbl.Position = UDim2.new(0.5, 0, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.TextSize = 12
    valLbl.TextColor3 = SubTextColor
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = frame

    local barBg = Instance.new("TextButton")
    barBg.Size = UDim2.new(1, -30, 0, 4)
    barBg.Position = UDim2.new(0, 15, 1, -12)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.Text = ""
    barBg.Parent = frame
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local pct = math.clamp((default - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = AccentColor
    fill.Parent = barBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + ((max - min) * pos))
        valLbl.Text = tostring(val)
        callback(val)
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; updateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextColor3 = TextColor
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = AccentColor, TextColor3 = DarkBG}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = TextColor}):Play()
        callback()
    end)
end

-- ==========================================
-- 4. POPULATE UI
-- ==========================================
local MainTab = CreateTab("Main", "", true)
local PlayerTab = CreateTab("Player", "", false)
local VisualsTab = CreateTab("Visuals", "", false)
local TeleportTab = CreateTab("Teleports", "", false)

-- Toggle UI visibility with RightControl
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Main
CreateToggle(MainTab, "Auto Attack", false, function(v) _G.Settings.AutoAttack = v end)
CreateToggle(MainTab, "Auto Equip", false, function(v) _G.Settings.AutoEquip = v end)
CreateToggle(MainTab, "Safe Auto Click", false, function(v) _G.Settings.AutoClick = v end)

-- Player
CreateToggle(PlayerTab, "Custom Speed", false, function(v) _G.Settings.SpeedToggle = v end)
CreateSlider(PlayerTab, "Walk Speed", 16, 300, 16, function(v) _G.Settings.WalkSpeed = v end)
CreateToggle(PlayerTab, "Custom Jump", false, function(v) _G.Settings.JumpToggle = v end)
CreateSlider(PlayerTab, "Jump Power", 50, 500, 50, function(v) _G.Settings.JumpPower = v end)
CreateToggle(PlayerTab, "Infinite Jump", false, function(v) _G.Settings.InfJump = v end)
CreateToggle(PlayerTab, "No Clip", false, function(v) _G.Settings.Noclip = v end)
CreateToggle(PlayerTab, "Walk On Water", false, function(v) _G.Settings.WalkOnWater = v end)
CreateToggle(PlayerTab, "Anti Sit", false, function(v) _G.Settings.AntiSit = v end)
CreateToggle(PlayerTab, "Fly Mode", false, function(v) _G.Settings.Fly = v end)
CreateSlider(PlayerTab, "Fly Speed", 16, 300, 50, function(v) _G.Settings.FlySpeed = v end)

-- Visuals
CreateToggle(VisualsTab, "Player ESP", false, function(v) _G.Settings.ESP = v end)
CreateToggle(VisualsTab, "FPS Saver", false, function(v) 
    _G.Settings.FPSSaver = v
    settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    Lighting.GlobalShadows = not v
end)
CreateToggle(VisualsTab, "Remove Fog", false, function(v)
    Lighting.FogEnd = v and 100000 or 1000
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then atmo.Density = v and 0 or 0.3 end
end)

-- Teleports
for name, cf in pairs(FirstSeaIslands) do
    CreateButton(TeleportTab, name, function() SafeTeleport(cf) end)
end
