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

-- Helper: Teleports the HRP to the given position safely.
local function safeTeleport(pos)
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

-- Table to track gold bars that have already been processed.
local processedGoldBars = {}

-- Loop through each waypoint.
for _, waypoint in ipairs(positions) do
    -- Teleport to the current waypoint.
    safeTeleport(waypoint)
    wait(0.5)  -- Allow time to settle.
    
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    
    -- Repeat processing until no new gold bar is found at this waypoint.
    repeat
        local goldFound = false  -- Flag for finding at least one unprocessed gold bar.
        
        for _, goldBar in ipairs(goldBarFolder:GetChildren()) do
            if goldBar:IsA("BasePart") and not processedGoldBars[goldBar] then
                goldFound = true
                processedGoldBars[goldBar] = true  -- Mark this gold bar as processed.
                
                local savedPos = waypoint  -- Save the current waypoint position.
                -- Teleport 5 studs BELOW the gold bar.
                safeTeleport(goldBar.CFrame.p + Vector3.new(0, -5, 0))
                wait(0.4)  -- Give a moment for settling.
                
                local parentModel = goldBar:FindFirstAncestorOfClass("Model") or goldBar.Parent
                if parentModel and parentModel:IsA("Model") then
                    local attempts = 0
                    -- Fire the store remote every 0.4 seconds until the gold bar is removed,
                    -- or until a maximum number of attempts (here, 10) is reached.
                    while goldBar.Parent and attempts < 10 do
                        storeItemRemote:FireServer(parentModel)
                        attempts = attempts + 1
                        wait(0.4)
                    end
                end
                
                -- Return to the waypoint after processing this gold bar.
                safeTeleport(savedPos)
                wait(0.2)
            end
        end
        
        -- If no unprocessed gold bar was found at this waypoint, exit the repeat loop.
        if not goldFound then break end
        
    until false
    
    wait(0.5)  -- Brief pause before moving to the next waypoint.
end
