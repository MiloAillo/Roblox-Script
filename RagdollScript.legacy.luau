-- ========= Collison Group ==============
local PhysicsService = game:GetService("PhysicsService")

pcall(function()
	PhysicsService:RegisterCollisionGroup("Body")
	PhysicsService:RegisterCollisionGroup("CollisionPart")

	PhysicsService:CollisionGroupSetCollidable("Body", "CollisionPart", false)
end)

-- ========== Object Creation Zone ============
local Ragdoll = {}
Ragdoll.__index = Ragdoll

function Ragdoll.new(char)
	local self = setmetatable({}, Ragdoll)

	self.char = char
	self.hum = char:WaitForChild("Humanoid")
	self.hrp = char:WaitForChild("HumanoidRootPart")
	self.attachments = {}

	return self
end

function Ragdoll:SetupChar()
	self.hum.BreakJointsOnDeath = false
	self.hum.RequiresNeck = false
end

function Ragdoll:SetGroupCollision()

end

function Ragdoll:EnableDefaultMotor6D(state: boolean)
	local torsoChild = self.char:FindFirstChild("Torso"):GetChildren()

	for _, object in torsoChild do
		if not object:IsA("Motor6D") then continue end
		object.Enabled = state
	end
end

function Ragdoll:MakeAttachment(name, cframe, parent)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.CFrame = cframe
	attachment.Parent = parent

	return attachment
end

function Ragdoll:MakeWeld(name, obj1, obj2, parent)
	local weld = Instance.new("Weld")
	weld.Name = name
	weld.Part0 = obj1
	weld.Part1 = obj2
	weld.Parent = parent

	return weld
end 

function Ragdoll:MakeBallSocket(name, obj1, obj2, parent)
	local ballSocket = Instance.new("BallSocketConstraint")
	ballSocket.Attachment0 = obj1
	ballSocket.Attachment1 = obj2
	ballSocket.Name = name
	ballSocket.Parent = parent

	return ballSocket
end

function Ragdoll:SetBodyCollision()
	for _, object: BasePart in self.char:GetChildren() do
		if not object:IsA("BasePart") or object.Name == "HumanoidRootPart" then continue end

		local smallingValue = 0.8
		local collPart: BasePart = object:Clone()
		collPart.Size = Vector3.new(object.Size.X * smallingValue, object.Size.Y * smallingValue, object.Size.Z * smallingValue)
		collPart.Transparency = 1
		collPart.Massless = false
		collPart.CanCollide = true
		collPart.CanTouch = true
		collPart.Parent = object

		object.CollisionGroup = "Body"
		collPart.CollisionGroup = "CollisionPart"

		self:MakeWeld("R_"..object.Name.."CollisionWeld", object, collPart, object)
	end
end

function Ragdoll:SetBodyAttachments()
	for _, object in self.char:GetChildren() do
		if not object:IsA("BasePart") or object.Name == "HumanoidRootPart" then continue end

		if object.Name == "Head" then
			self.attachments["R_HeadTorsoAttachment"] = Ragdoll:MakeAttachment("R_HeadTorsoAttachment",  CFrame.new(0, -0.5, 0), object)
		end

		if object.Name == "Left Arm" then
			self.attachments["R_LeftArmTorsoAttachment"] = Ragdoll:MakeAttachment("R_LeftArmTorsoAttachment", CFrame.new(0.4, 0.75, 0), object)
		end

		if object.Name == "Right Arm" then
			self.attachments["R_RightArmTorsoAttachment"] = Ragdoll:MakeAttachment("R_RightArmTorsoAttachment", CFrame.new(-0.4, 0.75, 0), object)
		end

		if object.Name == "Left Leg" then
			self.attachments["R_LeftLegTorsoAttachment"] = Ragdoll:MakeAttachment("R_LeftLegTorsoAttachment", CFrame.new(0, 1, 0), object)
		end

		if object.Name == "Right Leg" then
			self.attachments["R_RightLegTorsoAttachment"] = Ragdoll:MakeAttachment("R_RightLegTorsoAttachment", CFrame.new(0, 1, 0), object)
		end

		if object.Name == "Torso" then
			self.attachments["R_TorsoHeadAttachment"] = Ragdoll:MakeAttachment("R_TorsoHeadAttachment", CFrame.new(0, 1, 0), object)
			self.attachments["R_TorsoLeftArmAttachment"] = Ragdoll:MakeAttachment("R_TorsoLeftArmAttachment", CFrame.new(-1, 0.75, 0), object)
			self.attachments["R_TorsoRightArmAttachment"] = Ragdoll:MakeAttachment("R_TorsoRightArmAttachment", CFrame.new(1, 0.75, 0), object)
			self.attachments["R_TorsoLeftLegAttachment"] = Ragdoll:MakeAttachment("R_TorsoLeftLegAttachment", CFrame.new(-0.5, -1, 0), object)
			self.attachments["R_TorsoRightLegAttachment"] = Ragdoll:MakeAttachment("R_TorsoRightLegAttachment", CFrame.new(0.5, -1, 0), object)
		end
	end
end

function Ragdoll:SetBodyJoints() 
	local torso = self.char:FindFirstChild("Torso")

	self:MakeBallSocket("R_TorsoHeadBallSocket", self.attachments["R_TorsoHeadAttachment"], self.attachments["R_HeadTorsoAttachment"], torso)
	self:MakeBallSocket("R_TorsoLeftArmBallSocket", self.attachments["R_TorsoLeftArmAttachment"], self.attachments["R_LeftArmTorsoAttachment"], torso)
	self:MakeBallSocket("R_TorsoRightArmBallSocket", self.attachments["R_TorsoRightArmAttachment"], self.attachments["R_RightArmTorsoAttachment"], torso)
	self:MakeBallSocket("R_TorsoLeftLegBallSocket", self.attachments["R_TorsoLeftLegAttachment"], self.attachments["R_LeftLegTorsoAttachment"], torso)
	self:MakeBallSocket("R_TorsoRightLegBallSocket", self.attachments["R_TorsoRightLegAttachment"], self.attachments["R_RightLegTorsoAttachment"], torso)
end

-- ====== Instantiation Zone ===========

local ragdoll = Ragdoll.new(script.Parent)

ragdoll:SetupChar()
ragdoll:EnableDefaultMotor6D(false)
ragdoll:SetBodyAttachments()
ragdoll:SetBodyJoints()
ragdoll:SetBodyCollision()