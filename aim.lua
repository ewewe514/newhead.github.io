local player = game.Players.LocalPlayer
if not player then
    warn("LocalPlayer is nil! Make sure this is running in a LocalScript.")
    return
end

local character = player.Character or player.CharacterAdded:Wait()

-- Function to safely load scripts
local function safeLoadstring(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Failed to load script from: " .. url)
    end
end

-- Teleportation function
local function teleportPlayer(position)
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
    else
        warn("HumanoidRootPart not found!")
    end
end

-- Fire all ProximityPrompts repeatedly for a set duration
local function activatePromptsForDuration(duration)
    local startTime = tick()
    while tick() - startTime < duration do
        if fireproximityprompt then
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(descendant)
                    end)
                end
            end
        end
        task.wait(0.1) -- Slight delay to prevent performance issues
    end
end

-- Schedule tasks
task.spawn(function()
    task.wait(15)
    safeLoadstring("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua")
end)

task.spawn(function()
    task.wait(25)
    safeLoadstring("https://raw.githubusercontent.com/ringtaa/fly.github.io/refs/heads/main/fly.lua")
end)

task.spawn(function()
    task.wait(30)
    teleportPlayer(Vector3.new(3, 100, 30000))
end)

task.spawn(function()
    task.wait(600)
    teleportPlayer(Vector3.new(-351.34, 3, -49042.71))
end)

task.spawn(function()
    task.wait(601)
    activatePromptsForDuration(5) -- Keeps firing prompts for 5 seconds
end)

task.spawn(function()
    task.wait(606)
    teleportPlayer(Vector3.new(3, 101, 30000))
end)
