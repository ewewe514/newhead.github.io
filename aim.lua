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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")

-- Start at first waypoint.
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
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

-- Flight loop: continuously drive to the current waypoint.
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

-- Gold bar collection loop: continuously scan for gold bars.
task.spawn(function()
    while true do
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        for _, item in pairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") and not processedGoldBars[item] then
                processedGoldBars[item] = true
                isCollecting = true
                local savedCFrame = hrp.CFrame
                -- Teleport 5 studs below the gold bar.
                safeTeleport(item.CFrame.p + Vector3.new(0, -5, 0))
                task.wait(0.9)
                local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                if parentModel and parentModel:IsA("Model") then
                    for i = 1, 10 do
                        if not (item and item.Parent) then
                            break
                        end
                        storeItemRemote:FireServer(parentModel)
                        task.wait(0.4)
                    end
                end
                isCollecting = false
                safeTeleport(savedCFrame)
            end
        end
        task.wait(0.1)
    end
end)
