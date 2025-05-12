task.spawn(function()
    local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")

    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local sackLabel = player.Backpack:WaitForChild("Sack"):WaitForChild("BillboardGui"):WaitForChild("TextLabel")

    local positions = {
        Vector3.new(57, -5, 21959),
        Vector3.new(57, -5, 13973),
        Vector3.new(57, -5, 6025),
        Vector3.new(57, -5, -9000),
        Vector3.new(57, -5, -25870),
        Vector3.new(57, -5, -33844)
    }

    -- Function to collect all nearby GoldBars before moving
    local function collectGoldBars()
        while true do
            -- Stop the script entirely if sack is full
            if sackLabel.Text == "10/10" then
                return false
            end

            local foundGold = false

            for _, goldBar in pairs(goldBarFolder:GetChildren()) do
                if goldBar:IsA("Model") then
                    for _, part in pairs(goldBar:GetChildren()) do
                        if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= 400 then
                            foundGold = true
                            
                            -- **Spawn player -5 under the map instead of above the GoldBar**
                            hrp.CFrame = CFrame.new(part.Position.X, -5, part.Position.Z)
                            task.wait(0.5) -- Wait for teleport positioning

                            storeItemRemote:FireServer(goldBar)
                            task.wait(0.3) -- Delay after firing StoreItem

                            -- Check sack again after collecting each item
                            if sackLabel.Text == "10/10" then
                                return false -- Stop everything if full
                            end
                        end
                    end
                end
            end

            -- Stop scanning if no GoldBars were found
            if not foundGold then break end

            task.wait(0.5) -- Short pause before rechecking
        end

        return true -- Continue collecting at the next location
    end

    -- Loop through locations, ensuring GoldBars are fully collected before teleporting
    while true do
        for _, pos in ipairs(positions) do
            -- Teleport player to the **correct position (-5 on Y-axis)**
            hrp.CFrame = CFrame.new(pos.X, -5, pos.Z)
            task.wait(1) -- Let surroundings load

            -- Collect GoldBars **before teleporting again**
            if not collectGoldBars() then
                return -- **Stop script once sack reaches 10/10**
            end
        end
    end
end)
