loadstring(game:HttpGet("https://raw.githubusercontent.com/Nasrali11448/FaxvKM/refs/heads/main/Cheat"))()

    local player = game:GetService("Players").LocalPlayer
    local gui, button

    for _, child in ipairs(player:WaitForChild("PlayerGui"):GetChildren()) do
        local success, frame = pcall(function()
            return child:FindFirstChild("Frame")
        end)
        if success and frame and frame:FindFirstChildWhichIsA("TextButton") then
            gui = child
            button = frame:FindFirstChildWhichIsA("TextButton")
            break
        end
    end

    if gui and button then
        gui.Enabled = false
        task.wait(1)
        pcall(function()
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
            end
        end)
    end

    wait(3)

    local Crank_Cooldown = 600
    local Crank_StartTime = tick() - workspace.DistributedGameTime
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local gui2 = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui2.Name = "CooldownTimer"

    local label = Instance.new("TextLabel", gui2)
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(1, -210, 0, 10)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true

    task.spawn(function()
        local timePassed = tick() - Crank_StartTime
        local timeLeft = math.max(0, Crank_Cooldown - timePassed)

        if timeLeft > 0 and hrp then
        wait(1)
            hrp.CFrame = CFrame.new(-338, 3, -49045)
        end

        while true do
            timePassed = tick() - Crank_StartTime
            timeLeft = math.max(0, Crank_Cooldown - timePassed)
            local minutes = math.floor(timeLeft / 60)
            local seconds = math.floor(timeLeft % 60)

            if timeLeft <= 0 then
                label.Text = "Ready"
                task.wait(2)
                gui2:Destroy()

                if hrp then
                    hrp.CFrame = CFrame.new(-338, 3, -49045)
                end
                wait(1)

                if fireproximityprompt then
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            pcall(function()
                                fireproximityprompt(descendant)
                            end)
                        end
                    end
                end
                break
            else
                label.Text = string.format("%02d:%02d", minutes, seconds)
            end

            task.wait(1)
        end
    end)
