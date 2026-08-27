MainTab:CreateToggle({
   Name = "Auto Coin Farm",
   CurrentValue = false,
   Flag = "AutoCoin",
   Callback = function(Value)
      _G.AutoCoin = Value
      
      if Value then
          -- Wrap the loop in task.spawn to prevent UI freezing
          task.spawn(function()
              while _G.AutoCoin do
                  task.wait(0.1)
                  local character = LocalPlayer.Character
                  if character and character:FindFirstChild("HumanoidRootPart") then
                      -- MM2 Maps are generated inside a folder called "Normal"
                      local normalFolder = Workspace:FindFirstChild("Normal")
                      if normalFolder then
                          -- Look for CoinContainer specifically inside the current map instead of the whole workspace
                          local coinContainer = normalFolder:FindFirstChild("CoinContainer", true)
                          
                          if coinContainer then
                              for _, coin in pairs(coinContainer:GetChildren()) do
                                  if _G.AutoCoin == false then break end -- Exit instantly if turned off
                                  
                                  -- Teleport to the coin
                                  if coin:IsA("BasePart") then
                                      character.HumanoidRootPart.CFrame = coin.CFrame
                                      task.wait(0.2) -- Wait briefly so the server registers the touch
                                  end
                              end
                          end
                      end
                  end
              end
          end)
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Grab Dropped Gun",
   CurrentValue = false,
   Flag = "AutoGun",
   Callback = function(Value)
      _G.AutoGun = Value
      
      if Value then
          -- Wrap the loop in task.spawn to prevent UI freezing
          task.spawn(function()
              while _G.AutoGun do
                  task.wait(0.1)
                  local character = LocalPlayer.Character
                  if character and character:FindFirstChild("HumanoidRootPart") then
                      -- Look for the dropped gun
                      local gunDrop = Workspace:FindFirstChild("GunDrop")
                      if gunDrop then
                          -- Safely handle it whether the game loads it as a Model or a Part
                          if gunDrop:IsA("Model") then
                              character.HumanoidRootPart.CFrame = gunDrop:GetPivot()
                          elseif gunDrop:IsA("BasePart") then
                              character.HumanoidRootPart.CFrame = gunDrop.CFrame
                          end
                          
                          task.wait(0.5) -- Add a small cooldown so we don't glitch under the map
                      end
                  end
              end
          end)
      end
   end,
})
