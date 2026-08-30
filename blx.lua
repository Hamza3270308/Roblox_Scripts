-- HAMI HUB | Blox Fruits Script
-- UI Loading Bug Fixed: UI loads first, background tasks are protected.

-- 1. WAIT FOR GAME TO LOAD
if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- 2. SETUP DEFAULTS FIRST
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

-- 3. SAFE CONFIG LOADER
function LoadSettings()
    pcall(function()
        if isfile and readfile and isfile("HamiHubConfig.json") then
            local fileData = readfile("HamiHubConfig.json")
            if fileData and fileData ~= "" then
                local Decode = game:GetService("HttpService"):JSONDecode(fileData)
                for i,v in pairs(Decode) do
                    _G.Settings[i] = v
                end
            end
        end
    end)
end

function SaveSettings()
    pcall(function()
        if writefile then
            writefile("HamiHubConfig.json", game:GetService("HttpService"):JSONEncode(_G.Settings))
        end
    end)
end
LoadSettings()

-- 4. INITIALIZE RAYFIELD & BUILD UI IMMEDIATELY
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "HAMI HUB | Blox Fruits",
    LoadingTitle = "Loading HAMI HUB...",
    LoadingSubtitle = "by Hamii0327",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HamiHub",
        FileName = "HamiHubConfig_UI"
    },
    Discord = {
        Enabled = false,
        Invite = "", 
        RememberJoins = true 
    },
    KeySystem = false, 
})

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
    CurrentOption = {_G.Settings.Configs["Fast Attack Type"] or "Fast"},
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
    CurrentOption = {_G.Settings.Configs["Select Weapon"] or "Melee"},
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

Rayfield:LoadConfiguration() -- Finalizes UI

-- 5. SAFELY HOOK COMBAT FRAMEWORK (Delayed to prevent crashes)
local CombatFrameworkR = nil
task.spawn(function()
    pcall(function()
        local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
        CombatFrameworkR = getupvalues(CombatFramework)[2] or debug.getupvalue(CombatFramework, 2)
    end)
end)

-- 6. BACKGROUND LOGIC
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
    if not CombatFrameworkR then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    local ac = CombatFrameworkR.activeController
    if not ac then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    local ret = ac.blades[1]
    if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    pcall(function()
        while ret.Parent~=game.Players.LocalPlayer.Character do ret=ret.Parent end
    end)
    if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
    return ret
end

function AttackFunction()
    if not CombatFrameworkR then return end
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        for indexincrement = 1, 1 do
            local bladehit = getAllBladeHits(60)
            if #bladehit > 0 then
                pcall(function()
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
                end)
            end
        end
    end
end

-- Fast Attack Loop
task.spawn(function()
    while task.wait(.1) do
        if CombatFrameworkR then
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
                    pcall(function() ac:attack() end)
                end
            end
        end
    end
end)

-- Auto Haki Loop
task.spawn(function()
    while task.wait(1) do
        if _G.Settings.Configs["Auto Haki"] and game.Players.LocalPlayer.Character then
            if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
                end)
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
