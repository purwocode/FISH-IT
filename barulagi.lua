-- 🎣 AUTO FISH + TELEPORT GUI (No Cycle Delay + Auto Tune)
-- by GPT-5

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ⚙️ Remotes
local RFChargeFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
local RFStartMinigame = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
local RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]

-- ⚙️ State
local autoFish = false
local autoTune = false
local loopTask = nil
local successCount, errorCount = 0, 0
local dragging = false
local dragStart, startPos, dragInput

-- ⚙️ Delay limits
local MIN_DELAY = 0.05
local MAX_DELAY = 10

-- Default config
local config = {
	completeDelay = 0.3,
	cancelDelay = 0.2
}

-- ⚙️ Teleport locations
local teleportSpots = {
	["🏝️ Beach"] = Vector3.new(120, 5, -240),
	["🌊 Dock"] = Vector3.new(-45, 4, 320),
	["🐠 Lake"] = Vector3.new(520, 12, 140),
	["🦈 Deep Sea"] = Vector3.new(950, 0, 800),
}

-- Helper functions
local function clamp(v, lo, hi)
	if v < lo then return lo end
	if v > hi then return hi end
	return v
end

local function safeSetConfig(key, val)
	local n = tonumber(val)
	if not n then return false end
	n = clamp(n, MIN_DELAY, MAX_DELAY)
	config[key] = n
	return true
end

local function tuneDelay(up)
	if up then
		config.completeDelay = clamp(config.completeDelay + 0.1, MIN_DELAY, MAX_DELAY)
		config.cancelDelay = clamp(config.cancelDelay + 0.05, MIN_DELAY, MAX_DELAY)
	else
		config.completeDelay = clamp(config.completeDelay - 0.05, MIN_DELAY, MAX_DELAY)
		config.cancelDelay = clamp(config.cancelDelay - 0.03, MIN_DELAY, MAX_DELAY)
	end
end

-- ⚙️ Core Fishing
local function doFishingCycle()
	local ok = pcall(function()
		local args = { [4] = workspace:GetServerTimeNow() }
		RFChargeFishingRod:InvokeServer(unpack(args, 1, table.maxn(args)))
		task.wait(0.1)
		RFStartMinigame:InvokeServer(-1.233184814453125, 0.5949690465352809, 1762501523.357608)
		task.wait(config.completeDelay)
		REFishingCompleted:FireServer()
		task.wait(config.cancelDelay)
		RFCancelFishingInputs:InvokeServer()
	end)

	if ok then
		successCount += 1
	else
		errorCount += 1
	end

	if autoTune then
		if errorCount >= 3 then
			tuneDelay(true)
			errorCount = 0
			print(("[🧠] Delay increased | Complete: %.2f | Cancel: %.2f"):format(config.completeDelay, config.cancelDelay))
		elseif successCount >= 10 then
			tuneDelay(false)
			successCount = 0
			print(("[⚡] Delay decreased | Complete: %.2f | Cancel: %.2f"):format(config.completeDelay, config.cancelDelay))
		end
	end
end

local function startLoop()
	if loopTask then return end
	autoFish = true
	loopTask = task.spawn(function()
		while autoFish do
			doFishingCycle()
		end
		loopTask = nil
	end)
end

local function stopLoop()
	autoFish = false
	loopTask = nil
	pcall(function()
		RFCancelFishingInputs:InvokeServer()
	end)
end

-- === GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFishTeleportGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 450)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🎣 Auto Fish + Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 60, 0, 30)
closeButton.Position = UDim2.new(1, -68, 0, 0)
closeButton.Text = "❌ Close"
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.BackgroundColor3 = Color3.fromRGB(120,20,20)
closeButton.Parent = frame
closeButton.MouseButton1Click:Connect(function()
	stopLoop()
	gui:Destroy()
end)

-- Drag window
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Buttons
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.Text = "▶️ Start Auto Fish"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
	autoFish = not autoFish
	toggleButton.Text = autoFish and "⏹ Stop Auto Fish" or "▶️ Start Auto Fish"
	if autoFish then startLoop() else stopLoop() end
end)

local autoTuneButton = Instance.new("TextButton")
autoTuneButton.Size = UDim2.new(1, -20, 0, 35)
autoTuneButton.Position = UDim2.new(0, 10, 0, 100)
autoTuneButton.Text = "🧠 Auto Tune: OFF"
autoTuneButton.TextColor3 = Color3.new(1,1,1)
autoTuneButton.Font = Enum.Font.SourceSansBold
autoTuneButton.BackgroundColor3 = Color3.fromRGB(50,50,70)
autoTuneButton.Parent = frame

autoTuneButton.MouseButton1Click:Connect(function()
	autoTune = not autoTune
	autoTuneButton.Text = autoTune and "🧠 Auto Tune: ON" or "🧠 Auto Tune: OFF"
	autoTuneButton.BackgroundColor3 = autoTune and Color3.fromRGB(70,100,50) or Color3.fromRGB(50,50,70)
end)

-- Delay inputs
local function createDelayInput(labelText, defaultValue, y, key)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 150, 0, 24)
	label.Position = UDim2.new(0, 10, 0, y)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 90, 0, 26)
	box.Position = UDim2.new(0, 170, 0, y-2)
	box.Text = tostring(defaultValue)
	box.TextColor3 = Color3.new(1,1,1)
	box.BackgroundColor3 = Color3.fromRGB(50,50,50)
	box.Font = Enum.Font.SourceSans
	box.TextSize = 14
	box.ClearTextOnFocus = false
	box.Parent = frame

	box.FocusLost:Connect(function()
		if safeSetConfig(key, box.Text) then
			box.Text = tostring(config[key])
		else
			box.Text = tostring(config[key])
		end
	end)
	return box
end

local completeBox = createDelayInput("🎯 Complete Delay:", config.completeDelay, 150, "completeDelay")
local cancelBox = createDelayInput("❌ Cancel Delay:", config.cancelDelay, 190, "cancelDelay")

-- === TELEPORT SECTION ===
local teleportLabel = Instance.new("TextLabel")
teleportLabel.Size = UDim2.new(1, -20, 0, 24)
teleportLabel.Position = UDim2.new(0, 10, 0, 230)
teleportLabel.Text = "📍 Teleport Locations"
teleportLabel.BackgroundTransparency = 1
teleportLabel.TextColor3 = Color3.new(1,1,1)
teleportLabel.Font = Enum.Font.SourceSansBold
teleportLabel.TextSize = 16
teleportLabel.TextXAlignment = Enum.TextXAlignment.Left
teleportLabel.Parent = frame

local yOffset = 260
for name, pos in pairs(teleportSpots) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, yOffset)
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(40,60,80)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = frame
	btn.MouseButton1Click:Connect(function()
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(pos)
			print("[📍] Teleported to " .. name)
		end
	end)
	yOffset = yOffset + 35
end

-- Auto update delay textboxes
task.spawn(function()
	while gui.Parent do
		task.wait(1)
		if autoTune then
			completeBox.Text = string.format("%.2f", config.completeDelay)
			cancelBox.Text = string.format("%.2f", config.cancelDelay)
		end
	end
end)

print("[✅] Auto Fish + Teleport GUI Loaded.")
