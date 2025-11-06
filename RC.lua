-- ⚡ AUTO FISH + SELLSPECIFIC (Closeable GUI)
-- by GPT-5

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remotes
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local chargeRodRemote = net["RF/ChargeFishingRod"]
local miniGameRemote = net["RF/RequestFishingMinigameStarted"]
local fishingCompletedRemote = net["RE/FishingCompleted"]
local equipRemote = net["RE/EquipToolFromHotbar"]
local REFishCaught = net["RE/FishCaught"]
local RFSellAllItems = net["RF/SellAllItems"]

-- Config: nama ikan yang mau dijual otomatis
local fishToSell = {
    ["Golden Trout"] = true,
    ["Diamond Salmon"] = true,
}

-- State
local autoFish = false
local loopTask = nil

-- 🐟 AUTO FISH FUNCTIONS
local function instantRecast()
    pcall(function()
        chargeRodRemote:InvokeServer(miniGameRemote)
        miniGameRemote:InvokeServer(999999999999.999 + 9999999*9999999, 9999999.999)
        task.wait(2)
        fishingCompletedRemote:FireServer(999999999999.999 + 9999999*9999999, 9999999.999)
    end)
end

local function equipRodFast()
    pcall(function()
        equipRemote:FireServer(1)
    end)
end

-- Jual ikan tertentu
local function sellFish(fishName)
    if fishToSell[fishName] then
        pcall(function()
            RFSellAllItems:InvokeServer(fishName)
            print("[💰] Sold fish:", fishName)
        end)
    end
end

-- Event ketika ikan ditangkap
REFishCaught.OnClientEvent:Connect(function(fishName, fishData)
    if autoFish then
        print("[🎣] Fish caught:", fishName, "Weight:", fishData.Weight)
        equipRodFast()
        instantRecast()
        sellFish(fishName)
    end
end)

-- Loop auto fish
local function startLoop()
    if loopTask then return end
    loopTask = task.spawn(function()
        while autoFish do
            equipRodFast()
            instantRecast()
            task.wait(0.05)
        end
    end)
end

local function stopLoop()
    autoFish = false
    loopTask = nil
end

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFishGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.Text = "❌"
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.BackgroundColor3 = Color3.fromRGB(100,20,20)
closeButton.Parent = frame

closeButton.MouseButton1Click:Connect(function()
    stopLoop()          -- hentikan semua proses auto fish
    gui:Destroy()       -- hapus GUI
end)

-- Toggle Auto Fish Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 50)
toggleButton.Text = "▶️ Start Auto Fish"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
    autoFish = not autoFish
    toggleButton.Text = autoFish and "⏹ Stop Auto Fish" or "▶️ Start Auto Fish"
    if autoFish then
        startLoop()
    else
        stopLoop()
    end
end)

print("[✅] Auto Fish + Sell Specific GUI Loaded — Closeable & Functional")
