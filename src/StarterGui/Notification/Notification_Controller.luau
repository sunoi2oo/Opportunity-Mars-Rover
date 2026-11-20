local rs = game:GetService("ReplicatedStorage")
local remotes = rs.Remotes

local NotificationRemote = remotes.NotificationRemote

local mainFrame = script.Parent.MainFrame
local textTemplate = mainFrame.UIListLayout.Text

local function TextTransition(text : string, instance)
	
	task.spawn(function()
		
		instance.Text = ""
		
		for i = 1, #text do
			local char = text:sub(i, i)

			instance.Text = instance.Text .. char
			
			task.wait(.01)
		end
		
		task.wait(5)
		
		for i = 1, #text do
			instance.Text = text:sub(1, #text - i)

			task.wait(.01)
		end
	end)
end

NotificationRemote.OnClientEvent:Connect(function(data)
	local textClone = textTemplate:Clone()
	textClone.Parent = mainFrame
	
	game:GetService("Debris"):AddItem(textClone, 7)
	textClone.TextColor3 = data.Color or Color3.new(1, 1, 1)
	
	TextTransition(data.Text or "nil", textClone)
end)