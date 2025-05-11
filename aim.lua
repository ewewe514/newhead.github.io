local positions = {
    Vector3.new(57, -5, 21959),
    Vector3.new(57, -5, 13973),
    Vector3.new(57, -5, 6025),
    Vector3.new(57, -5, -9000),
    Vector3.new(57, -5, -25870),
    Vector3.new(57, -5, -33844)
}

local flightSpeed = 500
local waypointThreshold = 5  -- when within 5 studs, move to the next waypoint

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")

-- Start at the first waypoint.
hrp.CFrame = CFrame.new(57, -5, 21959)

local isCollecting = false
local processedGoldBars = {}  -- tracks which gold bars have been handled

local bv = Instance.new("BodyVelocity", hrp)
bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
local bg = Instance.new("BodyGyro", hrp)
bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bg.P = 1000
bg.D = 50

local function safeTeleport(pos)
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
end

-------------------------------
-- Flight Loop
-------------------------------
-- This loop continuously drives the HRP toward the next waypoint.
task.spawn(function()
    local targetIndex = 1
    while targetIndex <= #positions do
        if not isCollecting then
            local targetPos = positions[targetIndex]
            local dist = (hrp.Position - targetPos).Magnitude
            if dist < waypointThreshold then
                targetIndex = targetIndex + 1
                task.wait(0.1) -- small delay before changing waypoint
            else
                local direction = (targetPos - hrp.Position).Unit
                bv.Velocity = direction * flightSpeed
            end
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        task.wait(0.05)
    end
    bv.Velocity = Vector3.new(0, 0, 0)
end)

-------------------------------
-- Gold Bar Collection Loop
-------------------------------
-- This loop continually checks for any unprocessed gold bars.
task.spawn(function()
    while true do
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        local foundAny = false
        
        -- First, check if there's any unprocessed gold bar.
        for _, item in ipairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") and not processedGoldBars[item] then
                foundAny = true
                break
            end
        end
        
        if foundAny then
            isCollecting = true
            local savedCFrame = hrp.CFrame -- Save current flight position
            
            -- Process every unprocessed gold bar in the folder.
            for _, item in ipairs(goldBarFolder:GetChildren()) do
                if item:IsA("BasePart") and not processedGoldBars[item] then
                    processedGoldBars[item] = true  -- Mark as processed
                    -- Teleport 5 studs BELOW the gold bar.
                    safeTeleport(item.CFrame.p + Vector3.new(0, -5, 0))
                    task.wait(0.9) -- Wait for the position to settle.
                    
                    local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                    if parentModel and parentModel:IsA("Model") then
                        local attemptStart = tick()
                        -- Repeatedly fire the remote until the item is removed (or up to 2 seconds).
                        while (item and item.Parent) and (tick() - attemptStart < 2) do
                            storeItemRemote:FireServer(parentModel)
                            task.wait(0.2)
                        end
                    end
                    -- Proceed to the next gold bar in the batch.
                end
            end
            
            safeTeleport(savedCFrame)  -- Return to the saved flight position.
            isCollecting = false
        end
        
        task.wait(0.1)
    end
end)
