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
    while true do
        local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
        local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")

        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        for _, item in pairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") then
                -- Teleport under the GoldBar
                hrp.CFrame = item.CFrame + Vector3.new(0, -5, 0)
                task.wait(0.6) -- Short delay to settle position

                local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                if parentModel and parentModel:IsA("Model") then
                    local args = { parentModel }
                    storeItemRemote:FireServer(unpack(args))
                end
            end
        end

        task.wait(0.5) -- Delay before scanning again
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
