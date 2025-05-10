local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = Character:WaitForChild("HumanoidRootPart")

local x, y = 57, -5
local startZ, endZ, stepZ = 30000, -49032.99, 0
hrp.CFrame = CFrame.new(x, y, startZ)

local FLYING = true
local iyflyspeed = 500
local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
local v3inf = Vector3.new(9e9, 9e9, 9e9)
local bv = Instance.new("BodyVelocity")
bv.Name = "VelocityHandler"
bv.MaxForce = v3inf
bv.Velocity = Vector3.new()
bv.Parent = hrp

local bg = Instance.new("BodyGyro")
bg.Name = "GyroHandler"
bg.MaxTorque = v3inf
bg.P = 1000
bg.D = 50
bg.Parent = hrp

RunService.RenderStepped:Connect(function()
    if FLYING and hrp and hrp.Parent then
        local camera = Workspace.CurrentCamera
        bg.CFrame = camera.CFrame
        local moveVec = controlModule:GetMoveVector()
        if moveVec.Magnitude < 0.1 then
            moveVec = Vector3.new(0, 0, -1)
        end
        bv.Velocity = (camera.CFrame.RightVector * moveVec.X * iyflyspeed) + (-camera.CFrame.LookVector * moveVec.Z * iyflyspeed)
        if hrp.Position.Z <= endZ then
            bv:Destroy()
            FLYING = false
        end
    end
end)

task.spawn(function()
    local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
    while true do
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        for _, item in pairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") and item.Parent then
                local savedCFrame = hrp.CFrame
                hrp.CFrame = CFrame.new(item.Position.X, item.Position.Y - 5, item.Position.Z)
                task.wait(0.9)
                local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                if parentModel and parentModel:IsA("Model") then
                    local maxAttempts = 10
                    for i = 1, maxAttempts do
                        if not (item and item.Parent and item:IsDescendantOf(goldBarFolder)) then
                            break
                        end
                        storeItemRemote:FireServer(parentModel)
                        task.wait(0.4)
                    end
                end
                task.wait(0.5)
                hrp.CFrame = savedCFrame
            end
        end
        task.wait(0.5)
    end
end)
