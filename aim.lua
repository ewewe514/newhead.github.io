task.spawn(function()
    local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Locate player's Sack in Workspace
    local sack = workspace:WaitForChild(player.Name):WaitForChild("Sack")
    local sackLabel = sack:WaitForChild("StarterPack Sack BillboardGui"):WaitForChild("TextLabel")

    -- Locations to teleport to
    local positions = {
        Vector3.new(57, -5, 21959),
        Vector3.new(57, -5, 13973),
        Vector3.new(57, -5, 6025),
        Vector3.new(57, -5, -9000),
        Vector3.new(57, -5, -25870),
        Vector3.new(57, -5, -33844)
    }

    -- Collect all GoldBars before teleporting
    local function collectGoldBars()
        while true do
            -- **Stop entire script if sack reaches 10/10**
            if sackLabel.Text == "10/10" then
                return false
            end

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
            -- **Teleport player to -5 under the map at the correct position**
            hrp.CFrame = CFrame.new(pos.X, -5, pos.Z)
            task.wait(1) -- Let surroundings load

            -- **Collect GoldBars before teleporting again**
            if not collectGoldBars() then
                return -- **Stop entire script once Sack reaches 10/10**
            end
        end
    end
end)
