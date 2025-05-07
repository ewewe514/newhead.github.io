local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShootRemote  = ReplicatedStorage.Remotes.Weapon.Shoot
local ReloadRemote = ReplicatedStorage.Remotes.Weapon.Reload

local Players = game:GetService("Players")
local workspace = game.Workspace

-- Configuration
local AutoHeadshotEnabled = true   
local AutoReloadEnabled   = true   
local SEARCH_RADIUS       = 350   
local SHOOT_RADIUS        = 200  -- Reduced to prevent random firing

local SupportedWeapons = {
    "Revolver",
    "Rifle",
    "Sawed-Off Shotgun",
    "Shotgun"
}

local function isPlayerModel(m)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then
            return true
        end
    end
    return false
end

local function getEquippedSupportedWeapon()
    local char = Players.LocalPlayer and Players.LocalPlayer.Character
    if not char then return nil end
    for _, name in ipairs(SupportedWeapons) do
        local tool = char:FindFirstChild(name)
        if tool then
            return tool
        end
    end
    return nil
end

local function findClosestNPC()
    local closestNPC = nil
    local closestDistance = SEARCH_RADIUS
    local playerChar = Players.LocalPlayer.Character
    if not playerChar then return nil end

    local playerPosition = playerChar:GetPivot().Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not isPlayerModel(obj) and obj.Name:match("Model_") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local head = obj:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local npcPosition = obj:GetPivot().Position
                local dist = (npcPosition - playerPosition).Magnitude
                
                if dist <= SEARCH_RADIUS and dist < closestDistance then
                    closestDistance = dist
                    closestNPC = {model = obj, hum = hum, head = head, distance = dist}
                end
            end
        end
    end
    
    if closestNPC then
        print("Target Found:", closestNPC.model.Name, "Distance:", closestNPC.distance)
    else
        print("No valid NPC found!")
    end

    return closestNPC
end

local function autoHeadshotLoop()
    while AutoHeadshotEnabled do
        local tool = getEquippedSupportedWeapon()
        local closestNPC = findClosestNPC()

        if tool and closestNPC and closestNPC.head and closestNPC.distance <= SHOOT_RADIUS then
            local pelletTable = {}

            if tool.Name == "Shotgun" or tool.Name == "Sawed-Off Shotgun" then
                for i = 1, 6 do
                    pelletTable[tostring(i)] = closestNPC.hum
                end
            else
                pelletTable["1"] = closestNPC.hum
            end

            -- Shoot directly at NPC's head
            ShootRemote:FireServer(
                workspace:GetServerTimeNow(),
                tool,
                closestNPC.head.CFrame, -- Ensures precise targeting
                pelletTable
            )

            -- Auto reload
            if AutoReloadEnabled then
                ReloadRemote:FireServer(workspace:GetServerTimeNow(), tool)
            end

            print("Shot fired at:", closestNPC.model.Name)
        else
            print("No valid target found, NOT shooting!") -- Prevents unnecessary firing
        end

        task.wait(0.05)
    end
end

task.spawn(autoHeadshotLoop)
