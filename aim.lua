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
local duration = 0.9
local goldPauseDuration = 0.9

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")

local function safeTeleport(pos)
    pcall(function() hrp.CFrame = CFrame.new(pos) end)
end

local function collectGoldBars(returnPos)
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local found = false
    for _, item in ipairs(goldBarFolder:GetChildren()) do
        if item:IsA("BasePart") then
            found = true
            safeTeleport(item.CFrame.p + Vector3.new(0, -5, 0))
            task.wait(1)
            local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
            if parentModel and parentModel:IsA("Model") then
                storeItemRemote:FireServer(parentModel)
            end
            task.wait(goldPauseDuration)
        end
    end
    if found then
        safeTeleport(returnPos)
        task.wait(0.2)
    end
end

local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local root = hrp

local bv = Instance.new("BodyVelocity", root)
bv.Name = velocityHandlerName
bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bv.Velocity = Vector3.new()

local bg = Instance.new("BodyGyro", root)
bg.Name = gyroHandlerName
bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bg.P = 1000
bg.D = 50

for _, pos in ipairs(positions) do
    local targetPos = pos
    while (root.Position - targetPos).Magnitude > 5 do
        local dir = (targetPos - root.Position).Unit
        bv.Velocity = dir * 500
        task.wait(0.05)
    end
    bv.Velocity = Vector3.new(0, 0, 0)
    local returnPos = targetPos
    collectGoldBars(returnPos)
    task.wait(duration)
end
