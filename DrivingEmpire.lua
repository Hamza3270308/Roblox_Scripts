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
-- AUTO DELIVERY BACKEND LOGIC
-- ==========================================
local Config = {
    Enabled = false,
    PickupDelay = 0.18,
    WaitAfterFull = 3,
    TweenSpeed = 1.1,
    SkyHeight = 180,
    PickupStuckTime = 15,
    RetryDistance = 50
}

local maxItems = 4
local pickupStuckTime = 0
local isFlying = false
local isFull = false
local delivered = false
local fullTime = 0
local jobState = nil

local noclipConnection, flyConnection, loopConnection, jumpConnection = nil, nil, nil, nil

local function getChar()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
    end
    return nil, nil
end

local function waitForItemsUpdate(target, timeout)
    local start = tick()
    while tick() - start < (timeout or 3) do
        if jobState and jobState.ItemsCarried and jobState.ItemsCarried >= target then
            return true
        end
        task.wait(0.12)
    end
    return false
end

local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Enabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
end

local function startFly(part)
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.Heartbeat:Connect(function()
        if not isFull or not part then return end
        part.Velocity = Vector3.new(0, 0, 0)
        part.RotVelocity = Vector3.new(0, 0, 0)
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
    local goal = {CFrame = CFrame.new(pos.X, pos.Y + 5.5, pos.Z)}
    local ok, err = pcall(function()
        local tween = TweenService:Create(root, TweenInfo.new(Config.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        tween:Play()
        tween.Completed:Wait()
    end)
end

local function flyUp()
    local root = select(1, getChar())
    if root then
        local pos = root.Position + Vector3.new(0, Config.SkyHeight, 0)
        root.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
        startFly(root)
    end
end

local function findRemoteFunction(name)
    local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions", true)
    if remoteFolder then
        local rf = remoteFolder:FindFirstChild(name)
        if rf and (rf:IsA("RemoteFunction") or rf:IsA("RemoteEvent")) then return rf end
    end
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name == name and (v:IsA("RemoteFunction") or v:IsA("RemoteEvent")) then return v end
    end
    return nil
end

local function invokeRemote(name)
    local rf = findRemoteFunction(name)
    if not rf then return false end
    pcall(function()
        if rf:IsA("RemoteFunction") then rf:InvokeServer()
        elseif rf:IsA("RemoteEvent") then rf:FireServer() end
    end)
end

local function pickupDelivery() pcall(function() invokeRemote("Pickup") end) end
local function completeDelivery() pcall(function() invokeRemote("Deliver") end) end

local function startLoop()
    if loopConnection then loopConnection:Disconnect() end
    local jobModule = require(ReplicatedStorage:WaitForChild("Modules").Client.Jobs.Tasks.DeliveryJobTask)
    jobModule.OnStateChanged:Connect(function(state) jobState = state end)

    loopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled or not jobState then return end
        local root, hum = getChar()
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
                    if dir.Magnitude > 0 then root.CFrame = root.CFrame + dir.Unit * Config.RetryDistance + Vector3.new(0, 20, 0)
                    else root.CFrame = root.CFrame + Vector3.new(0, 20, 0) end
                    task.wait(0.6)
                    tweenTo(pickupPos)
                    pickupStuckTime = tick()
                end

                local attempts, success = 0, false
                while attempts < 3 and not success do
                    pickupDelivery()
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
                stopFly()
                tweenTo(destPos)
                task.wait(0.7)
                completeDelivery()
                delivered = true; isFull = false; fullTime = 0
                task.wait(2)
                delivered = false
            end
        else
            if isFull then isFull = false; stopFly() end
        end
    end)
end

local function startAll()
    task.wait(1)
    startNoclip()
    startInfiniteJump()
    startAntiSwim()
    startLoop()
end

-- ==========================================
-- VEHICLE HELPER FUNCTION
-- ==========================================
local function getVehicle()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        return char.Humanoid.SeatPart.Parent -- Returns the vehicle model the player is sitting in
    end
    return nil
end

-- ==========================================
-- ORION UI INITIALIZATION
-- ==========================================
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Hami Hub | Driving Empire", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroEnabled = true,
    IntroText = "Hami Hub Loading..."
})

-- ==========================================
-- TAB 1: AUTO FARMING
-- ==========================================
local FarmTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483362458", PremiumOnly = false})

FarmTab:AddSection({Name = "Delivery Farm"})
FarmTab:AddParagraph("Auto Delivery", "Join the delivery job first before turning it on.")
FarmTab:AddToggle({
    Name = "Auto Delivery",
    Default = false,
    Callback = function(state)
        if state then
            if not _G.InitDone then
                pcall(function()
                    local hasPass = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1744052086)
                    maxItems = hasPass and 8 or 4
                end)
                startAll()
                _G.InitDone = true
            end
            Config.Enabled = true
        else
            Config.Enabled = false
        end
    end    
})

FarmTab:AddSection({Name = "Passive Income"})
FarmTab:AddToggle({
    Name = "Auto Highway Farm",
    Default = false,
    Callback = function(Value)
        getgenv().AutoHighway = Value
        while getgenv().AutoHighway do
            task.wait(0.5)
            -- [PLACEHOLDER] Tween vehicle along highway nodes
        end
    end    
})

FarmTab:AddToggle({
    Name = "Auto Race",
    Default = false,
    Callback = function(Value)
        getgenv().AutoRace = Value
        while getgenv().AutoRace do
            task.wait(1)
            -- [PLACEHOLDER] Teleport to race, hold W, teleport to finish
        end
    end    
})

-- ==========================================
-- TAB 2: VEHICLE MODS
-- ==========================================
local VehicleTab = Window:MakeTab({Name = "Vehicle", Icon = "rbxassetid://4483362458", PremiumOnly = false})

VehicleTab:AddSection({Name = "Performance"})

VehicleTab:AddSlider({
    Name = "Speed Modifier",
    Min = 100, Max = 1000, Default = 200, Color = Color3.fromRGB(0, 255, 100), Increment = 10, ValueName = "Speed",
    Callback = function(Value)
        -- Applies basic velocity boost to the vehicle's primary part
        local veh = getVehicle()
        if veh and veh.PrimaryPart then
            veh.PrimaryPart.Velocity = veh.PrimaryPart.CFrame.LookVector * Value
        end
    end    
})

VehicleTab:AddButton({
    Name = "Auto Flip Car",
    Callback = function()
        local veh = getVehicle()
        if veh and veh.PrimaryPart then
            -- Resets the X and Z rotation to 0 to flip the car upright
            local currentPos = veh.PrimaryPart.Position
            veh:SetPrimaryPartCFrame(CFrame.new(currentPos) * CFrame.Angles(0, math.rad(veh.PrimaryPart.Orientation.Y), 0))
        end
    end    
})

VehicleTab:AddSection({Name = "Handling"})

VehicleTab:AddToggle({
    Name = "Instant Brakes",
    Default = false,
    Callback = function(Value)
        getgenv().InstantBrakes = Value
        -- [PLACEHOLDER] Override A-Chassis brake torque value
    end    
})

VehicleTab:AddToggle({
    Name = "Infinite Grip",
    Default = false,
    Callback = function(Value)
        getgenv().InfGrip = Value
        -- [PLACEHOLDER] Override CustomPhysicalProperties friction on wheels
    end    
})

VehicleTab:AddToggle({
    Name = "No Car Damage",
    Default = false,
    Callback = function(Value)
        -- [PLACEHOLDER] Delete or disable the vehicle damage script inside the car
    end    
})

-- ==========================================
-- TAB 3: TELEPORTS
-- ==========================================
local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local function tpPlayer(pos)
    local root, _ = getChar()
    if root then
        local veh = getVehicle()
        if veh then
            veh:SetPrimaryPartCFrame(CFrame.new(pos))
        else
            root.CFrame = CFrame.new(pos)
        end
    end
end

TeleportTab:AddButton({
    Name = "Teleport to Dealership",
    Callback = function()
        tpPlayer(Vector3.new(0, 50, 0)) -- Replace with exact dealership coordinates
    end    
})

TeleportTab:AddButton({
    Name = "Teleport to Highway",
    Callback = function()
        tpPlayer(Vector3.new(500, 50, 500)) -- Replace with exact highway coordinates
    end    
})

TeleportTab:AddButton({
    Name = "Teleport to Drag Race",
    Callback = function()
        tpPlayer(Vector3.new(-500, 50, -500)) -- Replace with exact drag strip coordinates
    end    
})

-- ==========================================
-- TAB 4: MISCELLANEOUS
-- ==========================================
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})

MiscTab:AddToggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(Value)
        getgenv().AntiAFK = Value
        if getgenv().AntiAFK then
            LocalPlayer.Idled:Connect(function()
                if getgenv().AntiAFK then
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
            OrionLib:MakeNotification({Name = "Anti-AFK", Content = "You will no longer be kicked for inactivity.", Image = "rbxassetid://4483362458", Time = 3})
        end
    end    
})

MiscTab:AddButton({
    Name = "Unlock Gamepasses (Client-Side)",
    Callback = function()
        -- [PLACEHOLDER] Bypass client-side checks for gamepass UI locks
        OrionLib:MakeNotification({Name = "Visual Only", Content = "Gamepasses visually unlocked. Server checks may still prevent use.", Image = "rbxassetid://4483362458", Time = 3})
    end    
})

-- Initialize UI
OrionLib:Init()
