local positions = {
    Vector3.new(57, -5, 21959),
    Vector3.new(57, -5, 13973),
    Vector3.new(57, -5, 6025),
    Vector3.new(57, -5, -9000),
    Vector3.new(57, -5, -25870),
    Vector3.new(57, -5, -33844)
}

local flightSpeed = 500
local waypointThreshold = 5
local goldProximityThreshold = 30 -- Only process gold bars if they're within 30 studs of the HRP.

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
local processedGoldBars = {}

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

-- Flight Loop: continuously drives toward the current waypoint.
task.spawn(function()
    local targetIndex = 1
    while targetIndex <= #positions do
        if not isCollecting then
            local targetPos = positions[targetIndex]
            local dist = (hrp.Position - targetPos).Magnitude
            if dist < waypointThreshold then
                targetIndex = targetIndex + 1
                task.wait(0.1)
            else
                local dir = (targetPos - hrp.Position).Unit
                bv.Velocity = dir * flightSpeed
            end
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        task.wait(0.05)
    end
    bv.Velocity = Vector3.new(0, 0, 0)
end)

-- Gold Bar Batch Collection Loop:
task.spawn(function()
    while true do
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        local nearbyGoldBars = {}
        -- Gather any unprocessed gold bars that are within the threshold.
        for _, item in pairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") and (not processedGoldBars[item]) then
                local distance = (hrp.Position - item.Position).Magnitude
                if distance <= goldProximityThreshold then
                    table.insert(nearbyGoldBars, item)
                end
            end
        end

        if #nearbyGoldBars > 0 then
            isCollecting = true
            local savedCFrame = hrp.CFrame
            for _, item in ipairs(nearbyGoldBars) do
                if item and item.Parent then
                    processedGoldBars[item] = true
                    -- Teleport 5 studs BELOW the gold bar.
                    safeTeleport(item.CFrame.p + Vector3.new(0, -5, 0))
                    task.wait(0.9) -- Wait for your position to settle.
                    local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                    if parentModel and parentModel:IsA("Model") then
                        local startTime = tick()
                        -- Keep firing until the gold bar is removed (or up to 2 seconds)
                        while (item and item.Parent) and (tick() - startTime < 2) do
                            storeItemRemote:FireServer(parentModel)
                            task.wait(0.2)
                        end
                    end
                end
            end
            -- After processing the entire batch, return to the saved flight position.
            safeTeleport(savedCFrame)
            isCollecting = false
        end
        task.wait(0.1)
    end
end)
