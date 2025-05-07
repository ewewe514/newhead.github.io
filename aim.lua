-- Kill Aura Variables
local auraOn = false
local killDist = 100

-- Helper Functions
local function isNPC(obj)
    return obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid")
        and obj.Humanoid.Health > 0
        and obj:FindFirstChild("Head")
        and obj:FindFirstChild("HumanoidRootPart")
        and not Players:GetPlayerFromCharacter(obj)
end

local function getNearestNPC()
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local nearest, minDist = nil, math.huge
    for _, npc in ipairs(workspace:GetDescendants()) do
        if isNPC(npc) then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChild("Humanoid")
            local dist = (hrp.Position - root.Position).Magnitude
            if hum.Health > 0 and dist < minDist and dist <= killDist then
                nearest, minDist = npc, dist
            end
        end
    end
    return nearest
end

local function shootRemote(npc)
    if not npc then return end
    local hum = npc:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return end

    local shootRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Weapon"):WaitForChild("Shoot")
    if shootRemote then
        local head = npc:FindFirstChild("Head")
        if head then
            local args = {head.Position} -- Only sending the head position now
            shootRemote:FireServer(unpack(args))
        end
    end
end

local function killAuraLoop()
    while auraOn do
        local target = getNearestNPC()
        if target then shootRemote(target) end
        task.wait(0.2)
    end
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    if auraOn then
        killAuraLoop()
    end
end)
