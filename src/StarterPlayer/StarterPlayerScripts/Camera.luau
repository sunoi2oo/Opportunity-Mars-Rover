local camera = game:GetService("Workspace").CurrentCamera
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")

camera.FieldOfView = 120

runService.RenderStepped:Connect(function()
	if player.Character then
		local camPart = player.Character:FindFirstChild("CameraPart")
		
		if camPart then
			camera.CameraType = Enum.CameraType.Scriptable

			camera.CFrame = camPart.CFrame
		end
	end
end)
