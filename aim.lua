-- Kill Aura Variables
local auraOn = true
local killDist = 100

-- Helper Functions
local function isNPC(obj)
    return obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid")
        and obj.Humanoid.Health > 0
        and obj:FindFirstChild("Head")
        and obj:FindFirstChild("HumanoidRootPart")
        and not game:GetService("Players"):GetPlayerFromCharacter(obj)
end

local function getNearestNPC()
    local plr = game:GetService("Players").LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end -- Prevent nil indexing

    local nearest, minDist = nil, math.huge
    for _, npc in ipairs(workspace:GetDescendants()) do
        if isNPC(npc) then
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            local hum = npc:FindFirstChild("Humanoid")
            local dist = (hrp.Position - root.Position).Magnitude
            if hum and hum.Health > 0 and dist < minDist and dist <= killDist then
                nearest, minDist = npc, dist
            end
        end
    end
    return nearest
end

local function shootRemote(npc)
    if not npc then return end
    local head = npc:FindFirstChild("Head")
    if not head then return end

    local shootRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Weapon"):WaitForChild("Shoot")
    if shootRemote then
        local args = {head.Position} -- Firing at head position
        shootRemote:FireServer(unpack(args))
        print("Shot fired at:", head.Position) -- Debugging confirmation
    end
end

local function killAuraLoop()
    while auraOn do
        local target = getNearestNPC()
        if target then
            print("Target found:", target.Name) -- Debugging output
            shootRemote(target)
        else
            print("No valid NPC found") -- Debugging output
        end
        task.wait(0.2)
    end
end

-- Main Loop (Prevents nil indexing)
RunService.Heartbeat:Connect(function()
    if auraOn then
        pcall(killAuraLoop) -- Ensures no errors crash the script
    end
end)
