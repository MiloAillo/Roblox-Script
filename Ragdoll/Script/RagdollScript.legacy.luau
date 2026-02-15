-- ========= Collison Group ==============
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	self.plr = game:GetService("Players"):GetPlayerFromCharacter(char)
	self.hum = char:WaitForChild("Humanoid")
	self.hrp = char:WaitForChild("HumanoidRootPart")
	self.ragdollEvent = ReplicatedStorage:FindFirstChild("IsRagdollEvent")
	self.BallSockets = {}
	self.attachments = {}
	self.collParts = {}
	self.isReservedToLoad = false

	return self
end

function Ragdoll:SetupChar()
	self.hum.BreakJointsOnDeath = false
	self.hum.RequiresNeck = false

	self.char:SetAttribute("IsRagdoll", false)
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

	self.BallSockets[ballSocket.Name] = ballSocket

	return ballSocket
end

function Ragdoll:SetBodyCollision()
	for _, object: BasePart in self.char:GetChildren() do
		if not object:IsA("BasePart") or object.Name == "HumanoidRootPart" then continue end

		local smallingValue = 0.8
		local collPart: BasePart = object:Clone()
		collPart.Size = Vector3.new(object.Size.X * smallingValue, object.Size.Y * smallingValue, object.Size.Z * smallingValue)
		collPart.Transparency = 1
		collPart.Massless = true
		collPart.CanCollide = false
		collPart.Parent = object

		object.CollisionGroup = "Body"
		collPart.CollisionGroup = "CollisionPart"

		self:MakeWeld("R_"..object.Name.."CollisionWeld", object, collPart, object)

		self.collParts[collPart.Name] = collPart
	end
end

function Ragdoll:SetBodyAttachments()
	for _, object in self.char:GetChildren() do
		if not object:IsA("BasePart") or object.Name == "HumanoidRootPart" then continue end

		if object.Name == "Head" then
			self.attachments["R_HeadTorsoAttachment"] = self:MakeAttachment("R_HeadTorsoAttachment",  CFrame.new(0, -0.5, 0), object)
		end

		if object.Name == "Left Arm" then
			self.attachments["R_LeftArmTorsoAttachment"] = self:MakeAttachment("R_LeftArmTorsoAttachment", CFrame.new(0.4, 0.75, 0), object)
		end

		if object.Name == "Right Arm" then
			self.attachments["R_RightArmTorsoAttachment"] = self:MakeAttachment("R_RightArmTorsoAttachment", CFrame.new(-0.4, 0.75, 0), object)
		end

		if object.Name == "Left Leg" then
			self.attachments["R_LeftLegTorsoAttachment"] = self:MakeAttachment("R_LeftLegTorsoAttachment", CFrame.new(0, 1, 0), object)
		end

		if object.Name == "Right Leg" then
			self.attachments["R_RightLegTorsoAttachment"] = self:MakeAttachment("R_RightLegTorsoAttachment", CFrame.new(0, 1, 0), object)
		end

		if object.Name == "Torso" then
			self.attachments["R_TorsoHeadAttachment"] = self:MakeAttachment("R_TorsoHeadAttachment", CFrame.new(0, 1, 0), object)
			self.attachments["R_TorsoLeftArmAttachment"] = self:MakeAttachment("R_TorsoLeftArmAttachment", CFrame.new(-1, 0.75, 0), object)
			self.attachments["R_TorsoRightArmAttachment"] = self:MakeAttachment("R_TorsoRightArmAttachment", CFrame.new(1, 0.75, 0), object)
			self.attachments["R_TorsoLeftLegAttachment"] = self:MakeAttachment("R_TorsoLeftLegAttachment", CFrame.new(-0.5, -1, 0), object)
			self.attachments["R_TorsoRightLegAttachment"] = self:MakeAttachment("R_TorsoRightLegAttachment", CFrame.new(0.5, -1, 0), object)
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

function Ragdoll:EnableCollision(state: boolean)
	for _, collPart: BasePart in pairs(self.collParts) do
		collPart.CanCollide = state
		collPart.CanTouch = state
	end
end

function Ragdoll:EnableRagdoll(enable: boolean)
	if enable then 
		self:EnableCollision(true)
		self:EnableDefaultMotor6D(false)
		self.hum:ChangeState(Enum.HumanoidStateType.Physics)
		self.hum.AutoRotate = false
		self.hum.PlatformStand = true
	else
		-- anchored the rootPart for a moment so it doesnt launch itself to the air
		self.hrp.Anchored = true

		-- set velocity to minimize the chance to launch itself
		self.hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    	self.hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		self:EnableCollision(false)
		self:EnableDefaultMotor6D(true)

		-- set velocity to minimize the chance to launch itself
		self.hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    	self.hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		self.hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		self.hum.AutoRotate = true
		self.hum.PlatformStand = false

		-- set velocity to minimize the chance to launch itself
		self.hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    	self.hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		self.hrp.Anchored = false

		-- mb for spamming the velocity lol, what can i do afterall
	end
end

function Ragdoll:PostInit()
	self.char.AttributeChanged:Connect(function(attribute)
		if(attribute == "IsRagdoll") then
			local isRagdoll = self.char:GetAttribute("IsRagdoll")
			
			if isRagdoll then
				self:EnableRagdoll(true)
			else
				self:EnableRagdoll(false)
			end
		end
	end)

	self.ragdollEvent.OnServerEvent:Connect(function(player)
		if self.plr ~= player then return end
		
		local isRagdoll = self.char:GetAttribute("IsRagdoll")
		self.char:SetAttribute("IsRagdoll", not isRagdoll)
	end)

	-- effective to ragdoll when character die, NOT EFFECTIVE when char already ragdolled because roblox engine succ.
	-- server Humanoid Health state is static and will not update until loosened.
	-- bypass using client
	self.hum.Died:Connect(function()
		self:EnableRagdoll(true)

		task.wait(game:GetService("Players").RespawnTime)

		if self.plr and not self.isReservedToLoad then
			self.plr:LoadCharacter()
			self.isReservedToLoad = true
		end
	end)
end

-- ====== Player Spawn Instantiation ===========

Players.PlayerAdded:Connect(function(player) 
	player.CharacterAdded:Connect(function(char) 
		local ragdoll = Ragdoll.new(char)

		-- run the first time character spawn
		ragdoll:SetupChar()
		ragdoll:EnableRagdoll(true) -- yeah, this is needed to disasble the default motor6D so the engine doesnt get confused
		ragdoll:SetBodyAttachments()
		ragdoll:SetBodyJoints()
		ragdoll:SetBodyCollision()

		-- switch back to false
		ragdoll:EnableRagdoll(false)

		ragdoll:PostInit()
	end)
end)
