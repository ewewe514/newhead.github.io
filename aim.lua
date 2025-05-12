task.spawn(function()
    local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Locate player's Sack in Workspace
    local sack = workspace:WaitForChild(player.Name):WaitForChild("Sack")
    local sackLabel = sack:WaitForChild("BillboardGui"):WaitForChild("TextLabel") -- Adjusted reference

    -- Locations to teleport to
    local positions = {
        Vector3.new(57, -5, 21959),
        Vector3.new(57, -5, 13973),
        Vector3.new(57, -5, 6025),
        Vector3.new(57, -5, -9000),
        Vector3.new(57, -5, -25870),
        Vector3.new(57, -5, -33844)
    }

    -- Function to continuously check Sack and stop when full
    local function isSackFull()
        while true do
            if sackLabel.Text == "10/10" then
                print("Sack is full! Stopping script.")
                return true -- Stop entire script
            end
            task.wait(0.1) -- Regular check
        end
    end

    -- Collect all GoldBars before teleporting
    local function collectGoldBars()
        while true do
            if isSackFull() then return false end -- Stop if Sack is full

            local foundGold = false

            for _, goldBar in pairs(goldBarFolder:GetChildren()) do
                if goldBar:IsA("Model") then
                    for _, part in pairs(goldBar:GetChildren()) do
                        if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= 400 then
                            foundGold = true

                            -- **Teleport -5 under the map instead of above GoldBar**
                            hrp.CFrame = CFrame.new(part.Position.X, -5, part.Position.Z)
                            task.wait(0.5) -- Let teleport settle

                            storeItemRemote:FireServer(goldBar)
                            task.wait(0.3) -- Delay after firing StoreItem

                            -- **Check Sack again after collecting each item**
                            if isSackFull() then return false end
                        end
                    end
                end
            end

            if not foundGold then break end
            task.wait(0.5) -- Short pause before rechecking
        end

        return true -- Continue collecting at the next location
    end

    -- Loop through locations, ensuring GoldBars are fully collected before teleporting
    while true do
        for _, pos in ipairs(positions) do
            if isSackFull() then return end -- **Stop entire script when Sack is full**
            
            hrp.CFrame = CFrame.new(pos.X, -5, pos.Z) -- Teleport player correctly
            task.wait(1) -- Let surroundings load

            if not collectGoldBars() then return end -- Stop when full
        end
    end
end)
