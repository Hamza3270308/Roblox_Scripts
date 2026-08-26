--[[
	WARNING: Use at your own risk!
	Hami Hub - Driving Empire Edition
]]

-- ==========================================
-- SERVICES & VARIABLES
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- PLAYER RESPAWN HANDLER
-- ==========================================
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        task.wait(0.5)
        if getgenv().WalkSpeedEnabled then hum.WalkSpeed = getgenv().WalkSpeedValue end
        if getgenv().JumpPowerEnabled then 
            hum.UseJumpPower = true
            hum.JumpPower = getgenv().JumpPowerValue 
        end
    end
end)

-- ==========================================
-- AUTO DELIVERY BACKEND LOGIC
-- ==========================================
local Config = {
    Enabled = false, PickupDelay = 0.18, WaitAfterFull = 3,
    TweenSpeed = 1.1, SkyHeight = 180, PickupStuckTime = 15, RetryDistance = 50
}

local maxItems = 4
local pickupStuckTime, fullTime = 0, 0
local isFlying, isFull, delivered = false, false, false
local jobState = nil
local noclipConnection, flyConnection, loopConnection, jumpConnection = nil, nil, nil, nil

local function getChar()
    local char = LocalPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid") end
    return nil, nil
end

local function waitForItemsUpdate(target, timeout)
    local start = tick()
    while tick() - start < (timeout or 3) do
        if jobState and jobState.ItemsCarried and jobState.ItemsCarried >= target then return true end
        task.wait(0.12)
    end
    return false
end

local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Enabled then return end
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end

local function startFly(part)
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.Heartbeat:Connect(function()
        if not isFull or not part then return end
        part.Velocity, part.RotVelocity = Vector3.zero, Vector3.zero
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
end

local function startInfiniteJump()
    if jumpConnection then jumpConnection:Disconnect() end
    jumpConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        local _, hum = getChar()
        if hum and hum.Sit then hum.Jump = true end
    end)
end

local function startAntiSwim()
    RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        local root, hum = getChar()
        if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
            hum.Jump = true
            if root then
                root.Velocity = Vector3.new(0, 80, 0)
                root.CFrame = root.CFrame + Vector3.new(0, 25, 0)
            end
        end
    end)
end

local function tweenTo(pos)
    local root = select(1, getChar())
    if not root or not pos then return end
    pcall(function()
        local tween = TweenService:Create(root, TweenInfo.new(Config.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(pos.X, pos.Y + 5.5, pos.Z)})
        tween:Play()
        tween.Completed:Wait()
    end)
end

local function flyUp()
    local root = select(1, getChar())
    if root then
        root.CFrame = CFrame.new(root.Position + Vector3.new(0, Config.SkyHeight, 0))
        startFly(root)
    end
end

local function invokeRemote(name)
    pcall(function()
        local rf = ReplicatedStorage:FindFirstChild(name, true)
        if rf then
            if rf:IsA("RemoteFunction") then rf:InvokeServer()
            elseif rf:IsA("RemoteEvent") then rf:FireServer() end
        end
    end)
end

local function startLoop()
    if loopConnection then loopConnection:Disconnect() end
    local jobModule = require(ReplicatedStorage:WaitForChild("Modules").Client.Jobs.Tasks.DeliveryJobTask)
    jobModule.OnStateChanged:Connect(function(state) jobState = state end)

    loopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled or not jobState then return end
        local root = select(1, getChar())
        if not root then return end

        local itemsCarried = jobState.ItemsCarried or 0
        local pickupPos, destPos = jobState.PickupPosition, jobState.DestinationPosition

        if itemsCarried < maxItems and pickupPos then
            local dist = (root.Position - pickupPos).Magnitude
            if dist > 25 then tweenTo(pickupPos); pickupStuckTime = tick(); task.wait(0.3) end
            if dist < 45 then
                if pickupStuckTime == 0 then pickupStuckTime = tick() end
                if tick() - pickupStuckTime > Config.PickupStuckTime then
                    local dir = (root.Position - pickupPos)
                    root.CFrame = root.CFrame + (dir.Magnitude > 0 and dir.Unit * Config.RetryDistance or Vector3.zero) + Vector3.new(0, 20, 0)
                    task.wait(0.6); tweenTo(pickupPos); pickupStuckTime = tick()
                end

                local attempts, success = 0, false
                while attempts < 3 and not success do
                    invokeRemote("Pickup")
                    task.wait(Config.PickupDelay)
                    success = waitForItemsUpdate((jobState.ItemsCarried or 0) + 1, 2)
                    attempts = attempts + 1
                end
                pickupStuckTime = 0
                return
            end
        else
            pickupStuckTime = 0
        end

        if (jobState.ItemsCarried or 0) >= maxItems and destPos and not delivered then
            if not waitForItemsUpdate(maxItems, 2) then return end
            if not isFull then isFull = true; fullTime = tick(); flyUp() end

            if tick() - fullTime >= Config.WaitAfterFull then
                stopFly(); tweenTo(destPos); task.wait(0.7)
                invokeRemote("Deliver")
                delivered = true; isFull = false; fullTime = 0
                task.wait(2); delivered = false
            end
        else
            if isFull then isFull = false; stopFly() end
        end
    end)
end

local function startAll()
    task.wait(1)
    startNoclip(); startInfiniteJump(); startAntiSwim(); startLoop()
end

-- ==========================================
-- VEHICLE HELPER FUNCTION
-- ==========================================
local function getVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent 
    end
    return nil
end

-- ==========================================
-- ORION UI INITIALIZATION
-- ==========================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Hami Hub | Driving Empire", 
    HidePremium = true, SaveConfig = false, IntroEnabled = true,
    IntroText = "Hami Hub Loading..."
})

-- ==========================================
-- TAB 1: AUTO FARMING
-- ==========================================
local FarmTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483362458", PremiumOnly = false})
FarmTab:AddSection({Name = "Delivery Farm"})
FarmTab:AddParagraph("Auto Delivery", "Join the delivery job first before turning it on.")
FarmTab:AddToggle({
    Name = "Auto Delivery", Default = false,
    Callback = function(state)
        Config.Enabled = state
        if state and not _G.InitDone then
            pcall(function() maxItems = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1744052086) and 8 or 4 end)
            startAll()
            _G.InitDone = true
        end
    end    
})

FarmTab:AddSection({Name = "Passive Income"})
FarmTab:AddToggle({
    Name = "Auto Highway Farm", Default = false,
    Callback = function(Value)
        getgenv().AutoHighway = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoHighway do
                    task.wait(0.5)
                    -- [PLACEHOLDER] Highway Logic
                end
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Race", Default = false,
    Callback = function(Value)
        getgenv().AutoRace = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoRace do
                    task.wait(1)
                    -- [PLACEHOLDER] Auto Race Logic
                end
            end)
        end
    end    
})

-- ==========================================
-- TAB 2: VEHICLE MODS
-- ==========================================
local VehicleTab = Window:MakeTab({Name = "Vehicle", Icon = "rbxassetid://4483362458", PremiumOnly = false})
VehicleTab:AddSection({Name = "Performance"})

getgenv().VehicleSpeed = 200
VehicleTab:AddSlider({
    Name = "Speed Value", Min = 100, Max = 1000, Default = 200, Color = Color3.fromRGB(0, 255, 100), Increment = 10, ValueName = "Speed",
    Callback = function(Value) getgenv().VehicleSpeed = Value end    
})

VehicleTab:AddToggle({
    Name = "Enable Speed Boost (Hold W)", Default = false,
    Callback = function(Value)
        getgenv().SpeedBoost = Value
        if Value then
            -- Wrapped in task.spawn to prevent UI freezing
            task.spawn(function()
                while getgenv().SpeedBoost do
                    task.wait()
                    local veh = getVehicle()
                    if veh and veh.PrimaryPart and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        local currentVel = veh.PrimaryPart.Velocity
                        local newVel = veh.PrimaryPart.CFrame.LookVector * getgenv().VehicleSpeed
                        veh.PrimaryPart.Velocity = Vector3.new(newVel.X, currentVel.Y, newVel.Z)
                    end
                end
            end)
        end
    end    
})

VehicleTab:AddButton({
    Name = "Auto Flip Car",
    Callback = function()
        local veh = getVehicle()
        if veh and veh.PrimaryPart then
            local currentPos = veh.PrimaryPart.Position
            veh:SetPrimaryPartCFrame(CFrame.new(currentPos) * CFrame.Angles(0, math.rad(veh.PrimaryPart.Orientation.Y), 0))
        end
    end    
})

-- ==========================================
-- TAB 3: PLAYER MODS
-- ==========================================
local PlayerTab = Window:MakeTab({Name = "Player", Icon = "rbxassetid://4483362458", PremiumOnly = false})
PlayerTab:AddSection({Name = "Movement"})

getgenv().WalkSpeedValue = 16
PlayerTab:AddSlider({
    Name = "Walk Speed Value", Min = 16, Max = 300, Default = 16, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "WS",
    Callback = function(Value)
        getgenv().WalkSpeedValue = Value
        if getgenv().WalkSpeedEnabled then
            local _, hum = getChar()
            if hum then hum.WalkSpeed = Value end
        end
    end    
})

PlayerTab:AddToggle({
    Name = "Enable Walk Speed", Default = false,
    Callback = function(Value)
        getgenv().WalkSpeedEnabled = Value
        local _, hum = getChar()
        if hum then hum.WalkSpeed = Value and getgenv().WalkSpeedValue or 16 end
    end    
})

getgenv().JumpPowerValue = 50
PlayerTab:AddSlider({
    Name = "High Jump Value", Min = 50, Max = 300, Default = 50, Color = Color3.fromRGB(0, 255, 100), Increment = 1, ValueName = "JP",
    Callback = function(Value)
        getgenv().JumpPowerValue = Value
        if getgenv().JumpPowerEnabled then
            local _, hum = getChar()
            if hum then 
                hum.UseJumpPower = true
                hum.JumpPower = Value 
            end
        end
    end    
})

PlayerTab:AddToggle({
    Name = "Enable High Jump", Default = false,
    Callback = function(Value)
        getgenv().JumpPowerEnabled = Value
        local _, hum = getChar()
        if hum then 
            hum.UseJumpPower = true
            hum.JumpPower = Value and getgenv().JumpPowerValue or 50 
        end
    end    
})

-- ==========================================
-- TAB 4: TELEPORTS
-- ==========================================
local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local function tpPlayer(pos)
    local root = select(1, getChar())
    if root then
        local veh = getVehicle()
        if veh then veh:SetPrimaryPartCFrame(CFrame.new(pos))
        else root.CFrame = CFrame.new(pos) end
    end
end

TeleportTab:AddButton({Name = "Teleport to Dealership", Callback = function() tpPlayer(Vector3.new(0, 50, 0)) end})
TeleportTab:AddButton({Name = "Teleport to Highway", Callback = function() tpPlayer(Vector3.new(500, 50, 500)) end})

-- ==========================================
-- TAB 5: MISCELLANEOUS
-- ==========================================
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MiscTab:AddToggle({
    Name = "Anti-AFK", Default = false,
    Callback = function(Value)
        getgenv().AntiAFK = Value
        if Value then
            task.spawn(function()
                LocalPlayer.Idled:Connect(function()
                    if getgenv().AntiAFK then VirtualUser:ClickButton2(Vector2.new()) end
                end)
            end)
            OrionLib:MakeNotification({Name = "Anti-AFK", Content = "You will no longer be kicked.", Image = "rbxassetid://4483362458", Time = 3})
        end
    end    
})

OrionLib:Init()
