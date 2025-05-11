local positions = {
    Vector3.new(57, -5, 21959),
    Vector3.new(57, -5, 13973),
    Vector3.new(57, -5, 6025),
    Vector3.new(57, -5, -9000),
    Vector3.new(57, -5, -25870),
    Vector3.new(57, -5, -33844)
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")

-- Safe teleport function
local function safeTeleport(pos)
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

-- Main loop: For each waypoint…
for _, waypoint in ipairs(positions) do
    -- Teleport to the waypoint.
    safeTeleport(waypoint)
    wait(0.5)  -- Allow time to settle.
    
    -- Get the folder of gold bars.
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    
    -- Process each gold bar in the folder.
    for _, goldBar in ipairs(goldBarFolder:GetChildren()) do
        if goldBar:IsA("BasePart") then
            -- Save the current waypoint position so we can return afterward.
            local savedPos = waypoint
            
            -- Teleport 5 studs BELOW the gold bar.
            local targetPos = goldBar.CFrame.p + Vector3.new(0, -5, 0)
            safeTeleport(targetPos)
            wait(0.4)  -- Wait for the character to settle.
            
            local parentModel = goldBar:FindFirstAncestorOfClass("Model") or goldBar.Parent
            if parentModel and parentModel:IsA("Model") then
                -- Keep firing the remote every 0.4 seconds until the gold bar is removed.
                while goldBar.Parent do
                    storeItemRemote:FireServer(parentModel)
                    wait(0.4)
                end
            end
            
            -- Return to the waypoint after processing this gold bar.
            safeTeleport(savedPos)
            wait(0.2)
        end
    end
    
    wait(0.5)  -- Pause briefly before moving on to the next waypoint.
end
