local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera  = Workspace.CurrentCamera
local WeaponController = ReplicatedStorage:FindFirstChild("WeaponController",true)
if WeaponController == nil then return end

function GetWeapon()
local Found = nil
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("ServerWeaponState",true) then
local Weapon = LocalPlayer.Character:FindFirstChild("ServerWeaponState",true)
if Weapon.Parent:IsA("Tool") then
Found = Weapon.Parent
end
end
if Found == nil then
if LocalPlayer:FindFirstChild("Backpack") then
for i, v in pairs(LocalPlayer:FindFirstChild("Backpack"):GetChildren()) do
if v:IsA("Tool") and v:FindFirstChild("ServerWeaponState") then
Found = v
break
end
end
end
end
return Found
end

function FireBullet()
if LocalPlayer.Character then
local WeaponTarget = GetWeapon()
if WeaponTarget == nil then return end
if WeaponTarget.Parent ~= LocalPlayer.Character then
WeaponTarget.Parent = LocalPlayer.Character
end
require(WeaponController).FireBullet(WeaponTarget)
end
end

function FindEvilNPC()
local Found = nil
for i, v in pairs(Workspace:GetDescendants()) do
if v:GetAttribute("DangerScore") and v:FindFirstChildOfClass("Humanoid") then
if LocalPlayer:DistanceFromCharacter(v:GetPivot().Position) <= 30 then
Found = v
break
end
end
end
return Found
end

RunService.RenderStepped:Connect(function()
local CameraPosition  = Camera.CFrame.Position
local Target = FindEvilNPC()
if Target ~= nil then
local Head = Target:FindFirstChild("Head")
if Head and Target:FindFirstChildOfClass("Humanoid") and Target:FindFirstChildOfClass("Humanoid").Health ~= 0 then
Camera.CFrame = CFrame.lookAt(CameraPosition, Head.Position)
task.wait()
FireBullet()
end
end
end)
