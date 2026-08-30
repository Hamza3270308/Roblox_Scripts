-- HAMI HUB | Blox Fruits Script
-- Migrated to Rayfield Library (100% supported by Delta Executor)
-- Fixed and cleaned up runtime errors, undefined variables, and UI conflicts.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "HAMI HUB | Blox Fruits",
    LoadingTitle = "Loading HAMI HUB...",
    LoadingSubtitle = "by Hamii0327",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HamiHub",
        FileName = "HamiHubConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "", 
        RememberJoins = true 
    },
    KeySystem = false, 
})

print("https://discord.gg/aUd8umqUKu")
if setclipboard then setclipboard("https://discord.gg/aUd8umqUKu") end

if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Death") then
    game:GetService("ReplicatedStorage").Effect.Container.Death:Destroy()
end
if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Respawn") then
    game:GetService("ReplicatedStorage").Effect.Container.Respawn:Destroy()
end

_G.Settings = {
    Main = {
        ["Auto Farm Level"] = false,
    },
    Configs = {
        ["Fast Attack"] = true,
        ["Fast Attack Type"] = "Fast",
        ["Select Weapon"] = "Melee",
        ["Auto Haki"] = true,
    }
}

local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
local cooldownfastattack = tick()

function getAllBladeHits(Sizes)
    local Hits = {}
    local Client = game.Players.LocalPlayer
    local Enemies = game:GetService("Workspace").Enemies:GetChildren()
    for i=1,#Enemies do local v = Enemies[i]
        local Human = v:FindFirstChildOfClass("Humanoid")
        if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
            table.insert(Hits,Human.RootPart)
        end
    end
    return Hits
end

function CurrentWeapon()
    local ac = CombatFrameworkR.activeController
    local ret = ac.blades[1]
    if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    pcall(function()
        while ret.Parent~=game.Players.LocalPlayer.Character do ret=ret.Parent end
    end)
    if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    return ret
end

function AttackFunction()
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        for indexincrement = 1, 1 do
            local bladehit = getAllBladeHits(60)
            if #bladehit > 0 then
                local AcAttack8 = debug.getupvalue(ac.attack, 5)
                local AcAttack9 = debug.getupvalue(ac.attack, 6)
                local AcAttack7 = debug.getupvalue(ac.attack, 4)
                local AcAttack10 = debug.getupvalue(ac.attack, 7)
                local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
                local NumberAc13 = AcAttack7 * 798405
                (function()
                    NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
                    AcAttack8 = math.floor(NumberAc12 / AcAttack9)
                    AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
                end)()
                AcAttack10 = AcAttack10 + 1
                debug.setupvalue(ac.attack, 5, AcAttack8)
                debug.setupvalue(ac.attack, 6, AcAttack9)
                debug.setupvalue(ac.attack, 4, AcAttack7)
                debug.setupvalue(ac.attack, 7, AcAttack10)
                for k, v in pairs(ac.animator.anims.basic) do
                    v:Play(0.01,0.01,0.01)
                end                  
                if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
                    game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
                end
            end
        end
    end
end

-- Initialize folders
if not workspace:FindFirstChild("EnemySpawns") then
    local EnemySpawns = Instance.new("Folder", workspace)
    EnemySpawns.Name = "EnemySpawns"
end

function LoadSettings()
    -- Reduced and simplified for modern executors
    if isfile and readfile then
        if isfile("HamiHubConfig.json") then
            local Decode = game:GetService("HttpService"):JSONDecode(readfile("HamiHubConfig.json"))
            for i,v in pairs(Decode) do
                _G.Settings[i] = v
            end
        end
    end
end

function SaveSettings()
    if writefile then
        writefile("HamiHubConfig.json", game:GetService("HttpService"):JSONEncode(_G.Settings))
    end
end
LoadSettings()

local function QuestCheck()
    local QuestLevel, NPCPosition, MobName, QuestName, LevelRequire, Mon, MobCFrame = 1, CFrame.new(), "", "", 0, "", {}
    local Lvl = game:GetService("Players").LocalPlayer.Data.Level.Value
    
    if Lvl >= 1 and Lvl <= 9 then
        if tostring(game.Players.LocalPlayer.Team) == "Marines" then
            MobName = "Trainee [Lv. 5]"
            QuestName = "MarineQuest"
            QuestLevel = 1
            Mon = "Trainee"
            NPCPosition = CFrame.new(-2709.67, 24.52, 2104.24)
        elseif tostring(game.Players.LocalPlayer.Team) == "Pirates" then
            MobName = "Bandit [Lv. 5]"
            Mon = "Bandit"
            QuestName = "BanditQuest1"
            QuestLevel = 1
            NPCPosition = CFrame.new(1059.99, 16.92, 1549.28)
        end
        return {QuestLevel, NPCPosition, MobName, QuestName, LevelRequire, Mon, MobCFrame}
    end
    
    local GuideModule = require(game:GetService("ReplicatedStorage").GuideModule)
    local Quests = require(game:GetService("ReplicatedStorage").Quests)
    for i,v in pairs(GuideModule["Data"]["NPCList"]) do
        for i1,v1 in pairs(v["Levels"]) do
            if Lvl >= v1 then
                if v1 > LevelRequire then
                    NPCPosition = i["CFrame"]
                    QuestLevel = i1
                    LevelRequire = v1
                end
                if #v["Levels"] == 3 and QuestLevel == 3 then
                    NPCPosition = i["CFrame"]
                    QuestLevel = 2
                    LevelRequire = v["Levels"][2]
                end
            end
        end
    end

    for i,v in pairs(Quests) do
        for i1,v1 in pairs(v) do
            if v1["LevelReq"] == LevelRequire and i ~= "CitizenQuest" then
                QuestName = i
                for i2,v2 in pairs(v1["Task"]) do
                    MobName = i2
                    Mon = string.split(i2," [Lv. ")[1]
                end
            end
        end
    end
    
    if not MobName:find("Lv") then
        for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
            local MonLV = string.match(v.Name, "%d+")
            if v.Name:find(MobName) and #v.Name > #MobName and (MonLV and tonumber(MonLV) <= Lvl + 50) then
                MobName = v.Name
                Mon = string.split(v.Name, " [Lv.")[1]
            end
        end
    end
    
    return {QuestLevel, NPCPosition, MobName, QuestName, LevelRequire, Mon, {CFrame.new()}}
end

function Bypass(Point)
    task.wait(1.5)
    _G.StopTween = true
    _G.StertScript = false

    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
    if game.Players.LocalPlayer.Character:FindFirstChild("Head") then
        game.Players.LocalPlayer.Character.Head:Destroy()
    end
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Point * CFrame.new(0,50,0)
    task.wait(0.2)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Point
    task.wait(0.1)
    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
    task.wait(0.1)
    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
    
    _G.StopTween = false
    _G.StertScript = false
end
    
local function toTarget(...)
    local RealtargetPos = {...}
    local targetPos = RealtargetPos[1]
    local RealTarget
    if type(targetPos) == "vector" then
        RealTarget = CFrame.new(targetPos)
    elseif type(targetPos) == "userdata" then
        RealTarget = targetPos
    elseif type(targetPos) == "number" then
        RealTarget = CFrame.new(unpack(RealtargetPos))
    end

    if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health == 0 then 
        if tween then tween:Cancel() end 
        repeat task.wait() until game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health > 0
        task.wait(0.2) 
    end

    local tweenfunc = {}
    local Distance = (RealTarget.Position - game:GetService("Players").LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).Magnitude
    local Speed = Distance < 1000 and 315 or 300

    if _G.Settings.Configs["Bypass TP"] and Distance > 3000 then
        pcall(function()
            if tween then tween:Cancel() end
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = RealTarget
            task.wait(.08)
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
            return
        end)
    end

    local tween_s = game:service"TweenService"
    local info = TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear)
    local tweenw, err = pcall(function()
        tween = tween_s:Create(game.Players.LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = RealTarget})
        tween:Play()
    end)

    function tweenfunc:Stop() tween:Cancel() end 
    function tweenfunc:Wait() tween.Completed:Wait() end 

    return tweenfunc
end

function InMyNetWork(object)
    if isnetworkowner then
        return isnetworkowner(object)
    else
        return (object.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350
    end
end

task.spawn(function()
    while true do task.wait()
        if setscriptable then setscriptable(game.Players.LocalPlayer, "SimulationRadius", true) end
        if sethiddenproperty then sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge) end
    end
end)

function EquipWeapon(Tool)
    pcall(function()
        if game.Players.LocalPlayer.Backpack:FindFirstChild(Tool) then 
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild(Tool)) 
        end
    end)
end

-------------------- [UI CONSTRUCTION - RAYFIELD] --------------------

local TabMain = Window:CreateTab("Main Farm", 4483362458)
local TabConfig = Window:CreateTab("Config", 4483345998)

TabMain:CreateSection("Auto Farming")

TabMain:CreateToggle({
    Name = "Auto Farm Level",
    CurrentValue = _G.Settings.Main["Auto Farm Level"],
    Flag = "AutoFarmLevelToggle", 
    Callback = function(Value)
        _G.AutoFarmLevelReal = Value
        _G.Settings.Main["Auto Farm Level"] = Value
        SaveSettings()
    end,
})

TabConfig:CreateSection("Combat Settings")

TabConfig:CreateToggle({
    Name = "Fast Attack",
    CurrentValue = _G.Settings.Configs["Fast Attack"],
    Flag = "FastAttackToggle",
    Callback = function(Value)
        _G.Settings.Configs["Fast Attack"] = Value
        SaveSettings()
    end,
})

TabConfig:CreateDropdown({
    Name = "Fast Attack Type",
    Options = {"Fast", "Normal", "Slow"},
    CurrentOption = {"Fast"},
    MultipleOptions = false,
    Flag = "FastAttackDrop",
    Callback = function(Option)
        _G.Settings.Configs["Fast Attack Type"] = Option[1]
        SaveSettings()
    end,
})

TabConfig:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Sword", "Fruit"},
    CurrentOption = {"Melee"},
    MultipleOptions = false,
    Flag = "WeaponDrop",
    Callback = function(Option)
        local SelectWeapon = Option[1]
        for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if v.ToolTip == SelectWeapon or (SelectWeapon == "Fruit" and v.ToolTip == "Blox Fruit") then
                _G.Settings.Configs["Select Weapon"] = v.Name
            end
        end
        SaveSettings()
    end,
})

TabConfig:CreateToggle({
    Name = "Auto Haki",
    CurrentValue = _G.Settings.Configs["Auto Haki"],
    Flag = "AutoHakiToggle",
    Callback = function(Value)
        _G.Settings.Configs["Auto Haki"] = Value
        SaveSettings()
    end,
})

-------------------- [BACKGROUND LOOPS] --------------------

-- Fast Attack Loop
task.spawn(function()
    while task.wait(.1) do
        local ac = CombatFrameworkR.activeController
        if ac and ac.equipped then
            if _G.AutoFarmLevelReal and _G.Settings.Configs["Fast Attack"] then
                AttackFunction()
                if _G.Settings.Configs["Fast Attack Type"] == "Normal" then
                    if tick() - cooldownfastattack > .9 then task.wait(.1); cooldownfastattack = tick() end
                elseif _G.Settings.Configs["Fast Attack Type"] == "Fast" then
                    if tick() - cooldownfastattack > 1.5 then task.wait(.01); cooldownfastattack = tick() end
                elseif _G.Settings.Configs["Fast Attack Type"] == "Slow" then
                    if tick() - cooldownfastattack > .3 then task.wait(.7); cooldownfastattack = tick() end
                end
            elseif _G.AutoFarmLevelReal and not _G.Settings.Configs["Fast Attack"] then
                if ac.hitboxMagnitude ~= 55 then ac.hitboxMagnitude = 55 end
                ac:attack()
            end
        end
    end
end)

-- Auto Haki Loop
task.spawn(function()
    while task.wait(1) do
        if _G.Settings.Configs["Auto Haki"] and game.Players.LocalPlayer.Character then
            if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
            end
        end
    end
end)

-- Noclip & Physics Loop
task.spawn(function()
    while task.wait() do 
        if _G.AutoFarmLevelReal and game.Players.LocalPlayer.Character then
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not hrp:FindFirstChild("BodyVelocity1") then
                    if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
                        game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
                    end
                    local BodyVelocity = Instance.new("BodyVelocity")
                    BodyVelocity.Name = "BodyVelocity1"
                    BodyVelocity.Parent = hrp
                    BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
                    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false    
                end
            end
        else
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local bv = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1")
                if bv then bv:Destroy() end
            end
        end
    end
end)
