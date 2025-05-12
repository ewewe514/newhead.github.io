task.spawn(function()
    local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Locate player's Sack in Workspace
    local sack = workspace:WaitForChild(player.Name):WaitForChild("Sack")
    local sackLabel = sack:WaitForChild("BillboardGui"):WaitForChild("TextLabel")

    -- Locations to teleport to before searching for GoldBars
    local positions = {
        Vector3.new(57, -5, 21959),
        Vector3.new(57, -5, 13973),
        Vector3.new(57, -5, 6025),
        Vector3.new(57, -5, -9000),
        Vector3.new(57, -5, -25870),
        Vector3.new(57, -5, -33844)
    }

    -- Check sack capacity
    local function isSackFull()
        return sackLabel.Text == "10/10"
    end

    -- Find **all nearby GoldBars** within 500 studs
    local function findNearbyGoldBars()
        local nearbyGoldBars = {}
        for _, goldBar in pairs(goldBarFolder:GetChildren()) do
            if goldBar:IsA("Model") then
                for _, part in pairs(goldBar:GetChildren()) do
                    if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= 500 then
                        table.insert(nearbyGoldBars, part)
                    end
                end
            end
        end
        return nearbyGoldBars
    end

    -- Collect ALL GoldBars before teleporting to the next position
    local function collectGoldBars()
        while true do
            if isSackFull() then
                print("Sack is full! Stopping script.")
                return false
            end

            local goldBars = findNearbyGoldBars()

            if #goldBars > 0 then
                for _, goldBar in ipairs(goldBars) do
                    -- **Teleport -5 under each GoldBar**
                    hrp.CFrame = CFrame.new(goldBar.Position.X, -5, goldBar.Position.Z)
                    task.wait(0.5) -- Allow teleport to settle

                    -- **Store the GoldBar**
                    storeItemRemote:FireServer(goldBar)
                    task.wait(0.3) -- Short delay to ensure StoreItem processes

                    -- **Track Sack progress dynamically**
                    print("Current Sack Capacity:", sackLabel.Text)

                    -- **Check Sack again after collecting each item**
                    if isSackFull() then
                        return false -- Stop everything when Sack is full
                    end
                end
            else
                break -- No more GoldBars nearby, move to the next position
            end

            task.wait(0.5) -- Short delay before rechecking
        end

        return true -- Continue collecting at the next location
    end

    -- Loop through locations, scanning GoldBars **1 second after teleporting**
    while true do
        for _, pos in ipairs(positions) do
            if isSackFull() then return end -- **Stop entire script when Sack is full**

            -- **Teleport player to the predefined search location (-5 on Y-axis)**
            hrp.CFrame = CFrame.new(pos.X, -5, pos.Z)
            task.wait(1) -- Wait 1 second before searching for GoldBars

            -- **Scan up to 500 studs around the position for GoldBars, then collect**
            if not collectGoldBars() then return end -- Stop when Sack is full
        end
    end
end)
