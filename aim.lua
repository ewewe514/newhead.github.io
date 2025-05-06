-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local workspace = game.Workspace

local ShootRemote = ReplicatedStorage.Remotes.Weapon.Shoot
local ReloadRemote = ReplicatedStorage.Remotes.Weapon.Reload

-- Configuration
local AutoHeadshotEnabled = true   
local AutoReloadEnabled   = true   
local SEARCH_RADIUS       = 350  -- Detect NPCs within 350 studs
local SHOOT_RADIUS        = 300  -- Increased auto-shoot range

local SupportedWeapons = {
    "Revolver",
    "Rifle",
    "Sawed-Off Shotgun",
    "Shotgun"
}

-- Function to check if a model is a valid NPC
local function isValidNPC(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    local head = model:FindFirstChild("Head")
    return hum and head and hum.Health > 0 -- Must have Humanoid & Head, and be alive
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

-- Function to find the closest valid NPC
local function findClosestNPC()
    local closestNPC = nil
    local closestDistance = SEARCH_RADIUS
    local playerChar = Players.LocalPlayer.Character
    if not playerChar then return nil end

    local playerPosition = playerChar:GetPivot().Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and isValidNPC(obj) then
            local npcPosition = obj:GetPivot().Position
            local dist = (npcPosition - playerPosition).Magnitude
            
            if dist <= SEARCH_RADIUS and dist < closestDistance then
                closestDistance = dist
                closestNPC = {model = obj, hum = obj:FindFirstChildOfClass("Humanoid"), head = obj:FindFirstChild("Head"), distance = dist}
            end
        end
    end
    return closestNPC
end

-- Function for auto-headshots with proper target validation
local function autoHeadshotLoop()
    while AutoHeadshotEnabled do
        local tool = getEquippedSupportedWeapon() -- Get the equipped weapon
        local closestNPC = findClosestNPC()

        -- Ensure a valid NPC exists before shooting
        if tool and closestNPC and closestNPC.head and closestNPC.distance <= SHOOT_RADIUS then
            local pelletTable = {}

            -- Ensure shotgun types fire multiple pellets
            if tool.Name == "Shotgun" or tool.Name == "Sawed-Off Shotgun" then
                for i = 1, 6 do
                    pelletTable[tostring(i)] = closestNPC.hum
                end
            else
                pelletTable["1"] = closestNPC.hum
            end

            -- Fire at NPC's head
            ShootRemote:FireServer(
                workspace:GetServerTimeNow(),
                tool,
                closestNPC.head.CFrame, -- Ensures precise head targeting
                pelletTable
            )

            -- **Auto Reload**
            if AutoReloadEnabled then
                ReloadRemote:FireServer(workspace:GetServerTimeNow(), tool)
            end
        else
            print("No valid target found, NOT shooting!") -- Prevents unnecessary firing
        end

        task.wait(0.05) -- Prevents crashes while maintaining high fire rate
    end
end

task.spawn(autoHeadshotLoop)
