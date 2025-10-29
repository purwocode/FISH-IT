
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remotes
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local chargeRodRemote = net["RF/ChargeFishingRod"]
local miniGameRemote = net["RF/RequestFishingMinigameStarted"]
local fishingCompletedRemote = net["RE/FishingCompleted"]

-- State
local autoFish = false
local loopTask = nil

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "RecastFishGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "▶️ Start Auto Fish"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 200, 0, 40)
closeButton.Position = UDim2.new(0, 10, 0, 60)
closeButton.Text = "❌ Close GUI"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
closeButton.Parent = frame

-- Fungsi utama
local function instantRecast()
    pcall(function()
        -- charge fishing rod
        chargeRodRemote:InvokeServer(workspace:GetServerTimeNow())
        task.wait(0.1)

        -- lempar pancingan (minigame)
        miniGameRemote:InvokeServer(-0.65 + math.random() * 0.05, 0.91)
        task.wait(2)

        -- selesai memancing (ikan langsung didapat)
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
            task.wait(0.05) -- jeda antar recast
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

print("[✅] Recast Auto Fishing Loaded — Tanpa Equip Rod.")
