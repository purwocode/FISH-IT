--// AUTO FISH GUI - Versi HyRexxyy Event-Based Multi-Rod Stable
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Lokasi Remote
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
local rodThreads = 2
local rodConnections = {}
local rodName = "FishingRod"

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

-- Fungsi untuk memastikan rod tersedia
local function GetRod()
    local rod = player.Backpack:FindFirstChild(rodName) or player.Character:FindFirstChild(rodName)
    if not rod then
        equipRemote:FireServer(1)
        task.wait(0.1)
        rod = player.Backpack:FindFirstChild(rodName) or player.Character:FindFirstChild(rodName)
    end
    return rod
end

-- Fungsi utama auto fish untuk satu rod
local function AutoFishCycle()
    pcall(function()
        local rodTool = GetRod()
        if not rodTool then return end

        local timestamp = perfectCast and 9999999999 or (tick() + math.random())
        rodRemote:InvokeServer(timestamp)
        task.wait(0.5)

        local x = perfectCast and -1.238 or (math.random(-1000,1000)/1000)
        local y = perfectCast and 0.969 or (math.random(0,1000)/1000)
        miniGameRemote:InvokeServer(x, y)

        -- Event-based detection
        local caught = false
        local connection
        connection = rodTool:GetAttributeChangedSignal("HasFish"):Connect(function()
            if rodTool:GetAttribute("HasFish") == true then
                caught = true
                connection:Disconnect()
            end
        end)

        -- Safety timer
        local timer = 0
        while not caught and timer < 15 do
            task.wait(0.1)
            timer += 0.1
        end

        -- Fire finishRemote dua kali
        finishRemote:FireServer()
        task.wait(0.1)
        finishRemote:FireServer()

        fishCount += 1
        CounterLabel:Set("🐟 Fish Caught: " .. fishCount)
    end)
end

-- Fungsi multi-rod
local function AutoFishMultiRod()
    -- hentikan semua thread sebelumnya
    for _, conn in pairs(rodConnections) do
        if conn then task.cancel(conn) end
    end
    rodConnections = {}

    for i = 1, rodThreads do
        local thread = task.spawn(function()
            while autofish do
                AutoFishCycle()
                task.wait(autoRecastDelay)
            end
        end)
        table.insert(rodConnections, thread)
    end
end

-- START / STOP AUTO FISH
MainTab:CreateToggle({
    Name = "🎣 Enable Auto Fishing",
    CurrentValue = false,
    Callback = function(val)
        autofish = val
        if val then
            AutoFishMultiRod()
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
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = autoRecastDelay,
    Callback = function(val)
        autoRecastDelay = val
    end
})

-- MULTI-ROD SLIDER
MainTab:CreateSlider({
    Name = "🎣 Number of Rods",
    Range = {1, 5},
    Increment = 1,
    CurrentValue = rodThreads,
    Callback = function(val)
        rodThreads = val
        if autofish then
            AutoFishMultiRod() -- restart threads jika sedang berjalan
        end
    end
})

-- CLOSE GUI BUTTON
MainTab:CreateButton({
    Name = "❌ Close GUI",
    Callback = function()
        autofish = false
        for _, conn in pairs(rodConnections) do
            if conn then task.cancel(conn) end
        end
        rodConnections = {}
        Rayfield:Destroy()
    end
})

-- Notifikasi awal
Rayfield:Notify({
    Title = "✅ AutoFish GUI Loaded",
    Content = "Stable multi-rod event-based fishing ready!",
    Duration = 4
})
