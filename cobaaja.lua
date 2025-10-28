--// 🎣 AUTO FISH GUI V2
-- Struktur: game.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
-- UI Library: Rayfield (https://sirius.menu/rayfield)

--=== SERVICES ===--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--=== REMOTES ===--
local net = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

local RF = net:WaitForChild("RF")
local RE = net:WaitForChild("RE")

local equipRemote = RE:WaitForChild("EquipToolFromHotbar")
local rodRemote = RF:WaitForChild("ChargeFishingRod")
local miniGameRemote = RF:WaitForChild("RequestFishingMinigameStarted")
local finishRemote = RE:WaitForChild("FishingCompleted")

print("[AutoFish] ✅ Remotes loaded successfully!")

--=== STATE VARS ===--
local autofish = false
local perfectCast = false
local autoRecastDelay = 2.5
local fishCount = 0

--=== UI SETUP ===--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
	Name = "🐟 Fish It | Auto Fishing",
	Theme = "Default",
	LoadingTitle = "🎣 Loading AutoFish...",
	LoadingSubtitle = "by GPT-5",
	ConfigurationSaving = {
		Enabled = false
	}
})

local MainTab = Window:CreateTab("Main", 4483362458)
local InfoSection = MainTab:CreateSection("Status")
local ControlSection = MainTab:CreateSection("Controls")

-- Label Counter
local fishLabel = MainTab:CreateLabel("🐟 Fish Caught: 0")

--=== AUTO FISH FUNCTION ===--
local function startAutoFish()
	task.spawn(function()
		while autofish do
			pcall(function()
				equipRemote:FireServer(1)
				task.wait(0.2)

				local timestamp = perfectCast and 9999999999 or (tick() + math.random())
				rodRemote:InvokeServer(timestamp)
				task.wait(0.2)

				local x = perfectCast and -1.238 or (math.random(-1000, 1000) / 1000)
				local y = perfectCast and 0.969 or (math.random(0, 1000) / 1000)
				miniGameRemote:InvokeServer(x, y)

				task.wait(1.3)
				finishRemote:FireServer()
				fishCount += 1
				fishLabel:Set("🐟 Fish Caught: " .. fishCount)
				print(string.format("[AutoFish] 🎣 Fish caught! Total: %d", fishCount))
			end)
			task.wait(autoRecastDelay)
		end
	end)
end

--=== GUI CONTROLS ===--
MainTab:CreateToggle({
	Name = "🎣 Enable Auto Fishing",
	CurrentValue = false,
	Flag = "AutoFishToggle",
	Callback = function(val)
		autofish = val
		if val then
			print("[AutoFish] ▶ Started Auto Fishing")
			startAutoFish()
		else
			print("[AutoFish] ⏹ Stopped Auto Fishing")
		end
	end
})

MainTab:CreateToggle({
	Name = "✨ Use Perfect Cast",
	CurrentValue = false,
	Flag = "PerfectCastToggle",
	Callback = function(val)
		perfectCast = val
		print("[AutoFish] Perfect Cast:", val)
	end
})

MainTab:CreateSlider({
	Name = "⏱️ Auto Recast Delay (seconds)",
	Range = {0.5, 5},
	Increment = 0.1,
	CurrentValue = autoRecastDelay,
	Flag = "DelaySlider",
	Callback = function(val)
		autoRecastDelay = val
		print(string.format("[AutoFish] Recast Delay set to %.1f sec", val))
	end
})

--=== CLOSE GUI BUTTON ===--
MainTab:CreateButton({
	Name = "❌ Close GUI",
	Callback = function()
		Rayfield:Destroy()
		print("[AutoFish] GUI closed manually by user.")
	end
})
