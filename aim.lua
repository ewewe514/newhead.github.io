task.spawn(function()
    local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Locate player's Sack in Workspace
    local sack = workspace:WaitForChild(player.Name):WaitForChild("Sack")
    local sackLabel = sack:WaitForChild("BillboardGui"):WaitForChild("TextLabel") -- Correctly referencing the GUI

    -- Locations to teleport to
    local positions = {
        Vector3.new(57, -5, 21959),
        Vector3.new(57, -5, 13973),
        Vector3.new(57, -5, 6025),
        Vector3.new(57, -5, -9000),
        Vector3.new(57, -5, -25870),
        Vector3.new(57, -5, -33844)
    }

    -- Function to check sack capacity
    local function getSackCount()
        return sackLabel.Text
    end

    -- Function to collect and track GoldBars
    local function collectGoldBars()
        while true do
            if getSackCount() == "10/10" then
                print("Sack is full! Stopping script.")
                return false -- Stop script when Sack is full
            end

            local foundGold = false

            for _, goldBar in pairs(goldBarFolder:GetChildren()) do
                if goldBar:IsA("Model") then
                    for _, part in pairs(goldBar:GetChildren()) do
                        if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= 400 then
                            foundGold = true

                            -- **Teleport -5 below the map near the GoldBar**
                            hrp.CFrame = CFrame.new(part.Position.X, -5, part.Position.Z)
                            task.wait(0.5) -- Allow teleport to settle

                            -- **Fire StoreItem remote to collect the GoldBar**
                            storeItemRemote:FireServer(goldBar)
                            task.wait(0.3) -- Short delay to ensure StoreItem processes

                            -- **Print Sack Capacity Each Time a GoldBar is Collected**
                            print("Current Sack Capacity:", getSackCount())

                            -- **Check Sack again after collecting each item**
                            if getSackCount() == "10/10" then
                                return false -- Stop everything when Sack is full
                            end
                        end
                    end
                end
            end

            if not foundGold then break end -- Stop scanning if no GoldBars are found
            task.wait(0.5) -- Short delay before rechecking
        end

        return true -- Continue collecting at the next location
    end

    -- Loop through locations, collecting and tracking Sack count
    while true do
        for _, pos in ipairs(positions) do
            if getSackCount() == "10/10" then return end -- **Stop entire script when Sack is full**

            -- **Teleport player to -5 below the map at correct position**
            hrp.CFrame = CFrame.new(pos.X, -5, pos.Z)
            task.wait(1) -- Allow surroundings to load

            -- **Collect GoldBars before teleporting again**
            if not collectGoldBars() then return end -- Stop when Sack is full
        end
    end
end)
