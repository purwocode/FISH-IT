
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote
local RFSellItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellItem"] -- RemoteFunction

-- Inventory (contoh, sesuaikan dengan path di game)
local inventoryFolder = player:WaitForChild("RE/ClaimNotification") -- ganti sesuai folder inventory sebenarnya

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "SellFishGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "💰 Sell Fish"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = frame

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 1, -50)
listFrame.Position = UDim2.new(0, 10, 0, 40)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 8
listFrame.BackgroundTransparency = 1
listFrame.Parent = frame

local uilist = Instance.new("UIListLayout")
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0,5)
uilist.Parent = listFrame

-- Fungsi untuk refresh daftar ikan
local function refreshInventory()
    listFrame:ClearAllChildren()
    for _, fish in ipairs(inventoryFolder:GetChildren()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = fish.Name
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        btn.Parent = listFrame

        btn.MouseButton1Click:Connect(function()
            pcall(function()
                RFSellItem:InvokeServer(fish) -- kirim objek fish langsung
                print("[💰] Sold fish:", fish.Name)
                fish:Destroy() -- hapus dari GUI/inventory lokal
                refreshInventory() -- refresh list
            end)
        end)
    end
end

refreshInventory()
