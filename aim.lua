local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

FLYING = true
local iyflyspeed = 500 -- Fixed speed

local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local targetZ = -49040 -- Final destination along Z-axis
local startPosition = Vector3.new(57, -3, 30000)
HumanoidRootPart.Position = startPosition -- Set initial position

local function enableFlying()
    local root = HumanoidRootPart

    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, -iyflyspeed) -- Move along negative Z-axis

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 1000
    bg.D = 50
    bg.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(0, 0, -1)) -- Keep orientation forward

    -- Start gold collection while flying
    task.spawn(function()
        while FLYING do
            local storeItemRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StoreItem")
            local goldBarFolder = workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")

            for _, item in pairs(goldBarFolder:GetChildren()) do
                if item:IsA("BasePart") then
                    -- Teleport 3 blocks under the GoldBar
                    root.CFrame = item.CFrame + Vector3.new(0, -3, 0)
                    task.wait(1) -- Wait 1 second for collection

                    local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                    if parentModel and parentModel:IsA("Model") then
                        local args = { parentModel }
                        storeItemRemote:FireServer(unpack(args))
                    end

                    -- Return to original flight position after collecting
                    root.Position = Vector3.new(root.Position.X, -3, root.Position.Z)
                end
            end

            task.wait(0.5) -- Short delay before scanning again
        end
    end)

    -- Stop flight when reaching target Z coordinate
    RunService.RenderStepped:Connect(function()
        if FLYING and root.Position.Z <= targetZ then
            bv.Velocity = Vector3.new(0, 0, 0) -- Stop movement
            FLYING = false
        end
    end)
end

enableFlying() -- Flight automatically starts when script is executed
