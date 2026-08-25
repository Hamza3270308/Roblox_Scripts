-- Delta-Compatible UI using the active 'jensonhirst' Orion fork
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Create the Window
local Window = OrionLib:MakeWindow({
    Name = "HAMI HUB", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "HamiHub"
})

-- Create the Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Create the Section
local MainMenu = MainTab:AddSection({
    Name = "MAIN MENU"
})

-- Add Toggles
MainMenu:AddToggle({
    Name = "Auto Hatch",
    Default = true,
    Callback = function(Value)
        print("Auto Hatch:", Value)
    end    
})

MainMenu:AddToggle({
    Name = "Egg ESP",
    Default = true,
    Callback = function(Value)
        print("Egg ESP:", Value)
    end    
})

MainMenu:AddToggle({
    Name = "Infinite Jump",
    Default = true,
    Callback = function(Value)
        print("Infinite Jump:", Value)
    end    
})

-- Add Sliders
MainMenu:AddSlider({
    Name = "Player Speed",
    Min = 0,
    Max = 100,
    Default = 75,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 1,
    ValueName = "%",
    Callback = function(Value)
        print("Player Speed:", Value)
    end    
})

MainMenu:AddSlider({
    Name = "Jump Height",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 1,
    ValueName = "%",
    Callback = function(Value)
        print("Jump Height:", Value)
    end    
})

-- Initialize UI
OrionLib:Init()
