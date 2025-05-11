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

local processedGoldBars = {}  -- Keeps track of gold bars already handled

-- For each waypoint…
for _, waypoint in ipairs(positions) do
    -- Teleport to the waypoint.
    safeTeleport(waypoint)
    wait(0.5)  -- Allow time for the teleport to settle.
    
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    
    -- Keep checking until there are no unprocessed gold bars at this waypoint.
    repeat
        local goldFound = false
        for _, goldBar in ipairs(goldBarFolder:GetChildren()) do
            if goldBar:IsA("BasePart") and not processedGoldBars[goldBar] then
                goldFound = true
                processedGoldBars[goldBar] = true  -- Mark it as processed.
                
                local savedPos = waypoint  -- Save the current waypoint position.
                -- Teleport exactly 5 studs BELOW the gold bar.
                safeTeleport(goldBar.CFrame.p + Vector3.new(0, -5, 0))
                wait(0.4)  -- Wait for the character to settle.
                
                local parentModel = goldBar:FindFirstAncestorOfClass("Model") or goldBar.Parent
                if parentModel and parentModel:IsA("Model") then
                    -- Keep firing the remote every 0.4 seconds until the gold bar is removed.
                    while goldBar.Parent do
                        storeItemRemote:FireServer(parentModel)
                        wait(0.4)
                    end
                end
                
                -- Return to the saved waypoint.
                safeTeleport(savedPos)
                wait(0.2)
            end
        end
        if not goldFound then break end  -- No new gold bar found; exit the repeat loop.
    until false
    
    wait(0.5)  -- Short pause before moving on to the next waypoint.
end
