-- 🧭 TELEPORT + SELL ALL GUI (No Auto Fish)
-- by GPT-5

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- 🛰️ Remotes
local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]

-- 📍 TELEPORT LOCATIONS
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

-- ✨ TELEPORT FUNCTION
local function teleportTo(location)
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(location + Vector3.new(0, 5, 0))
        print("[🌍] Teleported to location!")
    end
end

-- 🎨 GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportSellGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 500)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- 🏷️ Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "📍 Teleport + Sell All"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- 🖱️ Dragging Logic
local dragging, dragInput, dragStart, startPos
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

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- 🔘 Close Button
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
	gui:Destroy()
end)

-- 🔽 Minimize Button
local minimized = false
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 0)
minimizeButton.Text = "➖"
minimizeButton.TextColor3 = Color3.new(1,1,1)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 16
minimizeButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeButton.Parent = frame

-- 📜 Teleport Panel
local teleportPanel = Instance.new("ScrollingFrame")
teleportPanel.Size = UDim2.new(1, -20, 1, -80)
teleportPanel.Position = UDim2.new(0, 10, 0, 50)
teleportPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
teleportPanel.ScrollBarThickness = 8
teleportPanel.BackgroundTransparency = 1
teleportPanel.Parent = frame

local uilist = Instance.new("UIListLayout")
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0, 5)
uilist.Parent = teleportPanel

-- 🧭 Create teleport buttons
for name, coords in pairs(teleportPoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = "📍 " .. name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
    btn.Parent = teleportPanel

    btn.MouseButton1Click:Connect(function()
        teleportTo(coords)
        print("[🌍] Teleported to " .. name)
    end)
end

-- 💰 Sell All Button
local sellAllButton = Instance.new("TextButton")
sellAllButton.Size = UDim2.new(1, -20, 0, 40)
sellAllButton.Position = UDim2.new(0, 10, 1, -45)
sellAllButton.Text = "💰 SELL ALL FISH"
sellAllButton.TextColor3 = Color3.new(1, 1, 1)
sellAllButton.Font = Enum.Font.SourceSansBold
sellAllButton.TextSize = 16
sellAllButton.BackgroundColor3 = Color3.fromRGB(60, 45, 45)
sellAllButton.Parent = frame

sellAllButton.MouseButton1Click:Connect(function()
    pcall(function()
        RFSellAllItems:InvokeServer()
        print("[💰] All fish sold successfully!")
    end)
end)

-- Minimize logic
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    teleportPanel.Visible = not minimized
    sellAllButton.Visible = not minimized
end)

print("[✅] Teleport + Sell All GUI Loaded — by GPT-5")
