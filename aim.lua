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

    local function collectGoldBars()
        while true do
            -- Stop the script if sack is full
            if sackLabel.Text == "10/10" then
                return false -- Indicate collection should stop
            end

            local foundGold = false

            for _, goldBar in pairs(goldBarFolder:GetChildren()) do
                if goldBar:IsA("Model") then
                    for _, part in pairs(goldBar:GetChildren()) do
                        if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= 400 then
                            foundGold = true
                            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                            task.wait(0.5) -- Let teleport settle

                            storeItemRemote:FireServer(goldBar)
                            task.wait(0.3) -- Keep firing StoreItem

                            -- Check sack again after collecting each item
                            if sackLabel.Text == "10/10" then
                                return false -- Stop the loop
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

    while true do
        for _, pos in ipairs(positions) do
            hrp.CFrame = CFrame.new(pos) -- Teleport to location
            task.wait(1) -- Let surroundings load

            if not collectGoldBars() then
                return -- **Exit the entire script when sack is full**
            end
        end
    end
end)
