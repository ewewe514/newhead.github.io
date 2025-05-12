local positions = {
    Vector3.new(57, -5, 21959),
    Vector3.new(57, -5, 13973),
    Vector3.new(57, -5, 6025),
    Vector3.new(57, -5, -9000),
    Vector3.new(57, -5, -25870),
    Vector3.new(57, -5, -33844)
}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

for _, pos in ipairs(positions) do
    humanoidRootPart.CFrame = CFrame.new(pos)
    wait(5) -- Delay before moving to the next position
end


task.spawn(function()
    local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Find all nearby GoldBars within 500 studs
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

    -- Continuously scan and collect GoldBars
    while true do
        local goldBars = findNearbyGoldBars()

        if #goldBars > 0 then
            for _, goldBar in ipairs(goldBars) do
                -- **Teleport -5 under the GoldBar**
                hrp.CFrame = CFrame.new(goldBar.Position.X, -5, goldBar.Position.Z)
                task.wait(0.1) -- Fast teleport settling

                -- **Store the GoldBar**
                storeItemRemote:FireServer(goldBar.Parent)
                task.wait(0.3) -- Remote firing delay
            end
        end

        task.wait(0.1) -- Constant scanning (never stops)
    end
end)




task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Locate player's Sack in Workspace
    local sack = workspace:WaitForChild(player.Name):WaitForChild("Sack")
    local sackLabel = sack:WaitForChild("BillboardGui"):WaitForChild("TextLabel")

    -- Function to check Sack capacity
    local function isSackFull()
        return sackLabel.Text == "10/10"
    end

    while true do
        if isSackFull() then
            print("Sack is full! Teleporting...")
            hrp.CFrame = CFrame.new(57, 3, 30000) -- Teleport position
            break -- Stop script after teleporting
        end
        task.wait(0.1) -- Check Sack capacity every 0.1 seconds
    end
end)
