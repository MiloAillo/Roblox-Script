-- ========== Object Creation Zone ============
local Ragdoll = {}
Ragdoll.__index = Ragdoll

function Ragdoll.new(char)
    local self = setmetatable({}, Ragdoll)
    
    self.char = char
    self.hum = char:WaitForChild("Humanoid")
    self.hrp = char:WaitForChild("HumanoidRootPart")

    return self
end

function Ragdoll:SetupChar()
    self.hum.BreakJointsOnDeath = false
    self.hum.RequiresNeck = false
end

function Ragdoll:EnableDefaultMotor6D(state: boolean)
    local torsoChild = self.char:FindFirstChild("Torso"):GetChildren()

    for _, object in torsoChild do
        if not object:IsA("Motor6D") then continue end
        object.Enabled = state
    end
end 

-- ====== Instantiation Zone ===========

local ragdoll = Ragdoll.new(script.Parent)
ragdoll:SetupChar()
ragdoll:EnableDefaultMotor6D(false)