--// AUTO FISH GUI - Stable Version
-- Author: GPT-5 (by request)
-- 🎣 Includes Start/Stop, Counter, Close GUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==[ Remote Setup ]==--
local net = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local RF = net:WaitForChild("RF")
local RE = net:WaitForChild("RE")

local chargeRod = RF:WaitForChild("ChargeFishingRod")
local requestStart = RF:WaitForChild("RequestFishingMinigameStarted")
local completeFishing = RE:WaitForChild("FishingCompleted")

--==[ Variables ]==--
local autoFishing = false
local fishCount = 0

--==[ GUI Setup ]==--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishGUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 180)
Frame.Position = UDim2.new(0.5, -120, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(0, 255, 200)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.2

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🎣 AutoFish Controller"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- Start Button
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.9, 0, 0, 30)
StartButton.Position = UDim2.new(0.05, 0, 0.3, 0)
StartButton.Text = "✅ Start AutoFish"
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 18
StartButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Parent = Frame
Instance.new("UICorner", StartButton)

-- Stop Button
local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.9, 0, 0, 30)
StopButton.Position = UDim2.new(0.05, 0, 0.52, 0)
StopButton.Text = "⏹ Stop AutoFish"
StopButton.Font = Enum.Font.SourceSansBold
StopButton.TextSize = 18
StopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Parent = Frame
Instance.new("UICorner", StopButton)

-- Fish Counter
local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(1, 0, 0, 30)
CounterLabel.Position = UDim2.new(0, 0, 0.74, 0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "🐟 Fish Caught: 0"
CounterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CounterLabel.TextScaled = true
CounterLabel.Font = Enum.Font.SourceSansBold
CounterLabel.Parent = Frame

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.9, 0, 0, 28)
CloseButton.Position = UDim2.new(0.05, 0, 0.9, 0)
CloseButton.Text = "❌ Close GUI"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = Frame
Instance.new("UICorner", CloseButton)

--==[ Logic ]==--
local function updateCounter()
	CounterLabel.Text = "🐟 Fish Caught: " .. tostring(fishCount)
end

local function startAutoFish()
	if autoFishing then return end
	autoFishing = true
	print("[AutoFish] ▶ Started")

	task.spawn(function()
		while autoFishing do
			-- Charge Rod
			local success, err = pcall(function()
				return chargeRod:InvokeServer()
			end)
			if not success then warn("[AutoFish] Charge failed:", err) end

			task.wait(0.5)

			-- Start Minigame
			local startSuccess, startErr = pcall(function()
				return requestStart:InvokeServer()
			end)
			if not startSuccess then warn("[AutoFish] Start failed:", startErr) end

			-- Wait for fish caught
			local connection
			connection = completeFishing.OnClientEvent:Once(function(data)
				fishCount += 1
				updateCounter()
				print("[AutoFish] 🎣 Fish caught:", data and data.Name or "Unknown")
			end)

			task.wait(6)
		end
	end)
end

local function stopAutoFish()
	if not autoFishing then return end
	autoFishing = false
	print("[AutoFish] ⏹ Stopped")
end

--==[ Button Connections ]==--
StartButton.MouseButton1Click:Connect(startAutoFish)
StopButton.MouseButton1Click:Connect(stopAutoFish)
CloseButton.MouseButton1Click:Connect(function()
	stopAutoFish()
	ScreenGui:Destroy()
	print("[AutoFish] ❌ GUI closed")
end)

print("[AutoFish GUI] ✅ Loaded successfully!")
