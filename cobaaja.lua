--// 🐟 AUTO FISH GUI v2 (sleitnick_net compatible)
-- Pastikan ini dijalankan di LocalScript (executor / client)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Ambil remote folder
local net = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local RF = net:WaitForChild("RF")
local RE = net:WaitForChild("RE")

-- Remote utama
local equipRemote = RE:WaitForChild("EquipToolFromHotbar")
local rodRemote = RF:WaitForChild("ChargeFishingRod")
local miniGameRemote = RF:WaitForChild("RequestFishingMinigameStarted")
local finishRemote = RE:WaitForChild("FishingCompleted")

print("[AutoFish] Remotes Loaded ✅")

-- Variabel utama
local autofish = false
local perfectCast = false
local autoRecastDelay = 1.5
local fishCount = 0

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFishGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 230)
Frame.Position = UDim2.new(0.5, -150, 0.5, -115)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "🎣 Auto Fishing"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local StartButton = Instance.new("TextButton", Frame)
StartButton.Position = UDim2.new(0.1, 0, 0.2, 0)
StartButton.Size = UDim2.new(0.8, 0, 0, 30)
StartButton.Text = "✅ Start AutoFish"
StartButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 16

local StopButton = Instance.new("TextButton", Frame)
StopButton.Position = UDim2.new(0.1, 0, 0.35, 0)
StopButton.Size = UDim2.new(0.8, 0, 0, 30)
StopButton.Text = "⏹ Stop AutoFish"
StopButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 16

local TogglePerfect = Instance.new("TextButton", Frame)
TogglePerfect.Position = UDim2.new(0.1, 0, 0.5, 0)
TogglePerfect.Size = UDim2.new(0.8, 0, 0, 30)
TogglePerfect.Text = "✨ Perfect Cast: OFF"
TogglePerfect.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
TogglePerfect.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePerfect.Font = Enum.Font.GothamBold
TogglePerfect.TextSize = 16

local Counter = Instance.new("TextLabel", Frame)
Counter.Position = UDim2.new(0.1, 0, 0.65, 0)
Counter.Size = UDim2.new(0.8, 0, 0, 30)
Counter.Text = "🐟 Fish Caught: 0"
Counter.TextColor3 = Color3.fromRGB(255, 255, 255)
Counter.BackgroundTransparency = 1
Counter.Font = Enum.Font.GothamBold
Counter.TextSize = 16

local CloseButton = Instance.new("TextButton", Frame)
CloseButton.Position = UDim2.new(0.1, 0, 0.8, 0)
CloseButton.Size = UDim2.new(0.8, 0, 0, 30)
CloseButton.Text = "❌ Close GUI"
CloseButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16

-- Fungsi utama AutoFish
local function startFishing()
	task.spawn(function()
		while autofish do
			pcall(function()
				equipRemote:FireServer(1)
				task.wait(0.2)

				-- Casting
				local timestamp = perfectCast and 9999999999 or (tick() + math.random())
				rodRemote:InvokeServer(timestamp)
				task.wait(0.5)

				-- Start minigame
				local x = perfectCast and -1.238 or (math.random(-1000, 1000) / 1000)
				local y = perfectCast and 0.969 or (math.random(0, 1000) / 1000)
				miniGameRemote:InvokeServer(x, y)
				task.wait(1.2)

				-- Finish fishing (simulate reel complete)
				finishRemote:FireServer()
				fishCount += 1
				Counter.Text = "🐟 Fish Caught: " .. fishCount
			end)
			task.wait(autoRecastDelay)
		end
	end)
end

-- Button logic
StartButton.MouseButton1Click:Connect(function()
	if not autofish then
		autofish = true
		StartButton.Text = "🎣 Running..."
		startFishing()
	end
end)

StopButton.MouseButton1Click:Connect(function()
	autofish = false
	StartButton.Text = "✅ Start AutoFish"
end)

TogglePerfect.MouseButton1Click:Connect(function()
	perfectCast = not perfectCast
	TogglePerfect.Text = perfectCast and "✨ Perfect Cast: ON" or "✨ Perfect Cast: OFF"
end)

CloseButton.MouseButton1Click:Connect(function()
	autofish = false
	ScreenGui:Destroy()
end)
