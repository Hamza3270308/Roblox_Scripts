-- ==========================================
-- SERVICES & VARIABLES
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- State Variables
local _G = {
    AutoCoin = false,
    AutoGun = false,
    Noclip = false,
    InfJump = false,
    RoleESP = false,
    SpeedValue = 16,
    JumpValue = 50
}

-- ==========================================
-- LOAD UI LIBRARY
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LOCUST HUB | MM2",
   LoadingTitle = "Loading Locust Hub...",
   LoadingSubtitle = "Murder Mystery 2",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Create Tabs
local MainTab = Window:CreateTab("Main", "home")
local PlayerTab = Window:CreateTab("Player", "user")
local VisualsTab = Window:CreateTab("Visuals", "eye")

-- ==========================================
-- MAIN TAB (Automation & Combat)
-- ==========================================
MainTab:CreateSection("AUTOMATION")

MainTab:CreateToggle({
   Name = "Auto Coin Farm",
   CurrentValue = false,
   Flag = "AutoCoin",
   Callback = function(Value)
      _G.AutoCoin = Value
      while _G.AutoCoin do
          task.wait(0.1)
          if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
              -- Look for coin containers in MM2 maps
              for _, v in pairs(Workspace:GetDescendants()) do
                  if v.Name == "CoinContainer" and v:IsA("Part") then
                      LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                      task.wait(0.5) -- Wait briefly to collect
                  end
              end
          end
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Grab Dropped Gun",
   CurrentValue = false,
   Flag = "AutoGun",
   Callback = function(Value)
      _G.AutoGun = Value
      while _G.AutoGun do
          task.wait(0.5)
          if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
              local gunDrop = Workspace:FindFirstChild("GunDrop")
              if gunDrop then
                  LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
              end
          end
      end
   end,
})

-- ==========================================
-- PLAYER TAB (Movement)
-- ==========================================
PlayerTab:CreateSection("MOVEMENT MODS")

PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 150},
   Increment = 1,
   Suffix = " WS",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      _G.SpeedValue = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 200},
   Increment = 1,
   Suffix = " JP",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      _G.JumpValue = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      _G.InfJump = Value
   end,
})

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
      _G.Noclip = Value
   end,
})

RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Keep WalkSpeed active constantly so the game doesn't reset it
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if _G.SpeedValue > 16 then
            LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedValue
        end
    end
end)

-- ==========================================
-- VISUALS TAB (ESP)
-- ==========================================
VisualsTab:CreateSection("ESP SETTINGS")

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Determine Role based on tools in backpack/character
            local role = "Innocent"
            local color = Color3.fromRGB(0, 255, 0) -- Green
            
            local weapons = {}
            for _, v in pairs(player.Backpack:GetChildren()) do table.insert(weapons, v.Name) end
            if player.Character then 
                for _, v in pairs(player.Character:GetChildren()) do if v:IsA("Tool") then table.insert(weapons, v.Name) end end
            end
            
            if table.find(weapons, "Knife") then
                role = "Murderer"
                color = Color3.fromRGB(255, 0, 0) -- Red
            elseif table.find(weapons, "Gun") or table.find(weapons, "Revolver") then
                role = "Sheriff"
                color = Color3.fromRGB(0, 0, 255) -- Blue
            end

            -- Create or Update Highlight
            local highlight = player.Character:FindFirstChild("RoleESP")
            if _G.RoleESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "RoleESP"
                    highlight.Parent = player.Character
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                end
                highlight.FillColor = color
                highlight.OutlineColor = color
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

VisualsTab:CreateToggle({
   Name = "Role ESP (Colors)",
   CurrentValue = false,
   Flag = "RoleESP",
   Callback = function(Value)
      _G.RoleESP = Value
      if not Value then
          -- Clean up ESP when turned off
          for _, player in pairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("RoleESP") then
                  player.Character.RoleESP:Destroy()
              end
          end
      end
   end,
})

-- Loop to constantly update ESP
task.spawn(function()
    while task.wait(1) do
        if _G.RoleESP then
            UpdateESP()
        end
    end
end)
