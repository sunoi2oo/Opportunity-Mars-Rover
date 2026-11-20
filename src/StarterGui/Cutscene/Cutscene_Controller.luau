local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage.Remotes
local cutsceneRemote = remotes.CutsceneRemote

local mainFrame = script.Parent.MainFrame
local textLabel = mainFrame.TextLabel

local function TextTransition(instance, text : string)
	instance.Text = ""

	for i = 1, #text do
		local char = text:sub(i, i)

		instance.Text = instance.Text .. char

		task.wait(.01)
	end
end

cutsceneRemote.OnClientEvent:Connect(function(data)
	
	script.Parent.Enabled = true
	
	local texts = data.Texts
	
	for i, text in pairs(texts) do
		
		TextTransition(textLabel, text)
		
		task.wait(3)
	end
	
	script.Parent.Enabled = false
end)