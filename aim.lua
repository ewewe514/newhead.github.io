autoCollectRunning = true

local function collectItems()
    if not workspace:FindFirstChild("RuntimeItems") then return end

    local items = {
        workspace.RuntimeItems:FindFirstChild("Rifle"),
        workspace.RuntimeItems:FindFirstChild("RifleAmmo"),
        workspace.RuntimeItems:FindFirstChild("Bandage"),
        workspace.RuntimeItems:FindFirstChild("Shotgun"),
        workspace.RuntimeItems:FindFirstChild("Revolver"),
        workspace.RuntimeItems:FindFirstChild("ShotgunShells"),
        workspace.RuntimeItems:FindFirstChild("Molotov"),
        workspace.RuntimeItems:FindFirstChild("RevolverAmmo"),
        workspace.RuntimeItems:FindFirstChild("Mauser"),
        workspace.RuntimeItems:FindFirstChild("Snake Oil"),
        workspace.RuntimeItems:FindFirstChild("Shovel"),
        workspace.RuntimeItems:FindFirstChild("OpenableCrate"),
        workspace.RuntimeItems:FindFirstChild("Navy Revolver"),
        workspace.RuntimeItems:FindFirstChild("Bolt Action Rifle"),
        workspace.RuntimeItems:FindFirstChild("Holy Water"),
        workspace.RuntimeItems:FindFirstChild("Electrocutioner"),
        workspace.RuntimeItems:FindFirstChild("Vampire Knife")
    }

    local rs = game:GetService("ReplicatedStorage")

    local activateRemote = rs:WaitForChild("Packages"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_ActivateObject")

    if not activateRemote then return end

    for _, item in pairs(items) do
        if item then
            local args = { item }
            activateRemote:FireServer(unpack(args))
        end
    end
end

task.spawn(function()
    while autoCollectRunning do
        task.wait(0.4)
        pcall(collectItems)
    end
end)
