----------------------------------
-- Services and Variable Setup
----------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = Character:WaitForChild("HumanoidRootPart")

-- Set the initial flight position: (57, -5, 30000)
hrp.CFrame = CFrame.new(57, -5, 30000)

----------------------------------
-- Flight Configuration
----------------------------------
local FLYING = true
local iyflyspeed = 500            -- Flight speed in studs/second
local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local v3inf = Vector3.new(9e9, 9e9, 9e9)
local endZ = -49000              -- End flight at Z = -49000

-- Get the Control Module for movement input.
local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

-- Create BodyVelocity for movement.
local bv = Instance.new("BodyVelocity")
bv.Name = velocityHandlerName
bv.MaxForce = v3inf
bv.Velocity = Vector3.new()  -- Will be updated each frame.
bv.Parent = hrp

-- Create BodyGyro for smooth rotation.
local bg = Instance.new("BodyGyro")
bg.Name = gyroHandlerName
bg.MaxTorque = v3inf
bg.P = 1000
bg.D = 50
bg.Parent = hrp

-- Flight Loop: Uses player input if available; otherwise, defaults to moving along negative Z.
RunService.RenderStepped:Connect(function()
    if FLYING and hrp and hrp.Parent then
        local camera = Workspace.CurrentCamera
        bg.CFrame = camera.CFrame
        local moveVec = controlModule:GetMoveVector()
        -- If no input is detected, default to moving along negative Z.
        if moveVec.Magnitude < 0.1 then
            moveVec = Vector3.new(0, 0, -1)
        end
        bv.Velocity = (camera.CFrame.RightVector * moveVec.X * iyflyspeed) + (-camera.CFrame.LookVector * moveVec.Z * iyflyspeed)
        
        -- Stop flight when reaching destination.
        if hrp.Position.Z <= endZ then
            bv:Destroy()
            FLYING = false
            print("Reached destination at Z:", hrp.Position.Z)
        end
    end
end)

----------------------------------
-- Gold Bar Collection Loop
----------------------------------
task.spawn(function()
    local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")
    
    while true do
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        
        for _, item in pairs(goldBarFolder:GetChildren()) do
            if item:IsA("BasePart") then
                -- Save the current flight CFrame.
                local savedCFrame = hrp.CFrame

                -- Teleport to below the gold bar: use its X and Z;
                -- set Y to the gold bar's Y minus 5.
                local targetPos = Vector3.new(item.Position.X, item.Position.Y - 5, item.Position.Z)
                hrp.CFrame = CFrame.new(targetPos)
                task.wait(0.9)  -- Wait to ensure physics and network consistency.

                -- Retrieve the parent model for the gold bar.
                local parentModel = item:FindFirstAncestorOfClass("Model") or item.Parent
                if parentModel and parentModel:IsA("Model") then
                    storeItemRemote:FireServer(parentModel)
                    print("Gold bar stored:", parentModel.Name)
                end

                task.wait(0.5)  -- Short delay after collection.
                -- Return to the previously saved flight position.
                hrp.CFrame = savedCFrame
            end
        end

        task.wait(0.5)  -- Brief pause before scanning for new gold bars.
    end
end)
