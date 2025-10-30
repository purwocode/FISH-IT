-- ⚡ AUTO INSTANT RECAST FISHER + TELEPORT MENU
-- by GPT-5

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Remotes
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local chargeRodRemote = net["RF/ChargeFishingRod"]
local miniGameRemote = net["RF/RequestFishingMinigameStarted"]
local fishingCompletedRemote = net["RE/FishingCompleted"]
local equipRemote = net["RE/EquipToolFromHotbar"]

-- State
local autoFish = false
local loopTask = nil

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "RecastFishGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 380)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🎣 Auto Fish + Teleport"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 35)
toggleButton.Position = UDim2.new(0, 20, 0, 40)
toggleButton.Text = "▶️ Start Auto Fish"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 200, 0, 35)
closeButton.Position = UDim2.new(0, 20, 0, 80)
closeButton.Text = "❌ Close GUI"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
closeButton.Parent = frame

-- 🧭 TELEPORT LOCATIONS
local teleportPoints = {
    ["CRYSTAL FALL"] = Vector3.new(-1957.25 , -440.00, 7385.86),
    ["CRYSTAL CAVERN"] = Vector3.new(-1609.50, -447.75, 7238.00),
    ["Sisyphus STATUE"] = Vector3.new(-3705.79, -135.24, -1021.82),
    ["Mount Hallow"] = Vector3.new(1796.60, 2.67, 3066.99),
    ["KOHANA"] = Vector3.new(-651.95, 17.25, 497.16),
    ["KOHANA VOLCANO"] = Vector3.new(-632.30, 55.56, 199.26),
    ["FISHERMAN ISLAND"] = Vector3.new(99.53, 9.53, 2792.58),
    ["ANCIENT JUNGLE"] = Vector3.new(1307.63, 5.83, -155.62),
    ["Sacred Temple"] = Vector3.new(1465.62, -21.88, -637.75)
}

-- Fungsi teleport
local function teleportTo(location)
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(location + Vector3.new(0, 5, 0))
    end
end

-- BUAT TOMBOL TELEPORT
local yOffset = 130
for name, coords in pairs(teleportPoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 20, 0, yOffset)
    btn.Text = "📍 " .. name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        teleportTo(coords)
        print("[🌍] Teleported to " .. name)
    end)

    yOffset = yOffset + 35
end

-- 🐟 FUNGSI UTAMA
local function ensureRodEquipped()
    local char = player.Character or player.CharacterAdded:Wait()
    local hasRod = char:FindFirstChildOfClass("Tool")
    if not hasRod then
        equipRemote:FireServer(1) -- ambil dari slot 1
        task.wait(0.2)
    end
end

local function instantRecast()
    pcall(function()
        ensureRodEquipped()
        chargeRodRemote:InvokeServer(workspace:GetServerTimeNow())
        task.wait(0.1)
        miniGameRemote:InvokeServer(-0.65 + math.random() * 0.05, 0.91)
        task.wait(2)
        fishingCompletedRemote:FireServer()
        task.wait(0.05)
    end)
end

local function startAutoFishing()
    if loopTask then return end
    autoFish = true
    loopTask = task.spawn(function()
        while autoFish do
            instantRecast()
            task.wait(0.05)
        end
    end)
end

local function stopAutoFishing()
    autoFish = false
    loopTask = nil
end

-- GUI Controls
toggleButton.MouseButton1Click:Connect(function()
    if not autoFish then
        toggleButton.Text = "⏹ Stop Auto Fish"
        startAutoFishing()
    else
        toggleButton.Text = "▶️ Start Auto Fish"
        stopAutoFishing()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    stopAutoFishing()
    gui:Destroy()
end)

print("[✅] Auto Fish + Teleport Loaded — by GPT-5")
