-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local SliderFrame = Instance.new("Frame")
local SliderBar = Instance.new("Frame")
local SliderHandle = Instance.new("TextButton")
local SpeedDisplay = Instance.new("TextLabel")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0.5, -125, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, 0, 0.2, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Fly Speed"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true

SliderFrame.Parent = Frame
SliderFrame.Size = UDim2.new(0.8, 0, 0.4, 0)
SliderFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

SliderBar.Parent = SliderFrame
SliderBar.Size = UDim2.new(0, 0, 0.6, 0) -- Expands dynamically
SliderBar.Position = UDim2.new(0, 0, 0.2, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Blue fill

SliderHandle.Parent = SliderFrame
SliderHandle.Size = UDim2.new(0, 20, 1, 0)
SliderHandle.Position = UDim2.new(0, -10, 0, 0)
SliderHandle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
SliderHandle.Text = ""

SpeedDisplay.Parent = Frame
SpeedDisplay.Size = UDim2.new(1, 0, 0.2, 0)
SpeedDisplay.Position = UDim2.new(0, 0, 0.8, 0)
SpeedDisplay.BackgroundTransparency = 1
SpeedDisplay.Text = "Speed: 50"
SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplay.TextScaled = true

-- Flight Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

FLYING = true
local iyflyspeed = 50
local minSpeed, maxSpeed = 1, 1000

local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"

local function updateSpeed(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local relativePosition = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        iyflyspeed = math.floor(minSpeed + (maxSpeed - minSpeed) * relativePosition)
        SliderHandle.Position = UDim2.new(relativePosition, -10, 0, 0)
        SliderBar.Size = UDim2.new(relativePosition, 0, 0.6, 0) -- Expands dynamically
        SpeedDisplay.Text = "Speed: " .. iyflyspeed
    end
end

SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local connection
        connection = UserInputService.InputChanged:Connect(updateSpeed)

        UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                connection:Disconnect()
            end
        end)
    end
end)

local function enableFlying()
    local root = HumanoidRootPart
    local camera = workspace.CurrentCamera
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3inf
    bv.Velocity = Vector3.new()

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    RunService.RenderStepped:Connect(function()
        if FLYING then
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)

            if VelocityHandler and GyroHandler then
                GyroHandler.CFrame = camera.CoordinateFrame
                local direction = controlModule:GetMoveVector()

                VelocityHandler.Velocity = 
                    (camera.CFrame.RightVector * direction.X * iyflyspeed) +
                    (-camera.CFrame.LookVector * direction.Z * iyflyspeed)
            end
        end
    end)
end

enableFlying()
