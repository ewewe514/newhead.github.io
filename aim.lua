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
local timeLimit = 5

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")

local goldCollected = 0

local function safeTeleport(pos)
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
end

local bv = Instance.new("BodyVelocity", hrp)
bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bv.Velocity = Vector3.new()
local bg = Instance.new("BodyGyro", hrp)
bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bg.P = 1000
bg.D = 50

local function processGoldBars(currentTarget)
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    for _, item in ipairs(goldBarFolder:GetChildren()) do
        if item:IsA("BasePart") then
            safeTeleport(item.CFrame.p + Vector3.new(0, 5, 0))
            wait(0.4)
            local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
            if parentModel and parentModel:IsA("Model") then
                storeItemRemote:FireServer(parentModel)
            end
            goldCollected = goldCollected + 1
            if goldCollected >= 10 then
                return true
            end
        end
    end
    safeTeleport(currentTarget)
    wait(0.2)
    return false
end

for _, pos in ipairs(positions) do
    if goldCollected >= 10 then break end
    local targetPos = pos
    local startTime = tick()
    while (tick() - startTime) < timeLimit do
        if (hrp.Position - targetPos).Magnitude < 5 then break end
        local dir = (targetPos - hrp.Position).Unit
        bv.Velocity = dir * 500
        wait(0.05)
    end
    bv.Velocity = Vector3.new(0, 0, 0)
    if (hrp.Position - targetPos).Magnitude >= 5 then
        safeTeleport(targetPos)
    end
    wait(duration)
    local reachedGoal = processGoldBars(targetPos)
    if reachedGoal then break end
end

if goldCollected >= 10 then
    safeTeleport(Vector3.new(57, 3, 30000))
end
