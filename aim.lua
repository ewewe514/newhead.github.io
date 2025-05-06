-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local workspace = game.Workspace

local ShootRemote = ReplicatedStorage.Remotes.Weapon.Shoot

-- Configuration
local AutoHeadshotEnabled = true   
local SEARCH_RADIUS = 350  -- Detect NPCs within 350 studs
local SHOOT_RADIUS = 300   -- Increased auto-shoot range

local SupportedWeapons = {
    "Revolver",
    "Rifle",
    "Sawed-Off Shotgun",
    "Shotgun"
}

-- Function to check if a model is a player
local function isPlayerModel(m)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then return true end
    end
    return false
end

-- Function to get the equipped weapon
local function getEquippedSupportedWeapon()
    local char = Players.LocalPlayer and Players.LocalPlayer.Character
    if not char then return nil end
    for _, name in ipairs(SupportedWeapons) do
        local tool = char:FindFirstChild(name)
        if tool then return tool end
    end
    return nil
end

-- Function to find the closest NPC
local function findClosestNPC()
    local closestNPC = nil
    local closestDistance = SEARCH_RADIUS
    local playerChar = Players.LocalPlayer.Character
    if not playerChar then return nil end

    local playerPosition = playerChar:GetPivot().Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not isPlayerModel(obj) then
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
    return closestNPC
end

-- Function for auto-headshots
local function autoHeadshotLoop()
    while AutoHeadshotEnabled do
        local tool = getEquippedSupportedWeapon()
        if tool then
            local closestNPC = findClosestNPC()
            if closestNPC and closestNPC.distance <= SHOOT_RADIUS then
                local pelletTable = {}

                -- Use built-in head targeting
                local headCFrame = closestNPC.head.CFrame

                if tool.Name == "Shotgun" or tool.Name == "Sawed-Off Shotgun" then
                    for i = 1, 6 do
                        pelletTable[tostring(i)] = closestNPC.hum
                    end
                else
                    pelletTable["1"] = closestNPC.hum
                end

                -- Fire directly at head position
                ShootRemote:FireServer(
                    workspace:GetServerTimeNow(),
                    tool,
                    headCFrame, -- Ensures precise head targeting
                    pelletTable
                )
            end
        end
        task.wait(0.05) -- Prevents crashes while keeping high fire rate
    end
end

task.spawn(autoHeadshotLoop)
