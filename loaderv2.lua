-- [[ RONNEI HUB - PERMANENT TOP TRANSPARENT WATERMARK ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- 1. CHẠY SCRIPT GỐC MỚI (SONG SONG)
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/robvxs24/freemium/refs/heads/main/saegg.lua"))()
    end)
end)

-- 2. TẠO GIAO DIỆN WATERMARK SÁT MÉP TRÊN + MỜ MỜ
local sg = Instance.new("ScreenGui")
sg.Name = "RonneiBypassWatermark"
sg.ResetOnSpawn = false

pcall(function() sg.Parent = CoreGui end)
if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Frame Chính (Đã thu gọn + Làm mờ background)
local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 360, 0, 52)
Card.Position = UDim2.new(0.5, -180, 0, -70)
Card.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
Card.BackgroundTransparency = 0.35 -- Mờ xuyên thấu phông nền
Card.BorderSizePixel = 0
Card.ClipsDescendants = true
Card.Parent = sg

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 10)
CardCorner.Parent = Card

-- Viền Glow Gradient Mờ Nhẹ
local CardStroke = Instance.new("UIStroke")
CardStroke.Thickness = 1.2
CardStroke.Transparency = 0.25
CardStroke.Color = Color3.fromRGB(255, 255, 255)
CardStroke.Parent = Card

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255))
})
StrokeGradient.Parent = CardStroke

-- Icon Badge
local Badge = Instance.new("Frame")
Badge.Size = UDim2.new(0, 30, 0, 30)
Badge.Position = UDim2.new(0, 10, 0.5, -15)
Badge.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
Badge.BackgroundTransparency = 0.4
Badge.BorderSizePixel = 0
Badge.Parent = Card

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = Badge

local BadgeText = Instance.new("TextLabel")
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "🔓"
BadgeText.TextSize = 14
BadgeText.Parent = Badge

-- Dòng Tiếng Việt
local TextVI = Instance.new("TextLabel")
TextVI.Size = UDim2.new(1, -50, 0, 18)
TextVI.Position = UDim2.new(0, 48, 0, 9)
TextVI.BackgroundTransparency = 1
TextVI.Text = "Script được bypass nokey bởi @ronnei7.htk"
TextVI.TextColor3 = Color3.fromRGB(245, 248, 255)
TextVI.Font = Enum.Font.GothamBold
TextVI.TextSize = 11
TextVI.TextXAlignment = Enum.TextXAlignment.Left
TextVI.Parent = Card

-- Dòng Tiếng Anh
local TextEN = Instance.new("TextLabel")
TextEN.Size = UDim2.new(1, -50, 0, 14)
TextEN.Position = UDim2.new(0, 48, 0, 27)
TextEN.BackgroundTransparency = 1
TextEN.Text = "Script bypassed (no key required) by @ronnei7.htk"
TextEN.TextColor3 = Color3.fromRGB(170, 190, 220)
TextEN.Font = Enum.Font.GothamMedium
TextEN.TextSize = 9.5
TextEN.TextXAlignment = Enum.TextXAlignment.Left
TextEN.Parent = Card

-- HIỆU ỨNG TRƯỢT LÊN TÍT ĐẦU MÀN HÌNH (Y = 2)
local tweenIn = TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -180, 0, 2)
})
tweenIn:Play()

-- XOAY ĐỔI MÀU VIỀN LIÊN TỤC (VĨNH VIỄN)
task.spawn(function()
    while Card and Card.Parent do
        StrokeGradient.Rotation = (StrokeGradient.Rotation + 2) % 360
        task.wait(0.03)
    end
end)
