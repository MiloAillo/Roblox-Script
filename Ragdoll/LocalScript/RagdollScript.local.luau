-- ======== Easy Tweak ========
local Ragdoll_Key = Enum.KeyCode.G

-- ======== Services ==========
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- ========== variables =========
local IsRagdollEvent: RemoteEvent = ReplicatedStorage:FindFirstChild("IsRagdollEvent")
local plr = Players.LocalPlayer

-- ======== keyboard event ========
InputService.InputBegan:Connect(function(e) 
    if e.KeyCode == Ragdoll_Key then
        IsRagdollEvent:FireServer()
    end
end)

-- force the server to un-ragdolled and update this char health to 0.
-- nope you cant remove this and expect the character to be immortal.
-- the server still know that this character is dead, this code just kick the server to update. 
-- removing this will break the character behaviour!
plr.CharacterAdded:Connect(function(char) 
    char:FindFirstChild("Humanoid").Died:Connect(function()
        task.wait(Players.RespawnTime)
        IsRagdollEvent:FireServer()
    end)
end)