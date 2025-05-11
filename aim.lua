local positions = {
    Vector3.new(57, -5, 21959),
    Vector3.new(57, -5, 13973),
    Vector3.new(57, -5, 6025),
    Vector3.new(57, -5, -9000),
    Vector3.new(57, -5, -25870),
    Vector3.new(57, -5, -33844)
}

local flightSpeed = 500
local waypointThreshold = 5  -- When within 5 studs of a waypoint, move to the next one.

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
local processedGoldBars = {}  -- Tracks which gold bars have already been collected.

-- Create movement controllers.
local bv = Instance.new("BodyVelocity", hrp)
bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
local bg = Instance.new("BodyGyro", hrp)
bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bg.P = 1000
bg.D = 50

-- Simple function to teleport safely.
local function safeTeleport(pos)
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

-------------------------------
-- Flight Loop
-------------------------------
-- Continuously drive toward the current waypoint.
task.spawn(function()
    local targetIndex = 1
    while targetIndex <= #positions do
        if not isCollecting then
            local targetPos = positions[targetIndex]
            local distance = (hrp.Position - targetPos).Magnitude
            if distance < waypointThreshold then
                targetIndex = targetIndex + 1
                task.wait(0.1)  -- Small delay before moving to the next waypoint.
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
-- Continuously scan for any unprocessed gold bar.
task.spawn(function()
    while true do
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        local goldBarFound = nil
        
        for _, item in ipairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") and not processedGoldBars[item] then
                goldBarFound = item
                break
            end
        end

        if goldBarFound then
            isCollecting = true  -- Pause flight.
            local savedCFrame = hrp.CFrame  -- Save current flight position.
            -- Teleport 5 studs BELOW the gold bar.
            safeTeleport(goldBarFound.CFrame.p + Vector3.new(0, -5, 0))
            task.wait(0.9)  -- Wait for the position to settle.
            
            local parentModel = goldBarFound:FindFirstAncestorOfClass("Model") or goldBarFound.Parent
            if parentModel and parentModel:IsA("Model") then
                local startTime = tick()
                -- Repeatedly fire the remote every 0.4 seconds until the gold bar is removed or 2 seconds elapse.
                while (goldBarFound and goldBarFound.Parent) and (tick() - startTime < 2) do
                    storeItemRemote:FireServer(parentModel)
                    task.wait(0.4)
                end
            end
            
            processedGoldBars[goldBarFound] = true  -- Mark as processed.
            safeTeleport(savedCFrame)  -- Return to the flight position.
            isCollecting = false
            task.wait(0.1)
        else
            isCollecting = false
            task.wait(0.1)
        end
    end
end)
