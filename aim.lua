local positions = {
    Vector3.new(57, -5, 21959),
    Vector3.new(57, -5, 13973),
    Vector3.new(57, -5, 6025),
    Vector3.new(57, -5, -9000),
    Vector3.new(57, -5, -25870),
    Vector3.new(57, -5, -33844)
}

local MIN_SETTLE_WAIT = 0.4   -- How long to wait after teleporting (to let physics settle)
local REMOTE_DELAY   = 0.4    -- Delay between firing the store remote

-----------------------------------------------------------------------
-- SERVICES & REFERENCES
-----------------------------------------------------------------------

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local storeItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreItem")

-- Sack check: the TextLabel inside Backpack.Sack.BillboardGui should show "10/10" when full.
local function isSackFull()
    -- Ensure the Sack exists and its TextLabel is accessible.
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local sack = backpack:FindFirstChild("Sack")
        if sack and sack:FindFirstChild("BillboardGui") then
            local label = sack.BillboardGui:FindFirstChild("TextLabel")
            if label and label.Text == "10/10" then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------
-- HELPER FUNCTION: Safe Teleport
-----------------------------------------------------------------------

local function safeTeleport(pos)
    pcall(function()
        hrp.CFrame = CFrame.new(pos)
    end)
end

-----------------------------------------------------------------------
-- MAIN LOOP
-----------------------------------------------------------------------

-- processedGoldBars keeps track of those already handled so we don’t try them again.
local processedGoldBars = {}

-- Run forever until the Sack is full.
while not isSackFull() do
    -- Cycle through each waypoint in our list.
    for _, waypoint in ipairs(positions) do
        if isSackFull() then break end

        -- Teleport to the waypoint.
        safeTeleport(waypoint)
        wait(0.5)  -- Give time to settle.

        -- Get the folder of gold bars (assumed to be continuously updated).
        local goldBarFolder = Workspace:WaitForChild("RuntimeItems"):WaitForChild("GoldBar")
        
        -- Process ALL gold bars at this waypoint.
        local goldFound = true
        while goldFound and not isSackFull() do
            goldFound = false  -- reset; we will set to true if we process any gold bar in this pass.
            for _, goldBar in ipairs(goldBarFolder:GetChildren()) do
                if goldBar:IsA("BasePart") and (not processedGoldBars[goldBar]) then
                    goldFound = true
                    processedGoldBars[goldBar] = true  -- Mark this gold bar as processed.

                    local savedPosition = waypoint  -- Save current waypoint position.

                    -- Teleport 5 studs BELOW the gold bar.
                    safeTeleport(goldBar.CFrame.p + Vector3.new(0, -5, 0))
                    wait(MIN_SETTLE_WAIT)  -- Wait for settling
                  
                    local parentModel = goldBar:FindFirstAncestorOfClass("Model") or goldBar.Parent
                    if parentModel and parentModel:IsA("Model") then
                        -- Fire the remote repeatedly until the gold bar is removed.
                        while goldBar.Parent and not isSackFull() do
                            storeItemRemote:FireServer(parentModel)
                            wait(REMOTE_DELAY)
                        end
                    end

                    -- Return to the waypoint after processing this gold bar.
                    safeTeleport(savedPosition)
                    wait(0.2)
                end
                if isSackFull() then
                    break
                end
            end
            -- Wait a short moment before scanning for more gold bars at this location.
            wait(0.3)
        end

        -- After processing gold at this waypoint, wait a bit then move to the next.
        wait(0.5)
        
        if isSackFull() then break end
    end
    wait(0.2)  -- Brief pause before repeating the full cycle.
end

print("Sack is full (10/10); script ending.")
