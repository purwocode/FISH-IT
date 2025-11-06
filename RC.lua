-- ⚡ AUTO FISH 3X + TELEPORT (Dragable + Minimize)
-- by GPT-5

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Remotes
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local chargeRodRemote = net["RF/ChargeFishingRod"]
local miniGameRemote = net["RF/RequestFishingMinigameStarted"]
local fishingCompletedRemote = net["RE/FishingCompleted"]
local equipRemote = net["RE/EquipToolFromHotbar"]
local REFishCaught = net["RE/FishCaught"]
local RFSellAllItems = net["RF/SellAllItems"] -- RemoteFunction

-- State
local autoFish = false
local loopTask = nil
local minimized = false
local dragging = false
local dragInput, dragStart, startPos

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

-- Listener REFishCaught
REFishCaught.OnClientEvent:Connect(function(fishName, fishData)
    if autoFish then
        print("[🎣] Fish caught:", fishName, "Weight:", fishData.Weight)
        equipRodFast()
        instantRecast()
    end
end)

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

local function teleportTo(location)
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(location + Vector3.new(0, 5, 0))
    end
end

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "FishTeleportGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 500)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "🎣 Auto Fish + Teleport"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- Drag functionality
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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
    stopLoop()
    gui:Destroy()
end)

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 0)
minimizeButton.Text = "➖"
minimizeButton.TextColor3 = Color3.new(1,1,1)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 16
minimizeButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeButton.Parent = frame

-- Menu buttons
local btnAutoFishMenu = Instance.new("TextButton")
btnAutoFishMenu.Size = UDim2.new(0, 120, 0, 30)
btnAutoFishMenu.Position = UDim2.new(0, 20, 0, 40)
btnAutoFishMenu.Text = "🎣 Auto Fish"
btnAutoFishMenu.BackgroundColor3 = Color3.fromRGB(50,50,50)
btnAutoFishMenu.TextColor3 = Color3.new(1,1,1)
btnAutoFishMenu.Font = Enum.Font.SourceSansBold
btnAutoFishMenu.TextSize = 14
btnAutoFishMenu.Parent = frame

local btnTeleportMenu = Instance.new("TextButton")
btnTeleportMenu.Size = UDim2.new(0, 120, 0, 30)
btnTeleportMenu.Position = UDim2.new(0, 150, 0, 40)
btnTeleportMenu.Text = "📍 Teleport"
btnTeleportMenu.BackgroundColor3 = Color3.fromRGB(50,50,50)
btnTeleportMenu.TextColor3 = Color3.new(1,1,1)
btnTeleportMenu.Font = Enum.Font.SourceSansBold
btnTeleportMenu.TextSize = 14
btnTeleportMenu.Parent = frame

-- Panels
local autoFishPanel = Instance.new("Frame")
autoFishPanel.Size = UDim2.new(1, -20, 1, -90)
autoFishPanel.Position = UDim2.new(0, 10, 0, 80)
autoFishPanel.BackgroundTransparency = 1
autoFishPanel.Visible = false
autoFishPanel.Parent = frame

local teleportPanel = Instance.new("ScrollingFrame")
teleportPanel.Size = UDim2.new(1, -20, 1, -90)
teleportPanel.Position = UDim2.new(0, 10, 0, 80)
teleportPanel.CanvasSize = UDim2.new(0,0,0,0)
teleportPanel.ScrollBarThickness = 8
teleportPanel.BackgroundTransparency = 1
teleportPanel.Visible = false
teleportPanel.Parent = frame

local uilist = Instance.new("UIListLayout")
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0,5)
uilist.Parent = teleportPanel

-- Auto Fish toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0,240,0,35)
toggleButton.Position = UDim2.new(0,0,0,0)
toggleButton.Text = "▶️ Start Auto Fish"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
toggleButton.Parent = autoFishPanel

toggleButton.MouseButton1Click:Connect(function()
    autoFish = not autoFish
    toggleButton.Text = autoFish and "⏹ Stop Auto Fish" or "▶️ Start Auto Fish"
    if autoFish then
        startLoop()
    else
        stopLoop()
    end
end)

-- Teleport buttons
for name, coords in pairs(teleportPoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = "📍 "..name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40,40,80)
    btn.Parent = teleportPanel

    btn.MouseButton1Click:Connect(function()
        teleportTo(coords)
        print("[🌍] Teleported to "..name)
    end)
end

-- Menu toggle
btnAutoFishMenu.MouseButton1Click:Connect(function()
    autoFishPanel.Visible = true
    teleportPanel.Visible = false
end)

btnTeleportMenu.MouseButton1Click:Connect(function()
    autoFishPanel.Visible = false
    teleportPanel.Visible = true
end)

-- Minimize toggle
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    autoFishPanel.Visible = not minimized
    teleportPanel.Visible = not minimized
    btnAutoFishMenu.Visible = not minimized
    btnTeleportMenu.Visible = not minimized
end)

-- Sell all fish button
local sellAllButton = Instance.new("TextButton")
sellAllButton.Size = UDim2.new(0,240,0,35)
sellAllButton.Position = UDim2.new(0,0,0,45)
sellAllButton.Text = "💰 Sell All Fish"
sellAllButton.TextColor3 = Color3.new(1,1,1)
sellAllButton.Font = Enum.Font.SourceSansBold
sellAllButton.TextSize = 16
sellAllButton.BackgroundColor3 = Color3.fromRGB(60,45,45)
sellAllButton.Parent = autoFishPanel

sellAllButton.MouseButton1Click:Connect(function()
    pcall(function()
        RFSellAllItems:InvokeServer()
        print("[💰] All fish sold!")
    end)
end)

print("[✅] Dragable Auto Fish & Teleport GUI Loaded — by GPT-5")
