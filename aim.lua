local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

FLYING = true
local iyflyspeed = 500
local FirstBlock = 30000
local TargetZ = -49040
local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"

local function collectGoldBars(returnPos)
    local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
    local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
    for _, item in pairs(goldBarFolder:GetChildren()) do
        if item:IsA("BasePart") then
            HumanoidRootPart.CFrame = item.CFrame + Vector3.new(0, -3, 0)
            task.wait(1)
            local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
            if parentModel and parentModel:IsA("Model") then
                storeItemRemote:FireServer(parentModel)
            end
        end
    end
    HumanoidRootPart.CFrame = CFrame.new(returnPos)
    task.wait(0.2)
end

local function enableFlying()
    local root = HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new()
    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    task.spawn(function()
        while FLYING and FirstBlock > TargetZ do
            local targetPosition = Vector3.new(57, -3, FirstBlock)
            while (root.Position - targetPosition).Magnitude > 5 do
                local direction = (targetPosition - root.Position).Unit
                bv.Velocity = direction * iyflyspeed
                task.wait(0.05)
            end
            bv.Velocity = Vector3.new(0, 0, 0)
            local flightReturnPos = Vector3.new(57, -3, FirstBlock)
            collectGoldBars(flightReturnPos)
            task.wait(1)
            FirstBlock = FirstBlock - 2000 
        end
        FLYING = false
    end)
end

enableFlying()
