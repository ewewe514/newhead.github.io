local Players = game:GetService("Players")
local player = Players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local aimLockLoop

local function stopAimLock()
    if aimLockLoop then
        aimLockLoop:Disconnect()
        aimLockLoop = nil
    end
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
    end
end

local function startAimLock()
    stopAimLock()

    aimLockLoop = runService.RenderStepped:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

        local closestNPC = nil
        local closestDistance = math.huge

        for _, npc in ipairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc ~= player.Character and not Players:GetPlayerFromCharacter(npc) then
                local humanoid = npc:FindFirstChildOfClass("Humanoid")
                local hrp = npc:FindFirstChild("HumanoidRootPart")

                if humanoid and hrp and humanoid.Health > 0 then
                    local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestNPC = npc
                    end
                end
            end
        end

        if closestNPC then
            camera.CameraSubject = closestNPC:FindFirstChildOfClass("Humanoid")
        else
            camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        end
    end)
end

player.CameraMode = Enum.CameraMode.Classic
startAimLock()

task.delay(5, function()
    stopAimLock()
end)
