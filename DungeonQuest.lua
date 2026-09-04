-- Dungeon Quest | Active Combat Edition
-- Compact Size, Draggable Topbar, Floating Toggle & Combat Automation

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("DungeonQuestHub") then
    CoreGui.DungeonQuestHub:Destroy()
end

_G.DQ = {
    KillAura = false,
    AuraRange = 25,
    FastSkills = false,
    SafeHover = false,
    HoverHeight = 15,
    BringMobs = false,
    MobESP = false,
    BossESP = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    AntiAFK = true
}

local function isAlive(target)
    local plyr = target or LocalPlayer
    local char = plyr.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function getDungeonMobs()
    local mobs = {}
    local enemiesFolder = workspace:FindFirstChild("dungeon") and workspace.dungeon:FindFirstChild("monsters") 
        or workspace:FindFirstChild("mobs") 
        or workspace:FindFirstChild("Monsters") 
        or workspace:FindFirstChild("Enemies")

    if enemiesFolder then
        for _, mob in pairs(enemiesFolder:GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                table.insert(mobs, mob)
            end
        end
    else
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not Players:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 then
                    table.insert(mobs, obj)
                end
            end
        end
    end
    return mobs
end

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

local function enableDrag(frame, target)
    target = target or frame
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
GameTitle.TextSize = 13
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
ProfileText.Size = UDim2.new(0, 120, 1, 0)
ProfileText.Position = UDim2.new(1, -165, 0, 0)
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

local CombatLeft, CombatRight = CreateTab("Combat", true)
local MobsLeft, MobsRight = CreateTab("Mobs", false)
local VisualsLeft, VisualsRight = CreateTab("Visuals", false)
local PlayerLeft, PlayerRight = CreateTab("Player", false)
local MiscLeft, MiscRight = CreateTab("Misc", false)

-- [ COMBAT TAB ]
CreateToggle(CombatLeft, "Kill Aura", false, function(state) _G.DQ.KillAura = state end)
CreateToggle(CombatLeft, "Fast Skill Spam", false, function(state) _G.DQ.FastSkills = state end)
CreateToggle(CombatLeft, "Safe Hover (God)", false, function(state) _G.DQ.SafeHover = state end)

CreateSlider(CombatRight, "Aura Range", 10, 60, 25, function(val) _G.DQ.AuraRange = val end)
CreateSlider(CombatRight, "Hover Height", 5, 35, 15, function(val) _G.DQ.HoverHeight = val end)

-- [ MOBS TAB ]
CreateToggle(MobsLeft, "Bring Mobs / Vacuum", false, function(state) _G.DQ.BringMobs = state end)

-- [ VISUALS TAB ]
CreateToggle(VisualsLeft, "Mob Highlights", false, function(state)
    _G.DQ.MobESP = state
    if not state then
        for _, mob in pairs(getDungeonMobs()) do
            if mob:FindFirstChild("MobHighlight") then
                mob.MobHighlight:Destroy()
            end
        end
    end
end)

CreateToggle(VisualsRight, "Boss / High Tier ESP", false, function(state)
    _G.DQ.BossESP = state
    if not state then
        for _, mob in pairs(getDungeonMobs()) do
            if mob:FindFirstChild("BossHighlight") then
                mob.BossHighlight:Destroy()
            end
        end
    end
end)

-- [ PLAYER TAB ]
CreateToggle(PlayerLeft, "Infinite Jump", false, function(state) _G.DQ.InfJump = state end)
CreateSlider(PlayerRight, "WalkSpeed", 16, 120, 16, function(val) _G.DQ.WalkSpeed = val end)
CreateSlider(PlayerRight, "JumpPower", 50, 250, 50, function(val) _G.DQ.JumpPower = val end)

-- [ MISC TAB ]
CreateToggle(MiscLeft, "Anti-AFK", true, function(state) _G.DQ.AntiAFK = state end)

-- Kill Aura Loop
task.spawn(function()
    while task.wait(0.1) do
        if _G.DQ.KillAura and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            
            if not tool then
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        LocalPlayer.Character.Humanoid:EquipTool(item)
                        tool = item
                        break
                    end
                end
            end

            for _, mob in pairs(getDungeonMobs()) do
                if mob:FindFirstChild("HumanoidRootPart") then
                    local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= _G.DQ.AuraRange then
                        if tool then
                            tool:Activate()
                        end
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(500, 500))
                        task.wait(0.02)
                        VirtualUser:Button1Up(Vector2.new(500, 500))
                        break
                    end
                end
            end
        end
    end
end)

-- Fast Ability / Skill Spam Loop
task.spawn(function()
    local keys = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F}
    while task.wait(0.25) do
        if _G.DQ.FastSkills and isAlive() then
            for _, key in ipairs(keys) do
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown(key)
                task.wait(0.02)
                VirtualUser:SetKeyUp(key)
            end
        end
    end
end)

-- Mob Vacuum / Bring Mobs Handler
task.spawn(function()
    while task.wait(0.2) do
        if _G.DQ.BringMobs and isAlive() then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, mob in pairs(getDungeonMobs()) do
                if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    local targetPos = hrp.Position + (hrp.CFrame.LookVector * 6)
                    mob.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                end
            end
        end
    end
end)

-- Safe Hover / God Spot
local hoverBV
RunService.RenderStepped:Connect(function()
    if _G.DQ.SafeHover and isAlive() then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not hoverBV or hoverBV.Parent ~= hrp then
            hoverBV = Instance.new("BodyVelocity")
            hoverBV.MaxForce = Vector3.new(0, 1e5, 0)
            hoverBV.Velocity = Vector3.new(0, 0, 0)
            hoverBV.Parent = hrp
        end
        local ray = Ray.new(hrp.Position, Vector3.new(0, -100, 0))
        local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
        if hit then
            local targetY = hitPos.Y + _G.DQ.HoverHeight
            hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z) * hrp.CFrame.Rotation
        end
    else
        if hoverBV then
            hoverBV:Destroy()
            hoverBV = nil
        end
    end
end)

-- Mob & Boss Visuals
RunService.RenderStepped:Connect(function()
    if _G.DQ.MobESP or _G.DQ.BossESP then
        for _, mob in pairs(getDungeonMobs()) do
            local isBoss = mob.Name:lower():find("boss") or (mob:FindFirstChild("Humanoid") and mob.Humanoid.MaxHealth > 5000)
            
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

-- Player Movement Overrides
RunService.Stepped:Connect(function()
    if isAlive() then
        local hum = LocalPlayer.Character.Humanoid
        hum.UseJumpPower = true
        if _G.DQ.WalkSpeed > 16 then
            hum.WalkSpeed = _G.DQ.WalkSpeed
        end
        if _G.DQ.JumpPower > 50 then
            hum.JumpPower = _G.DQ.JumpPower
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.DQ.InfJump and isAlive() then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.DQ.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)
