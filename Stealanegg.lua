-- Load a standard UI Library (Placeholder URL for a popular library like Rayfield/Orion)
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- Create the Main Window (matching the dark theme and green accents)
local Window = Library:MakeWindow({
    Name = "HAMI HUB", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "HamiHub",
    IntroText = "Loading HAMI HUB..."
})

-- ==========================================
-- 1. TABS (Sidebar)
-- ==========================================
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998", -- Home Icon placeholder
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483362458", -- Player Icon placeholder
    PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483362458", -- Visuals Icon placeholder
    PremiumOnly = false
})

local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483362458", -- Sword Icon placeholder
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998", -- Gear Icon placeholder
    PremiumOnly = false
})

-- ==========================================
-- 2. MAIN TAB CONTENT
-- ==========================================

-- Left Column: Main Menu
local MainMenuSection = MainTab:AddSection({
    Name = "MAIN MENU"
})

MainMenuSection:AddToggle({
    Name = "Auto Hatch",
    Default = true,
    Callback = function(Value)
        print("Auto Hatch toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "Egg ESP",
    Default = true,
    Callback = function(Value)
        print("Egg ESP toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "Infinite Jump",
    Default = true,
    Callback = function(Value)
        print("Infinite Jump toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        print("No Clip toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "Teleport",
    Default = false,
    Callback = function(Value)
        print("Teleport toggled:", Value)
    end    
})

-- Right Column / General Main Menu ESP features
MainMenuSection:AddToggle({
    Name = "ESP",
    Default = true,
    Callback = function(Value)
        print("ESP toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "Players",
    Default = false,
    Callback = function(Value)
        print("Players toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "Items",
    Default = false,
    Callback = function(Value)
        print("Items toggled:", Value)
    end    
})

MainMenuSection:AddToggle({
    Name = "Desostlation",
    Default = false,
    Callback = function(Value)
        print("Desostlation toggled:", Value)
    end    
})

-- Sliders
MainMenuSection:AddSlider({
    Name = "Player Speed",
    Min = 0,
    Max = 100,
    Default = 75,
    Color = Color3.fromRGB(0, 255, 100), -- Matching the bright green UI accent
    Increment = 1,
    ValueName = "%",
    Callback = function(Value)
        print("Player Speed changed to:", Value)
    end    
})

MainMenuSection:AddSlider({
    Name = "Jump Height",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 1,
    ValueName = "%",
    Callback = function(Value)
        print("Jump Height changed to:", Value)
    end    
})

-- ==========================================
-- 3. VISUAL MODS SECTION
-- ==========================================
local VisualModsSection = MainTab:AddSection({
    Name = "VISUAL MODS"
})

VisualModsSection:AddToggle({
    Name = "ESP",
    Default = true,
    Callback = function(Value)
        print("Visual Mods ESP toggled:", Value)
    end    
})

VisualModsSection:AddToggle({
    Name = "Players",
    Default = true,
    Callback = function(Value)
        print("Visual Mods Players toggled:", Value)
    end    
})

VisualModsSection:AddToggle({
    Name = "Items",
    Default = true,
    Callback = function(Value)
        print("Visual Mods Items toggled:", Value)
    end    
})

-- Initialize the UI Library
Library:Init()
