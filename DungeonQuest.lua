-- Dungeon Quest | Unified & Direct Input Engine
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

for _, name in ipairs({"CustomGameHub", "DungeonQuestHub", "HamiHubCustom", "JumpForAnimalsHub"}) do
    local old = CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

_G.DQ = {
    AutoMob = false,
    AutoMobMode = "Above",
    AboveHeight = 11,
    BehindOffset = 6,
    AutoSwordNormal = false,
    AutoAttackFast = false,
    AutoAbilities = false,
    AbilityDelay = 0.5,
    SavedCFrame = nil,
    MobESP = false,
    BossESP = false,
    FieldOfView = 70,
    WalkSpeed = 16,
    NoClip = false,
    InfJump = false,
    AntiAFK = true,
    SkipIntro = false
}

local function isAlive(target)
    local plyr = target or LocalPlayer
    local char = plyr.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function getDungeonMobs()
    local mobs = {}
    local enemiesFolder = Workspace:FindFirstChild("dungeon") and Workspace.dungeon:FindFirstChild("monsters") 
        or Workspace:FindFirstChild("mobs") 
        or Workspace:FindFirstChild("Monsters") 
        or Workspace:FindFirstChild("Enemies")

    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                table.insert(mobs, mob)
            end
        end
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not Players:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 then
                    table.insert(mobs, obj)
                end
            end
        end
    end
    return mobs
end

local function getClosestMob()
    if not isAlive() then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local closest, shortestDist = nil, math.huge

    for _, mob in pairs(getDungeonMobs()) do
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (hrp.Position - myPos).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = mob
            end
        end
    end
    return closest
end

-- Direct In-Game Left-Click Attack Execution
local function performSwordSlash()
    if not isAlive() then return end
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                LocalPlayer.Character.Humanoid:EquipTool(item)
                break
            end
        end
    end

    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(viewportCenter)
    task.wait(0.01)
    VirtualUser:Button1Up(viewportCenter)
end

-- UI Construction
local Screen = Instance.new("ScreenGui")
Screen.Name = "DungeonQuestHub"
Screen.ResetOnSpawn = false
Screen.Parent = CoreGui

local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingBtn.Position = UDim2.new(0, 15, 0.5, -22)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.Text = "⚔️"
FloatingBtn.TextSize = 22
FloatingBtn.Active = true
FloatingBtn.Parent = Screen
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(30, 237, 93)
FloatStroke.Thickness = 2

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

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(1, 0, 0, 45)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "  Dungeon Quest"
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 12
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Active = true
GameTitle.Parent = Sidebar

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -130, 0, 35)
TopBar.Position = UDim2.new(0, 130, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Active = true
TopBar.Parent = MainFrame

enableDrag(TopBar, MainFrame)
enableDrag(GameTitle, MainFrame)

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

local ProfileText = Instance.new("TextLabel")
ProfileText.Size = UDim2.new(0, 150, 1, 0)
ProfileText.Position = UDim2.new(1, -190, 0, 0)
ProfileText.BackgroundTransparency = 1
ProfileText.Text = LocalPlayer.Name .. " | PRO"
ProfileText.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfileText.Font = Enum.Font.Gotham
ProfileText.TextSize = 12
ProfileText.TextXAlignment = Enum.TextXAlignment.Right
ProfileText.Parent = TopBar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -45)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

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

local function CreateButton(parent, title, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 1, -10)
    Btn.Position = UDim2.new(0, 10, 0, 5)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.Text = title
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        callback(Btn)
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

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 10)
    Btn.Position = UDim2.new(0, 0, 0, -5)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Track

    local draggingSlider = false
    Btn.MouseButton1Down:Connect(function() draggingSlider = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation().X
            local trackPos = Track.AbsolutePosition.X
            local trackSize = Track.AbsoluteSize.X
            local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            local val = math.floor(min + (max - min) * percent)
            ValueLabel.Text = tostring(val)
            callback(val)
        end
    end)
end

-- Tabs Initialization
local AutoMobLeft, AutoMobRight = CreateTab("AutoMob", true)
local CombatLeft, CombatRight = CreateTab("Automation", false)
local AbilitiesLeft, AbilitiesRight = CreateTab("Abilities", false)
local MovementLeft, MovementRight = CreateTab("Movement", false)
local VisualsLeft, VisualsRight = CreateTab("Visuals", false)
local TeleportLeft, TeleportRight = CreateTab("Teleport", false)

-- [ 1. AUTOMOB TAB ]
CreateToggle(AutoMobLeft, "Enable AutoMob", false, function(state) _G.DQ.AutoMob = state end)
CreateButton(AutoMobLeft, "Mode: Above / Behind", function(btn)
    if _G.DQ.AutoMobMode == "Above" then
        _G.DQ.AutoMobMode = "Behind"
        btn.Text = "Mode: Behind"
    else
        _G.DQ.AutoMobMode = "Above"
        btn.Text = "Mode: Above"
    end
end)
CreateSlider(AutoMobRight, "Above Height", 5, 25, 11, function(val) _G.DQ.AboveHeight = val end)
CreateSlider(AutoMobRight, "Behind Offset", 3, 15, 6, function(val) _G.DQ.BehindOffset = val end)

-- [ 2. AUTOMATION TAB ]
CreateToggle(CombatLeft, "Auto Sword Normal", false, function(state) _G.DQ.AutoSwordNormal = state end)
CreateToggle(CombatRight, "Auto Attack + Fast", false, function(state) _G.DQ.AutoAttackFast = state end)

-- [ 3. ABILITIES TAB ]
CreateToggle(AbilitiesLeft, "Auto Abilities (Q,E,R)", false, function(state) _G.DQ.AutoAbilities = state end)
CreateSlider(AbilitiesRight, "Ability Delay", 0.1, 2, 0.5, function(val) _G.DQ.AbilityDelay = val end)

-- [ 4. MOVEMENT TAB ]
CreateSlider(MovementLeft, "WalkSpeed", 16, 75, 16, function(val) _G.DQ.WalkSpeed = val end)
CreateToggle(MovementLeft, "NoClip", false, function(state) _G.DQ.NoClip = state end)
CreateToggle(MovementRight, "Infinite Jump", false, function(state) _G.DQ.InfJump = state end)
CreateToggle(MovementRight, "Anti-AFK", true, function(state) _G.DQ.AntiAFK = state end)

-- [ 5. VISUALS TAB ]
CreateToggle(VisualsLeft, "Mob Highlights", false, function(state)
    _G.DQ.MobESP = state
    if not state then
        for _, mob in pairs(getDungeonMobs()) do
            if mob:FindFirstChild("MobHighlight") then mob.MobHighlight:Destroy() end
        end
    end
end)
CreateToggle(VisualsRight, "Boss Highlights", false, function(state)
    _G.DQ.BossESP = state
    if not state then
        for _, mob in pairs(getDungeonMobs()) do
            if mob:FindFirstChild("BossHighlight") then mob.BossHighlight:Destroy() end
        end
    end
end)
CreateSlider(VisualsLeft, "Field of View", 70, 120, 70, function(val)
    _G.DQ.FieldOfView = val
    Camera.FieldOfView = val
end)
CreateToggle(VisualsRight, "Skip Dungeon Intro", false, function(state) _G.DQ.SkipIntro = state end)

-- [ 6. TELEPORT TAB WITH CONTROL BUTTONS ]
CreateButton(TeleportLeft, "Save Position", function(btn)
    if isAlive() then
        _G.DQ.SavedCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        btn.Text = "Position Saved!"
        task.delay(1.5, function() btn.Text = "Save Position" end)
    end
end)
CreateButton(TeleportLeft, "Load Position", function()
    if isAlive() and _G.DQ.SavedCFrame then
        LocalPlayer.Character.HumanoidRootPart.CFrame = _G.DQ.SavedCFrame
    end
end)
CreateButton(TeleportRight, "Control: Land on Floor", function()
    if isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local ray = Ray.new(hrp.Position, Vector3.new(0, -200, 0))
        local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if hit then
            hrp.CFrame = CFrame.new(hitPos + Vector3.new(0, 3, 0))
        end
    end
end)
CreateButton(TeleportRight, "Control: Jump 15 Studs", function()
    if isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 15, 0)
    end
end)

-- Background Loops

-- AutoMob Heartbeat Lock
RunService.Heartbeat:Connect(function()
    if _G.DQ.AutoMob and isAlive() then
        local target = getClosestMob()
        if target and target:FindFirstChild("HumanoidRootPart") then
            local myHrp = LocalPlayer.Character.HumanoidRootPart
            local targetHrp = target.HumanoidRootPart

            myHrp.AssemblyLinearVelocity = Vector3.zero
            myHrp.AssemblyAngularVelocity = Vector3.zero

            if _G.DQ.AutoMobMode == "Above" then
                myHrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, _G.DQ.AboveHeight, 0), targetHrp.Position)
            else
                local backPos = targetHrp.Position - (targetHrp.CFrame.LookVector * _G.DQ.BehindOffset) + Vector3.new(0, 2, 0)
                myHrp.CFrame = CFrame.new(backPos, targetHrp.Position)
            end
        end
    end
end)

-- Normal Sword Attack
task.spawn(function()
    while task.wait(0.3) do
        if _G.DQ.AutoSwordNormal and isAlive() then
            performSwordSlash()
        end
    end
end)

-- Fast Sword Attack
task.spawn(function()
    while task.wait(0.08) do
        if _G.DQ.AutoAttackFast and isAlive() then
            performSwordSlash()
        end
    end
end)

-- Auto Abilities (Spells: Q, E, R)
task.spawn(function()
    local abilityKeys = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R}
    while task.wait(_G.DQ.AbilityDelay or 0.5) do
        if _G.DQ.AutoAbilities and isAlive() then
            for _, key in ipairs(abilityKeys) do
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(key)
                task.wait(0.02)
                VirtualUser:SetKeyUp(key)
            end
        end
    end
end)

-- Micro-Vector WalkSpeed
RunService.Heartbeat:Connect(function(deltaTime)
    if isAlive() and _G.DQ.WalkSpeed > 16 and not _G.DQ.AutoMob then
        local hum = LocalPlayer.Character.Humanoid
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if hum.MoveDirection.Magnitude > 0 then
            local boost = (_G.DQ.WalkSpeed - 16) * deltaTime
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * boost)
        end
    end
end)

-- Visual Highlights
RunService.RenderStepped:Connect(function()
    if _G.DQ.MobESP or _G.DQ.BossESP then
        for _, mob in pairs(getDungeonMobs()) do
            local isBoss = mob.Name:lower():find("boss") or (mob:FindFirstChild("Humanoid") and mob.Humanoid.MaxHealth > 10000)

            if isBoss and _G.DQ.BossESP and not mob:FindFirstChild("BossHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "BossHighlight"
                h.FillColor = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = mob
            elseif not isBoss and _G.DQ.MobESP and not mob:FindFirstChild("MobHighlight") then
                local h = Instance.new("Highlight")
                h.Name = "MobHighlight"
                h.FillColor = Color3.fromRGB(30, 237, 93)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.Parent = mob
            end
        end
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if _G.DQ.NoClip and isAlive() then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if _G.DQ.InfJump and isAlive() then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Skip Dungeon Intro
task.spawn(function()
    while task.wait(1) do
        if _G.DQ.SkipIntro then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local intro = playerGui:FindFirstChild("introGui") or playerGui:FindFirstChild("cinematic") or playerGui:FindFirstChild("cutscene")
                if intro and intro.Enabled then
                    intro.Enabled = false
                end
            end
            if Camera.CameraType ~= Enum.CameraType.Custom then
                Camera.CameraType = Enum.CameraType.Custom
            end
        end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.DQ.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
