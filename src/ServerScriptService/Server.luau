local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local players = game:GetService("Players")
local Assets = serverStorage.Assets
local remotes = replicatedStorage.Remotes

local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false)

local MarsRover = Assets.Rover_Opportunity

local grabRemote = remotes.ArmGrabRemote
local notificationRemote = remotes.NotificationRemote
local objectiveRemote = remotes.ObjectiveRemote
local cutsceneRemote = remotes.CutsceneRemote

local rocks = game:GetService("Workspace").Rocks
local Zones = game:GetService("Workspace").Zones
local wayPoints = game:GetService("Workspace").WayPoints

local minDist = 5

local wayPointsData = {
	["1"] = "Visit Endurance Crater.",
	["2"] = "Visit Victoria Crater.",
	["3"] = "Visit Santa Maria Crater.",
	["4"] = "Visit Endeavor Crater.",
	["5"] = "Visit Bitterroot Valley.",
	["6"] = "Visit Perseverance Valley.",
	["7"] = "Main Story Completed, You May Explore Mars."
}

local currPoint = 1

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local sandStormCutscenes = {}
local endCutscenes = {}

local function checkPlayersInZone(zone)
	local characters = {}

	for _, player in ipairs(players:GetPlayers()) do
		if player.Character then
			table.insert(characters, player.Character)
		end
	end

	overlapParams.FilterDescendantsInstances = characters

	local parts = workspace:GetPartBoundsInBox(
		zone.CFrame,
		zone.Size,
		overlapParams
	)

	local playersInZone = {}

	for _, part in ipairs(parts) do
		local character = part:FindFirstAncestorOfClass("Model")
		local player = character and players:GetPlayerFromCharacter(character)

		if player then
			playersInZone[player] = true
		end
	end

	for player in pairs(playersInZone) do
		
		local Inventory = player:FindFirstChild("Inventory")
		
		if not Inventory then continue end
		
		for _, value in pairs(zone:GetChildren()) do
			if value:IsA("BoolValue") then
				
				if Inventory:FindFirstChild(value.Name) then continue end
				
				local valueClone = value:Clone()
				valueClone.Parent = Inventory
				
				notificationRemote:FireClient(player, {
					Text = "Arrived At <" .. value.Name .. "> !"
				})
			end
		end
		
		if zone.Name == "Perserverance Valley Zone" and not endCutscenes[player] then
			endCutscenes[player] = true
			
			task.delay(10, function()
				cutsceneRemote:FireClient(player, {
					Texts = {
						"LOW POWER CRITICAL ENERGY LEVEL Solar energy is insufficient to maintain normal operations.",
						"Communication may become unavailable.",
						"Mission status: Unknown OPPORTUNITY ROVER",
						"15 YEARS OF EXPLORATION.",
						"COUNTLESS DISCOVERIES.",
						"Opportunity, thank you."
					}
				})
			end)
			
		elseif zone.Name == "Victoria Crater Zone" and not sandStormCutscenes[player] then
			sandStormCutscenes[player] = true
			
			task.delay(10, function()
				cutsceneRemote:FireClient(player, {
					Texts = {
						"MARS — JULY 2007",
						"A DUST STORM APPROACHES",
						"“Dust is spreading across the Martian sky.”",
						"“The sunlight is becoming weaker.”",
						"LOW POWER WARNING",
						"“Less sunlight is reaching Opportunity’s solar panels.”",
						"“Available energy is dropping.”",
						"SCIENCE OPERATIONS SUSPENDED",
						"“Opportunity must conserve power to survive.”",
						"THE STORM BEGINS TO CLEAR",
						"“The dust storm is finally weakening.”",
						"“Opportunity begins recovering its power.”",
						"THE MISSION CONTINUES."
					}
				})
			end)
		end
	end
end

local function checkNearby(position, radius)
	for _, player in ipairs(players:GetPlayers()) do
		local character = player.Character

		if character then
			local rootPart = character.PrimaryPart

			local distance = (rootPart.Position - position).Magnitude

			if distance <= radius then
				return true, player
			end
		end
	end

	return false, nil
end

players.PlayerAdded:Connect(function(player)
	local inventory = Instance.new("Folder", player)
	inventory.Name = "Inventory"
	
	local point = wayPoints:FindFirstChild(currPoint) :: Attachment
	if point then
		objectiveRemote:FireClient(player, {
			Position = point.Position,
			Text = wayPointsData[tostring(currPoint)] or "nil"
		})
	end
	player.CharacterAdded:Connect(function(character)
		character:Destroy()
		local MarsRoverClone = MarsRover:Clone()
		MarsRoverClone.Parent = game:GetService("Workspace")

		player.Character = MarsRoverClone
		player.Character.Name = "Mars_Rover_"..player.Name
		player.Character:PivotTo(CFrame.new(-479.968, 9, 619.841))
		
	end)
end)

grabRemote.OnServerEvent:Connect(function(player, data)
	local pos = data.Position
	
	local Inventory = player:FindFirstChild("Inventory")
	
	for _, rock in pairs(rocks:GetChildren()) do
		
		local found = rock:FindFirstChild("Found")
		
		local rockPos = rock:GetPivot().Position
		local modelCFrame, modelSize = rock:GetBoundingBox()

		local boundingRadius = modelSize.Magnitude / 2
		
		if (rockPos - pos).Magnitude < boundingRadius and found and found.Value == false and Inventory then
			
			local highlight = rock:FindFirstChild("Highlight")
			if highlight then
				tweenService:Create(highlight, tweenInfo, {OutlineTransparency = 1}):Play()
			end
			
			found.Value = true
			
			local rockValue = Instance.new("BoolValue", Inventory)
			
			local rockType = rock:FindFirstChild("RockType")
			
			if rockType then
				rockValue.Name = rockType.Value
			else
				rockValue.Name = rock.Name
			end
			
			notificationRemote:FireClient(player, {
				Text = "Found <" .. rockValue.Name .. "> !"
			})
			break
		end
	end
end)

for _, zone in pairs(Zones:GetChildren()) do
	game:GetService("RunService").Heartbeat:Connect(function()
		checkPlayersInZone(zone)
	end)
end
for currPoint = 1, #wayPoints:GetChildren() do
	local point = wayPoints:FindFirstChild(currPoint) :: Attachment
	if point then
		
		objectiveRemote:FireAllClients({
			Position = point.Position,
			Text = wayPointsData[tostring(currPoint)] or "nil"
		})
		
		repeat task.wait()
			
		until checkNearby(point.Position, 10)
		
	end
end