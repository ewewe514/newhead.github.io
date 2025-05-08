local noclipConnection

local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        local player = game.Players.LocalPlayer
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

task.spawn(function()
    wait(5) -- Waits 5 seconds before activating noclip
    enableNoclip() -- Calls the function to enable noclip
end)




task.spawn(function()
    wait(10)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/fjruie/bypass.github.io/refs/heads/main/ringta.lua"))()
end)

task.spawn(function()
    wait(16)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ewewe514/flying.github.io/refs/heads/main/erer.lua"))()
end)

task.spawn(function()
    wait(22)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Target position
    local targetPosition = Vector3.new(-352.05, -6.16, -49041.93)

    -- Teleport
    rootPart.CFrame = CFrame.new(targetPosition)
end)

task.spawn(function()
    wait(60) -- Waits 1 minute
    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Set camera to first-person and force it to look directly up
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(math.rad(90), 0, 0) -- Looks straight up

    -- Continuously spin while maintaining upward view
    while true do
        camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(25), 0) -- Spins while locked on sky
        wait(0.05) -- Adjust speed for smoother rotation
    end
end)


task.spawn(function()
    wait(480) -- Waits 8 minutes (480 seconds)
    local prompt = workspace.Baseplates.FinalBasePlate.OutlawBase.Bridge.BridgeControl.Crank.Model.Mid.EndGame
    prompt.HoldDuration = 0
    
    while true do
        fireproximityprompt(prompt)
        wait(5) -- Runs every 5 seconds
    end
end)
