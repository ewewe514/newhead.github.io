local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local range = 50
local autoReloadEnabled = true

local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = range

    for _, enemy in pairs(workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= char then
            local distance = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance and enemy.Humanoid.Health > 0 then
                shortestDistance = distance
                closestEnemy = enemy
            end
        end
    end

    return closestEnemy
end

local function shootAt(target)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local fireEvent = tool:FindFirstChild("Fire") or tool:FindFirstChild("RemoteEvent")
        if fireEvent and fireEvent:IsA("RemoteEvent") then
            fireEvent:FireServer(target.HumanoidRootPart.Position)
        end
    end
end

local function reloadWeapon()
    local reloadEvent = ReplicatedStorage:FindFirstChild("ReloadEvent")
    if reloadEvent then
        reloadEvent:FireServer()
    end
end

local function autoShoot()
    while true do
        wait(0.1)
        local target = getClosestEnemy()
        if target then
            shootAt(target)
            if autoReloadEnabled then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Ammo") and tool.Ammo.Value == 0 then
                    reloadWeapon()
                end
            end
        end
    end
end

task.spawn(autoShoot)

print("[KillAura] Auto KillAura activated!")
