--// AUTO FISH GUI - Versi HyRexxyy Style
-- Pastikan Rayfield sudah di-load

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

-- Lokasi Remote (mengikuti struktur sleitnick_net@0.2.0)
local net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

-- Remote penting
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

-- Variabel utama
local autofish = false
local perfectCast = false
local autoRecastDelay = 2
local fishCount = 0

-- GUI Setup
local Window = Rayfield:CreateWindow({
    Name = "🎣 Auto Fishing Hub",
    LoadingTitle = "Fishing AutoFarm",
    LoadingSubtitle = "By HyRexxyy x GPT",
    ConfigurationSaving = { Enabled = true, FolderName = "AutoFishSettings" },
    KeySystem = false
})

local MainTab = Window:CreateTab("⚙️ Main Controls")
local CounterLabel = MainTab:CreateLabel("🐟 Fish Caught: 0")

-- START / STOP AUTO FISH
MainTab:CreateToggle({
    Name = "🎣 Enable Auto Fishing",
    CurrentValue = false,
    Callback = function(val)
        autofish = val
        if val then
            task.spawn(function()
                while autofish do
                    pcall(function()
                        -- Equip rod
                        equipRemote:FireServer(1)
                        task.wait(0.1)

                        -- Charge rod
                        local timestamp = perfectCast and 9999999999 or (tick() + math.random())
                        rodRemote:InvokeServer(timestamp)
                        task.wait(5) -- Tunggu rod siap

                        -- Random atau perfect cast
                        local x = perfectCast and -1.238 or (math.random(-1000,1000)/1000)
                        local y = perfectCast and 0.969 or (math.random(0,1000)/1000)

                        miniGameRemote:InvokeServer(x, y)

                        -- Tunggu ikan benar-benar tertangkap
                        local waitTime = 0
                        repeat
                            task.wait(0.5)
                            waitTime += 0.5
                        until waitTime >= 10 -- atau bisa sesuaikan kalau ingin menunggu lebih lama

                        -- Kirim finishRemote dua kali dengan delay kecil
                        finishRemote:FireServer()
                        task.wait(0.1)
                        finishRemote:FireServer()

                        -- Update counter
                        fishCount += 1
                        CounterLabel:Set("🐟 Fish Caught: " .. fishCount)
                    end)
                    task.wait(autoRecastDelay)
                end
            end)
        end
    end
})

-- PERFECT CAST OPTION
MainTab:CreateToggle({
    Name = "✨ Use Perfect Cast",
    CurrentValue = false,
    Callback = function(val)
        perfectCast = val
    end
})

-- DELAY SLIDER
MainTab:CreateSlider({
    Name = "⏱️ Auto Recast Delay (seconds)",
    Range = {0.5, 5},
    Increment = 0.1,
    CurrentValue = autoRecastDelay,
    Callback = function(val)
        autoRecastDelay = val
    end
})

-- CLOSE GUI BUTTON
MainTab:CreateButton({
    Name = "❌ Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Notifikasi awal
Rayfield:Notify({
    Title = "✅ AutoFish GUI Loaded",
    Content = "All remotes connected successfully!",
    Duration = 4
})
