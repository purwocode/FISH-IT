--// 🎣 AUTO FISH GUI - Versi HyRexxyy Style (Fixed)
-- Pastikan Rayfield sudah di-load

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

-- 🔧 Lokasi Remote (mengikuti struktur sleitnick_net@0.2.0)
local net = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_net@0.2.0")
	:WaitForChild("net")

-- Pastikan folder RF dan RE ada
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

-- Remote penting
local equipRemote = RE:WaitForChild("EquipToolFromHotbar")
local rodRemote = RF:WaitForChild("ChargeFishingRod")
local miniGameRemote = RF:WaitForChild("RequestFishingMinigameStarted")
local finishRemote = RE:WaitForChild("FishingCompleted")

-- Variabel utama
local autofish = false
local perfectCast = false
local autoRecastDelay = 2
local fishCount = 0

-- ⚙️ GUI Setup
local Window = Rayfield:CreateWindow({
	Name = "🎣 Auto Fishing Hub",
	LoadingTitle = "Fishing AutoFarm",
	LoadingSubtitle = "By HyRexxyy x GPT",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AutoFishSettings"
	},
	KeySystem = false
})

local MainTab = Window:CreateTab("⚙️ Main Controls")
local CounterLabel = MainTab:CreateLabel("🐟 Fish Caught: 0")

-- 🎣 AUTO FISH TOGGLE
MainTab:CreateToggle({
	Name = "🎣 Enable Auto Fishing",
	CurrentValue = false,
	Callback = function(val)
		autofish = val

		if val then
			task.spawn(function()
				while autofish do
					pcall(function()
						-- Equip alat pancing
						equipRemote:FireServer(1)
						task.wait(0.1)

						-- Casting
						local timestamp = perfectCast and 9999999999 or (tick() + math.random())
						rodRemote:InvokeServer(timestamp)
						task.wait(0.2)

						-- Mini game
						local x = perfectCast and -1.238 or (math.random(-1000, 1000) / 1000)
						local y = perfectCast and 0.969 or (math.random(0, 1000) / 1000)
						miniGameRemote:InvokeServer(x, y)

						-- Reel & selesai
						task.wait(1.2)
						finishRemote:FireServer()

						-- Counter naik
						fishCount += 1
						CounterLabel:SetText("🐟 Fish Caught: " .. fishCount)
					end)
					task.wait(autoRecastDelay)
				end
			end)
		end
	end
})

-- ✨ PERFECT CAST TOGGLE
MainTab:CreateToggle({
	Name = "✨ Use Perfect Cast",
	CurrentValue = false,
	Callback = function(val)
		perfectCast = val
	end
})

-- ⏱️ RECAST DELAY SLIDER
MainTab:CreateSlider({
	Name = "⏱️ Auto Recast Delay (seconds)",
	Range = {0.5, 5},
	Increment = 0.1,
	CurrentValue = autoRecastDelay,
	Callback = function(val)
		autoRecastDelay = val
	end
})

-- ❌ CLOSE GUI BUTTON
MainTab:CreateButton({
	Name = "❌ Close GUI",
	Callback = function()
		autofish = false
		Rayfield:Destroy()
	end
})

-- ✅ Notifikasi awal
Rayfield:Notify({
	Title = "✅ AutoFish GUI Loaded",
	Content = "All remotes connected successfully!",
	Duration = 4
})
