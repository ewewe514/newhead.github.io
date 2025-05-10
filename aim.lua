local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

FLYING = true
local iyflyspeed = 500
local FlightBlock = 30000
local TargetZ = -49040
local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"

local function collectGoldBars(returnPos)
    local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    local found = false
    for _, item in pairs(goldBarFolder:GetChildren()) do
        if item:IsA("BasePart") then
            found = true
            HumanoidRootPart.CFrame = item.CFrame + Vector3.new(0, -5, 0)
            task.wait(1)
            local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
            if parentModel and parentModel:IsA("Model") then
                storeItemRemote:FireServer(parentModel)
            end
        end
    end
    if found then
        HumanoidRootPart.CFrame = CFrame.new(returnPos)
        task.wait(0.2)
    end
end

local function enableFlying()
    local root = HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    while FLYING and FlightBlock > TargetZ do
        local targetPos = Vector3.new(57, -5, FlightBlock)
        repeat
            local dir = (targetPos - root.Position).Unit
            bv.Velocity = dir * iyflyspeed
            task.wait(0.05)
        until (root.Position - targetPos).Magnitude <= 5
        bv.Velocity = Vector3.new(0, 0, 0)
        local currTarget = targetPos
        collectGoldBars(currTarget)
        FlightBlock = FlightBlock - 2000
        task.wait(0.1)
    end
    FLYING = false
end

enableFlying()
