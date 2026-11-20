local contextActionService = game:GetService("ContextActionService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")

local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera

local remotes = replicatedStorage.Remotes
local grabRemote = remotes.ArmGrabRemote

local throttleInput = 0 -- -1 (reverse) to 1 (forward)
local steerInput = 0    -- -1 (left) to 1 (right)

local maxSteerAngle = math.rad(35) 
local maxSpeed = 20

local L1 = 2.084
local L2 = 2.084
local maxReach = L1 + L2
local minReach = math.abs(L1 - L2)

local maxTime = 3
local cd = 1
local currTime = tick()
local grab = false
local currPos

local function getMousePos()
	
	local dist = 8
		
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {player.Character}

	local screenPos = userInputService:GetMouseLocation()
	local inset = guiService:GetGuiInset()

	screenPos = screenPos - inset

	if userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or userInputService.TouchEnabled then
		screenPos = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2) - inset
	end

	local unitRay = camera:ScreenPointToRay(screenPos.X, screenPos.Y)

	local rayDir = unitRay.Direction * dist
	local rayResult = workspace:Raycast(unitRay.Origin, rayDir, raycastParams)

	local aimPoint
	if rayResult and rayResult.Position then
		aimPoint = rayResult.Position
	else
		aimPoint = unitRay.Origin + unitRay.Direction * dist
	end
	
	return aimPoint
end

local function solveIK(targetPos: Vector3, Links, Joints)
	local origin = Links.RotateBase.Upper.WorldPosition
	local relPos = targetPos - origin

	local localPos = Links.Base.CFrame:VectorToObjectSpace(relPos) -- Normalize the orientaion

	local r3D = relPos.Magnitude

	if r3D > maxReach then
		localPos = localPos.Unit * maxReach
	elseif r3D < minReach then
		localPos = localPos.Unit * minReach
	end

	local R = math.sqrt(localPos.Z^2 + localPos.X^2) -- XZ dist
	local H = localPos.Y -- Height
	local r = math.sqrt(R^2 + H^2) -- XYZ dist

	-- Base Yaw Angle
	local baseAngleRad = math.atan2(localPos.Z, localPos.X)

	-- Angle via Law of Cosines
	local cosTheta2 = (r^2 - L1^2 - L2^2) / (2 * L1 * L2)
	cosTheta2 = math.clamp(cosTheta2, -1, 1)
	local theta2 = math.acos(cosTheta2)

	-- Shoulder
	local theta1 = math.atan2(R, H) - math.atan2(L2 * math.sin(theta2), L1 + L2 * math.cos(theta2))

	Joints.J1.TargetAngle = math.deg(baseAngleRad)
	Joints.J2.TargetAngle = math.deg(theta1)
	Joints.J3.TargetAngle = math.deg(theta2)
end

local function flipRover(rootPart : BasePart)
	
	if not rootPart then return end
	
	local _, yRot, _ = rootPart.CFrame:ToOrientation()

	rootPart.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 3, 0)) * CFrame.Angles(0, yRot, 0)

	rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

local function handleInput(actionName, inputState, inputObject)
	if actionName == "ThrottleForward" then
		throttleInput = (inputState == Enum.UserInputState.Begin) and 1 or 0
	elseif actionName == "ThrottleReverse" then
		throttleInput = (inputState == Enum.UserInputState.Begin) and -1 or 0
	elseif actionName == "SteerLeft" then
		steerInput = (inputState == Enum.UserInputState.Begin) and -1 or 0
	elseif actionName == "SteerRight" then
		steerInput = (inputState == Enum.UserInputState.Begin) and 1 or 0
	end
end

contextActionService:BindAction("ThrottleForward", handleInput, false, Enum.KeyCode.W)
contextActionService:BindAction("ThrottleReverse", handleInput, false, Enum.KeyCode.S)
contextActionService:BindAction("SteerLeft", handleInput, false, Enum.KeyCode.A)
contextActionService:BindAction("SteerRight", handleInput, false, Enum.KeyCode.D)

contextActionService:BindAction("TargetHand", function(actionName, inputState, inputObject)
	
	if inputState == Enum.UserInputState.Begin then
		
		if tick() - currTime >= cd then
			currTime = tick()
			local hitPos = getMousePos()
			currPos = hitPos

			script.ArmMove:Play()
			
			grab = false
			
		elseif not grab then
			
			script.Grab:Play()
			grab = true
			
			grabRemote:FireServer({
				Position = currPos
			})
		end
	end
		
end, false, Enum.UserInputType.MouseButton1)

contextActionService:BindAction("FlipRover", function(actionName, inputState, inputObject)

	if inputState == Enum.UserInputState.Begin then
		
		flipRover(player.Character.PrimaryPart)
	end

end, false, Enum.KeyCode.R)

runService.RenderStepped:Connect(function()
	if player.Character then
		local rover = player.Character
		local chassis = rover:FindFirstChild("Chassis")
		
		if chassis then
			local flSteer = chassis:WaitForChild("SteerFL")
			local frSteer = chassis:WaitForChild("SteerFR")
			local blSteer = chassis:WaitForChild("SteerBL")
			local brSteer = chassis:WaitForChild("SteerBR")

			local flMotor = chassis:WaitForChild("MotorFL")
			local frMotor = chassis:WaitForChild("MotorFR")
			local mlMotor = chassis:WaitForChild("MotorML")
			local mrMotor = chassis:WaitForChild("MotorMR")
			local blMotor = chassis:WaitForChild("MotorBL")
			local brMotor = chassis:WaitForChild("MotorBR")

			local frontAngle = steerInput * maxSteerAngle
			local rearAngle = -steerInput * maxSteerAngle

			flSteer.TargetAngle = math.deg(frontAngle)
			frSteer.TargetAngle = math.deg(frontAngle)
			blSteer.TargetAngle = math.deg(rearAngle)
			brSteer.TargetAngle = math.deg(rearAngle)

			local targetVelocity = throttleInput * maxSpeed

			flMotor.AngularVelocity = targetVelocity
			frMotor.AngularVelocity = -targetVelocity
			mlMotor.AngularVelocity = targetVelocity
			mrMotor.AngularVelocity = -targetVelocity
			blMotor.AngularVelocity = targetVelocity
			brMotor.AngularVelocity = -targetVelocity
			
			script.Move.PlaybackSpeed = math.abs(targetVelocity) / maxSpeed
		end
		
		local arm = player.Character:FindFirstChild("Arm")
		
		if arm then
			if tick() - currTime >= maxTime then
				
				if currPos then
					script.ArmMove:Play()
				end
				
				local joints = arm.Joints
				
				joints.J1.TargetAngle = -90
				joints.J2.TargetAngle = -45
				joints.J3.TargetAngle = 135
				currPos = nil
				
				grab = false
				
			elseif currPos then
				
				local Joints = arm.Joints
				local Links = arm.Links
				solveIK(currPos, Links, Joints)
			end
		end
	end
end)