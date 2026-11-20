local tweenService = game:GetService("TweenService")
local player = game:GetService("Players").LocalPlayer

local Inventory = player:WaitForChild("Inventory") :: Folder

local menuButton = script.Parent.ImageButton

local mainFrame = script.Parent.MainFrame
local browseFrame = mainFrame.BrowseFrame
local detailFrame = mainFrame.DetailFrame

local Image = detailFrame.ImageLabel
local NameLabel = detailFrame.NameLabel
local DetailLabel = detailFrame.DetailLabel

local scrollingFrame = browseFrame.ScrollingFrame

local frameTemplate = scrollingFrame.UIListLayout.Frame

local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false)

local open = false
local detailOpen = false
local debounce = false

local rockDetails = {
	Hematite_Spherules = {
		ImageID = "rbxassetid://134920787668785",
		Name = "<Hematite_Spherules>",
		Detail = " Tiny, millimeter-sized, round spherical concretions scattered across the soil and embedded in rock outcrops throughout Meridiani Planum.\n\n Composed largely of iron-oxide hematite, these spheres formed chemically inside rocks as mineral-rich groundwaters soaked through them. Finding them provided the smoking-gun evidence that Mars once had abundant, standing surface water."
	},
	Meridiani_Meteorite = {
		ImageID = "rbxassetid://110142259443522",
		Name = "<Meridiani_Meteorite>",
		Detail = " A basketball-sized, metallic iron-nickel meteorite found sitting right next to the rover's discarded thermal heat shield.\n\n This marked the very first meteorite ever discovered on the surface of another planet. Its composition of iron and nickel proved that meteorites survive passage through the thin Martian atmosphere much like they do on Earth."
	},
	El_Capitan = {
		ImageID = "rbxassetid://73530327887913",
		Name = "<El_Capitan>",
		Detail = " A rock outcrop located inside Eagle Crater\n\n Opportunity drilled into El Capitan using its Rock Abrasion Tool (RAT). The exposed interior revealed fine-scale layering (cross-bedding) created by flowing liquid water, alongside the mineral jarosite, confirming that the ancient Martian environment was soaked in shallow, acidic water."
	},
	Bounce_Rock = {
		ImageID = "rbxassetid://95440117030688",
		Name = "<Bounce_Rock>",
		Detail = " A loose, highly unusual dark rock that happened to bounce off Opportunity’s landing airbag assembly as the rover bounced to a stop in Eagle Crater.\n\n Unlike the surrounding sedimentary plain, Bounce Rock is a chunk of volcanic basalt that chemically matched a famous Martian meteorite found on Earth (EETA79001). It proved that volcanic activity from a distant impact zone had been violently hurled across the region."
	},
	Block_Island = {
		ImageID = "rbxassetid://81539606182695",
		Name = "<Block_Island>",
		Detail = " A series of massive, car-sized or boulder-sized iron-nickel meteorites found sitting exposed on the flat plains as Opportunity journeyed toward the massive Endeavour Crater.\n\n Because they were so large, scientists calculated that they either fell under a much thicker ancient Martian atmosphere or that the surface of Mars has eroded significantly over geological time scales, uncovering buried ancient impacts."
	},
	Homestake_Vein = {
		ImageID = "rbxassetid://136690170446556",
		Name = "<Homestake_Vein>",
		Detail = " A bright, light-toned mineral vein discovered jutting out of the bedrock along the rim of Endeavour Crater.\n\n Unlike the acidic water indicators found earlier in the mission, Homestake was composed of pure gypsum. Gypsum forms only in neutral, non-acidic water. This was a monumental find because neutral water environments are far more hospitable and friendly to potential past microbial life."
	},
	Eagle_Crater = {
		ImageID = "rbxassetid://131961210291531",
		Name = "<Eagle_Crater>",
		Detail = " A small impact crater roughly 22 meters in diameter.\n\n It was the landing site for Opportunity on January 25, 2004. Inside Eagle Crater, the rover made its historic discovery of outcrop rocks (the Burns formation), providing the first definitive in-situ evidence that liquid water once flowed across ancient Mars."
	},
	Endurance_Crater = {
		ImageID = "rbxassetid://127312417243463",
		Name = "<Endurance_Crater>",
		Detail = " A large impact crater about 130 meters wide, visited by Opportunity between June and December 2004.\n\n Endurance Crater provided deep, well-exposed geological cross-sections of sedimentary rock layers. By studying the walls of the crater, scientists were able to confirm that the region experienced fluctuating environmental conditions, transitioning from wet dune fields to shallow, evaporating bodies of water."
	},
	Victoria_Crater = {
		ImageID = "rbxassetid://98795705402136",
		Name = "<Victoria_Crater>",
		Detail = " A massive impact crater roughly 750 meters in diameter, explored by Opportunity from 2006 to 2008.\n\n Victoria Crater is famous for its dramatic, towering cliffs and alcoves along its rim. It offered scientists a window into even deeper geological strata, showcasing aeolian (wind-blown) dune deposits cemented by groundwater over billions of years." 
	},
	Duck_Bay = {
		ImageID = "rbxassetid://99710627334182",
		Name = "<Duck_Bay>",
		Detail = " A scalloped alcove and indentation along the rim of Victoria Crater.\n\n Opportunity used Duck Bay as its designated gateway to enter Victoria Crater in September 2007 and later exited through it in August 2008 to begin its long journey toward Endeavour Crater."
	},
	Cape_Verde = {
		ImageID = "rbxassetid://140477208018283",
		Name = "<Cape_Verde>",
		Detail = " A prominent, towering promontory/cliff along the rim of Victoria Crater, named after the Cape Verde archipelago on Earth.\n\n Cape Verde featured some of the most spectacular exposed cliff faces seen by the rover, allowing scientists to study fine-scale laminations and cross-bedding in the Martian rock strata."
	},
	Lyell_Smith_Steno = {
		ImageID = "rbxassetid://139734563976893",
		Name = "<Lyell_Smith_Steno>",
		Detail = " Geological rock outcrops or crater features named after pioneering Earth geologists (Charles Lyell, William Smith, and Nicolaus Steno).\n\n These sites were examined by Opportunity to study the lateral continuity and variations in the rock layers across the Meridiani plains and crater rims, helping establish the geological history of the region."
	},
	Santa_Maria_Crater = {
		ImageID = "rbxassetid://77990740533977",
		Name = "<Santa_Maria_Crater>",
		Detail = " An impact crater about 90 meters in diameter, visited by Opportunity in late 2010 and early 2011.\n\n Serving as a stopover during the multi-year trek toward Endeavour Crater, Santa Maria provided fresh impact ejecta and exposed bedrock that allowed scientists to test instruments on undisturbed material."
	},
	Endeavour_Crater = {
		ImageID = "rbxassetid://131684817640750",
		Name = "<Endeavour_Crater>",
		Detail = " A colossal ancient impact crater measuring roughly 22 kilometers in diameter, reached by Opportunity in 2011.\n\n Endeavour represented a major milestone in the mission. Its rim segments (such as Cape York and Solander Point) exposed much older rocks from Mars' Noachian period—specifically clay-bearing minerals (phyllosilicates) formed in the presence of neutral, life-friendly water."
	},
	Bitterroot_Valley = {
		ImageID = "rbxassetid://78899845897393",
		Name = "<Bitterroot_Valley>",
		Detail = " A localized geological valley feature located along the rim of Endeavour Crater (near Cape York).\n\n Explored by Opportunity as part of the detailed stratigraphic mapping of Endeavour’s rim, contributing to the understanding of ancient aqueous alteration and mineral veins (like gypsum)."
	},
	Perserverance_Valley = {
		ImageID = "rbxassetid://117615485608197",
		Name = "<Perserverance_Valley>",
		Detail = " A depression and channel-like feature carved into the western rim of Endeavour Crater.\n\n Believed to have been shaped by fluid action (such as debris flows or flowing water), Perseverance Valley was the final operational site for the Opportunity rover in mid-2018 before the mission concluded during a planet-wide dust storm."
	},
}

local found = {}

local function openDetailsTween()
	if not detailOpen then
		detailOpen = true
		
		local tween = tweenService:Create(browseFrame, tweenInfo, {Position = UDim2.new(.23, 0, .5, 0)})

		tween:Play()

		tween.Completed:Once(function()
			detailFrame.Visible = true
		end)
	end
end

local function closeDetailsTween()
	
	detailFrame.Visible = false
	local tween = tweenService:Create(browseFrame, tweenInfo, {Position = UDim2.new(.5, 0, .5, 0)})

	tween:Play()
end

local function changeDetails(Name)
	local details = rockDetails[Name]
	
	if details then
		Image.Image = details.ImageID
		NameLabel.Text = details.Name
		DetailLabel.Text = details.Detail
		
		return true
	end
	
	return false
end

Inventory.ChildAdded:Connect(function(RockType)
	if found[RockType.Name] then return end
	
	local frameClone = frameTemplate:Clone()
	
	frameClone.TextButton.Text = "<"..RockType.Name..">"
	frameClone.Parent = scrollingFrame
	
	frameClone.RockType.Value = RockType.Name
	
	found[RockType.Name] = true
end)

scrollingFrame.ChildAdded:Connect(function(frame)
	local button = frame:FindFirstChild("TextButton")
	local rockType = frame:FindFirstChild("RockType")
	
	if button and rockType then
		button.MouseButton1Click:Connect(function()
			script.Tick:Play()
			if changeDetails(rockType.Value) then
				debounce = true
				openDetailsTween()
				
				task.wait(tweenInfo.Time)
				
				debounce = false
			end
		end)
	end
end)

menuButton.MouseButton1Down:Connect(function()
	script.Tick:Play()
	if debounce then return end
	
	if not open then
		debounce = true
		
		local tween = tweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(.5, 0, .5, 0)})
		tween:Play()
		
		open = true
		
		task.wait(tweenInfo.Time)
		
		debounce = false
	else
		debounce = true
		
		if detailOpen then
			closeDetailsTween()

			task.wait(tweenInfo.Time)
		end
		
		local tween = tweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(.5, 0, 1.5, 0)})
		tween:Play()
		
		open = false
		detailOpen = false
		
		task.wait(tweenInfo.Time)

		debounce = false
	end
end)