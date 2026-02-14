-- [Services]
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

-- [Script Holder Variables]
local player = Players.LocalPlayer
local character = script.Parent

-- [Part Variables]
local head: BasePart = character:WaitForChild("Head")
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

RunService:BindToRenderStep("CamScript", Enum.RenderPriority.Camera.Value + 1, function()
		if not character then return end
		
		local distance = (camera.CFrame.Position - head.Position).Magnitude
		print(distance)

		-- [if first person]
		if distance < 1.5 then
			humanoid.CameraOffset = Vector3.new(0, 0, -1)
			for _, part in pairs(character:GetChildren()) do
				if part:IsA("BasePart") then
					if part.Name == "Head" then
						part.LocalTransparencyModifier = 1
					else
						part.LocalTransparencyModifier = 0
					end
				end
			end
		-- [if third person]
		else
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
			for _, part in pairs(character:GetChildren()) do
				if part:IsA("BasePart") then
					if part.Name == "Head" or part.Name == "Torso" then
						part.LocalTransparencyModifier = 0
					else
						part.LocalTransparencyModifier = 0
					end
				end
			end
			
		end
end)