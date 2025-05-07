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
    local pickUpRemote = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Tool") and rs.Remotes.Tool:FindFirstChild("PickUpTool")
    local activateRemote = rs:FindFirstChild("Packages") and rs.Packages:FindFirstChild("RemotePromise") and rs.Packages.RemotePromise.Remotes:FindFirstChild("C_ActivateObject")

    if not pickUpRemote or not activateRemote then return end

    for _, item in pairs(items) do
        if item then
            local args = { item }
            pickUpRemote:FireServer(unpack(args))
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
