
-- KillAura Avançado para Dead Rails
-- Autor: beabadoobee 💀
-- Atualizado: Maio de 2025

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local range = 50 -- Distância máxima para detectar inimigos
local enabled = false -- Flag de controle do KillAura
local autoReloadEnabled = true -- Auto reload ativado
local moveSpeed = 0 -- Controle de movimento, de 0 a 100%

-- Função para encontrar o inimigo mais próximo
local function getClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = range

    for _, enemy in pairs(workspace:GetDescendants()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= char then
            local distance = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance and enemy.Humanoid.Health > 0 then
                shortestDistance = distance
                closestEnemy = enemy
            end
        end
    end

    return closestEnemy
end

-- Função para atirar no inimigo
local function shootAt(target)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local fireEvent = tool:FindFirstChild("Fire") or tool:FindFirstChild("RemoteEvent")
        if fireEvent and fireEvent:IsA("RemoteEvent") then
            -- Aciona o disparo no servidor com a posição do inimigo
            fireEvent:FireServer(target.HumanoidRootPart.Position)
        end
    end
end

-- Função para recarregar a arma
local function reloadWeapon()
    local reloadEvent = ReplicatedStorage:WaitForChild("ReloadEvent")
    if reloadEvent then
        reloadEvent:FireServer() -- Usa o evento de recarga do servidor
    end
end

-- Função de disparo automático
local function autoShoot()
    while enabled do
        wait(0.1)
        local target = getClosestEnemy()
        if target then
            shootAt(target)
            -- Verifica se a munição acabou e recarrega se o auto-reload estiver ativado
            if autoReloadEnabled then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Ammo") and tool.Ammo.Value == 0 then
                    reloadWeapon()
                end
            end
        end
    end
end

-- Função para alternar o KillAura
local function toggleKillAura()
    enabled = not enabled
    if enabled then
        -- Iniciar o disparo automático
        spawn(autoShoot)
    end
end

-- Função para ajustar a velocidade de movimento
local function setMoveSpeed()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = moveSpeed
    end
end

-- Função para esconder o script
local function hideScript()
    game:GetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui"):Destroy()
end

-- Detecta pressionamento do "Control Esquerdo" para esconder/exibir o script
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.LeftControl then
            toggleKillAura() -- Alterna o estado do KillAura ao pressionar "Control"
        end
        if input.KeyCode == Enum.KeyCode.F1 then
            hideScript() -- F1 para destruir o GUI (fechar o script)
        end
    end
end)

-- Detecta o movimento do slider para ajustar a velocidade de movimento
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        -- A cada movimento do mouse, ajusta a velocidade do personagem
        -- Por enquanto, só uma ideia básica de ajuste com base no mouse
        local targetSpeed = math.clamp(input.Position.X / 10, 0, 100)
        moveSpeed = targetSpeed
        setMoveSpeed()
    end
end)

-- Print de ativação
print("[KillAura] Script ativado com sucesso - feito por beabadoobee 💀")
