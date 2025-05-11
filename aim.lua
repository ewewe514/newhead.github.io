-- List of waypoint positions (you can update or add more as needed)
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

-- Helper function that instantly teleports the HRP
local function safeTeleport(pos)
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
end

-- Forever loop: iterates through all waypoints over and over.
task.spawn(function()
    while true do
        for _, waypoint in ipairs(positions) do
            -- Teleport to the waypoint.
            safeTeleport(waypoint)
            wait(0.5)  -- Give time for stabilization.
            
            -- Get the folder containing gold bars.
            local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
            
            -- Process gold bars until none remain at this waypoint.
            while #goldBarFolder:GetChildren() > 0 do
                -- For every gold bar found, process it.
                for _, goldBar in ipairs(goldBarFolder:GetChildren()) do
                    if goldBar:IsA("BasePart") then
                        -- Teleport 5 studs below the gold bar.
                        safeTeleport(goldBar.CFrame.p + Vector3.new(0, -5, 0))
                        wait(0.9)  -- Wait for the character to settle.
                        
                        -- Determine the model that should be stored.
                        local parentModel = goldBar:FindFirstAncestorOfClass("Model") or goldBar.Parent
                        if parentModel and parentModel:IsA("Model") then
                            -- Repeatedly fire the remote every 0.4 seconds until the gold bar is removed.
                            while goldBar.Parent do
                                storeItemRemote:FireServer(parentModel)
                                wait(0.4)
                            end
                        end
                        
                        -- After processing, return to the waypoint.
                        safeTeleport(waypoint)
                        wait(0.2)
                    end
                end
                wait(0.5)  -- Re-check to see if any new gold bars remain at this waypoint.
            end
            
            wait(0.5)  -- Pause briefly before going to the next waypoint.
        end
    end
end)
