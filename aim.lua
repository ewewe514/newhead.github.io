local positions = {
    Vector3.new(57, -5, 30000), Vector3.new(57, -5, 28000),
    Vector3.new(57, -5, 26000), Vector3.new(57, -5, 24000),
    Vector3.new(57, -5, 22000), Vector3.new(57, -5, 20000),
    Vector3.new(57, -5, 18000), Vector3.new(57, -5, 16000),
    Vector3.new(57, -5, 14000), Vector3.new(57, -5, 12000),
    Vector3.new(57, -5, 10000), Vector3.new(57, -5, 8000),
    Vector3.new(57, -5, 6000), Vector3.new(57, -5, 4000),
    Vector3.new(57, -5, 2000), Vector3.new(57, -5, 0),
    Vector3.new(57, -5, -2000), Vector3.new(57, -5, -4000),
    Vector3.new(57, -5, -6000), Vector3.new(57, -5, -8000),
    Vector3.new(57, -5, -10000), Vector3.new(57, -5, -12000),
    Vector3.new(57, -5, -14000), Vector3.new(57, -5, -16000),
    Vector3.new(57, -5, -18000), Vector3.new(57, -5, -20000),
    Vector3.new(57, -5, -22000), Vector3.new(57, -5, -24000),
    Vector3.new(57, -5, -26000), Vector3.new(57, -5, -28000),
    Vector3.new(57, -5, -30000), Vector3.new(57, -5, -32000),
    Vector3.new(57, -5, -34000), Vector3.new(57, -5, -36000),
    Vector3.new(57, -5, -38000), Vector3.new(57, -5, -40000),
    Vector3.new(57, -5, -42000), Vector3.new(57, -5, -44000),
    Vector3.new(57, -5, -46000), Vector3.new(57, -5, -48000),
    Vector3.new(57, -5, -49032)
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

-- Start position is the first waypoint.
hrp.CFrame = CFrame.new(57, -5, 30000)

-- Flag to indicate gold bar collection is in progress
local isCollecting = false

local bv = Instance.new("BodyVelocity", hrp)
bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
local bg = Instance.new("BodyGyro", hrp)
bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bg.P = 1000
bg.D = 50

local function safeTeleport(pos)
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

-- Flight loop: continuously moves toward the current target waypoint.
task.spawn(function()
    local targetIndex = 1
    while targetIndex <= #positions do
        if isCollecting then
            bv.Velocity = Vector3.new(0, 0, 0)
            task.wait(0.05)
        else
            local targetPos = positions[targetIndex]
            local dist = (hrp.Position - targetPos).Magnitude
            if dist < waypointThreshold then
                targetIndex = targetIndex + 1
            else
                local dir = (targetPos - hrp.Position).Unit
                bv.Velocity = dir * flightSpeed
            end
            task.wait(0.05)
        end
    end
    bv.Velocity = Vector3.new(0, 0, 0)
end)

-- Gold bar collection loop: continuously scans for gold bars and collects them.
task.spawn(function()
    while true do
        local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        for _, item in pairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") then
                isCollecting = true
                local savedCFrame = hrp.CFrame
                hrp.CFrame = item.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.9) -- allow time for physics/network to settle
                local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                if parentModel and parentModel:IsA("Model") then
                    local args = { parentModel }
                    storeItemRemote:FireServer(unpack(args))
                end
                isCollecting = false
                safeTeleport(savedCFrame)
            end
        end
        task.wait(0.5)
    end
end)
