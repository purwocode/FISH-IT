
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- RemoteFunction untuk menjual item
local RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"]

-- ID ikan yang ingin dijual
local fishID = "Sea Shell"

-- GUI sederhana
local gui = Instance.new("ScreenGui")
gui.Name = "SellFishGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Parent = gui

-- Tombol untuk menjual ikan
local sellButton = Instance.new("TextButton")
sellButton.Size = UDim2.new(0, 200, 0, 50)
sellButton.Position = UDim2.new(0, 25, 0, 25)
sellButton.Text = "💰 Sell Fish"
sellButton.Parent = frame
sellButton.TextColor3 = Color3.new(1,1,1)
sellButton.Font = Enum.Font.SourceSansBold
sellButton.TextSize = 18
sellButton.BackgroundColor3 = Color3.fromRGB(70,70,70)

-- Tombol untuk menutup GUI
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.Text = "❌"
closeButton.Parent = frame
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.BackgroundColor3 = Color3.fromRGB(100,20,20)

-- Fungsi jual ikan
sellButton.MouseButton1Click:Connect(function()
    pcall(function()
        RFSellItem:InvokeServer(fishID)
        print("[💰] Sold fish with ID:", fishID)
    end)
end)

-- Fungsi close GUI
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
    print("[❌] Sell GUI closed.")
end)

