-- =========================================================================
--   💠 KEY STEAM NASI RENDANG HUB - PHIÊN BẢN CHUẨN GIAO DIỆN (PHẦN 1/4) 💠
-- =========================================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local KeyUrl = "https://link4m.net/PBXEqaD"
local TargetScriptUrl = "https://raw.githubusercontent.com/robvxs24/freemium/refs/heads/main/saegg.lua"

local KeyFileName = "NasiRendang_KeyData.json"
local TrialFileName = "NasiRendang_TrialData.json"
local TRIAL_DURATION = 300 -- 5 phút = 300 giây

local InitialGuis = {}
local ScriptConnections = {}
local ActiveBlurEffect = nil
local InputBlockerScreen = nil
local OpenKeySystemUI = nil

-- MODULE MÃ HÓA & LƯU TRỮ CHỐNG SỬA FILE (HEX-XOR)
local CIPHER_KEY = 88

local function EncryptData(str)
    local hex = {}
    for i = 1, #str do
        table.insert(hex, string.format("%02X", bit32.bxor(string.byte(str, i), CIPHER_KEY)))
    end
    return table.concat(hex)
end

local function DecryptData(hexStr)
    local res = {}
    for i = 1, #hexStr, 2 do
        local b = tonumber(hexStr:sub(i, i + 1), 16)
        if not b then return nil end
        table.insert(res, string.char(bit32.bxor(b, CIPHER_KEY)))
    end
    return table.concat(res)
end

local function LoadTrialData()
    if isfile and readfile and isfile(TrialFileName) then
        local ok, raw = pcall(readfile, TrialFileName)
        if ok and raw and raw ~= "" then
            local dec = DecryptData(raw)
            if dec then
                local parseOk, data = pcall(function() return HttpService:JSONDecode(dec) end)
                if parseOk and type(data) == "table" and data.StartTime and data.LastSeen then
                    if os.time() < data.LastSeen then
                        return { StartTime = 0, LastSeen = os.time(), Tampered = true }
                    end
                    return data
                end
            end
        end
    end
    return nil
end

local function SaveTrialData(startTime, lastSeen)
    if writefile then
        pcall(function()
            local data = { StartTime = startTime, LastSeen = lastSeen or os.time(), Duration = TRIAL_DURATION }
            writefile(TrialFileName, EncryptData(HttpService:JSONEncode(data)))
        end)
    end
end

local function GetKeyRemainingTime()
    if isfile and readfile and isfile(KeyFileName) then
        local ok, content = pcall(readfile, KeyFileName)
        if ok and content and content ~= "" then
            local decOk, data = pcall(function() return HttpService:JSONDecode(content) end)
            if decOk and type(data) == "table" and data.ExpireTimestamp then
                local left = data.ExpireTimestamp - os.time()
                if left > 0 then return left end
            end
        end
    end
    return nil
end

local function Save24hKey()
    if writefile then
        pcall(function()
            writefile(KeyFileName, HttpService:JSONEncode({ ExpireTimestamp = os.time() + 86400 }))
        end)
    end
end

-- Thuật toán sinh mã Key nasirendangfree đồng bộ GMT+7 với trang web
local function GenerateTodayKey()
    local vnTime = os.time() + (7 * 3600)
    local d = os.date("!*t", vnTime)
    local v1 = (d.day * 4391 + d.month * 2803 + d.year * 79) % 65535
    local v2 = (d.day * 6719 + d.month * 5147 + d.year * 199) % 65535
    local v3 = (d.day * 3889 + d.month * 8191 + d.year * 313) % 65535
    return string.format("nasirendangfree-%04X-%04X-%04X", v1, v2, v3)
end
-- =========================================================================
--   💠 KEY STEAM NASI RENDANG HUB - PHIÊN BẢN CHUẨN GIAO DIỆN (PHẦN 2/4) 💠
-- =========================================================================

local function TakeGuiSnapshot()
    table.clear(InitialGuis)
    local containers = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
    for _, c in ipairs(containers) do
        if c then
            for _, child in ipairs(c:GetChildren()) do
                InitialGuis[child] = true
            end
        end
    end
end

local function ApplyScreenLockdown()
    if not ActiveBlurEffect then
        ActiveBlurEffect = Instance.new("BlurEffect")
        ActiveBlurEffect.Name = "NasiRendang_LockdownBlur"
        ActiveBlurEffect.Size = 28
        ActiveBlurEffect.Parent = Lighting
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.PlatformStand = true
        end
        if hrp then
            hrp.Anchored = true
        end
    end

    if not InputBlockerScreen then
        InputBlockerScreen = Instance.new("ScreenGui")
        InputBlockerScreen.Name = "NasiRendang_InputBlocker"
        InputBlockerScreen.ResetOnSpawn = false
        pcall(function() InputBlockerScreen.Parent = CoreGui end)
        if not InputBlockerScreen.Parent then InputBlockerScreen.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local shield = Instance.new("TextButton")
        shield.Size = UDim2.new(1, 0, 1, 0)
        shield.Position = UDim2.new(0, 0, 0, 0)
        shield.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shield.BackgroundTransparency = 0.45
        shield.Text = ""
        shield.AutoButtonColor = false
        shield.Active = true
        shield.ZIndex = 15
        shield.Parent = InputBlockerScreen
    end
end

local function RemoveScreenLockdown()
    if ActiveBlurEffect then
        ActiveBlurEffect:Destroy()
        ActiveBlurEffect = nil
    end
    if InputBlockerScreen then
        InputBlockerScreen:Destroy()
        InputBlockerScreen = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.PlatformStand = false
        end
        if hrp then
            hrp.Anchored = false
        end
    end
end

local function TerminateTargetScript()
    getgenv().NasiRendang_Active = false
    getgenv().NasiRendang_TrialExpired = true

    for _, conn in ipairs(ScriptConnections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(ScriptConnections)

    local containers = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
    for _, c in ipairs(containers) do
        if c then
            for _, child in ipairs(c:GetChildren()) do
                if not InitialGuis[child] and child.Name ~= "NasiRendang_GetKeyUI" and child.Name ~= "NasiRendang_ToastUI" and child.Name ~= "NasiRendang_InputBlocker" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function LaunchTargetScriptWithWatcher()
    TakeGuiSnapshot()
    getgenv().NasiRendang_Active = true

    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet(TargetScriptUrl))()
        end)
    end)
end

local function FormatTime(seconds)
    if seconds < 0 then seconds = 0 end
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d phút %02d giây", m, s)
end

local ActiveToastLabel = nil

local function ShowLiveToast(titleText, initialSeconds, color)
    if CoreGui:FindFirstChild("NasiRendang_ToastUI") then CoreGui.NasiRendang_ToastUI:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("NasiRendang_ToastUI") then
        LocalPlayer.PlayerGui.NasiRendang_ToastUI:Destroy()
    end

    local ToastGui = Instance.new("ScreenGui")
    ToastGui.Name = "NasiRendang_ToastUI"
    ToastGui.ResetOnSpawn = false
    pcall(function() ToastGui.Parent = CoreGui end)
    if not ToastGui.Parent then ToastGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local ToastFrame = Instance.new("Frame")
    ToastFrame.Size = UDim2.new(0, 370, 0, 74)
    ToastFrame.Position = UDim2.new(0.5, -185, 0, -100)
    ToastFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    ToastFrame.BorderSizePixel = 0
    ToastFrame.ZIndex = 50
    ToastFrame.Parent = ToastGui

    Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 14)
    local Stroke = Instance.new("UIStroke", ToastFrame)
    Stroke.Thickness = 1.6
    Stroke.Color = color or Color3.fromRGB(139, 92, 246)

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 42, 1, 0)
    Icon.Position = UDim2.new(0, 8, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "💠"
    Icon.TextSize = 22
    Icon.ZIndex = 51
    Icon.Parent = ToastFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 20)
    Title.Position = UDim2.new(0, 50, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = color or Color3.fromRGB(196, 181, 253)
    Title.TextSize = 11.5
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 51
    Title.Parent = ToastFrame

    local Msg = Instance.new("TextLabel")
    Msg.Size = UDim2.new(1, -60, 0, 20)
    Msg.Position = UDim2.new(0, 50, 0, 32)
    Msg.BackgroundTransparency = 1
    Msg.Text = "Thời gian thử nghiệm còn: " .. FormatTime(initialSeconds)
    Msg.TextColor3 = Color3.fromRGB(226, 232, 240)
    Msg.TextSize = 11
    Msg.Font = Enum.Font.GothamBold
    Msg.TextXAlignment = Enum.TextXAlignment.Left
    Msg.ZIndex = 51
    Msg.Parent = ToastFrame

    ActiveToastLabel = Msg

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -20, 0, 3)
    BarBg.Position = UDim2.new(0, 10, 1, -6)
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    BarBg.BorderSizePixel = 0
    BarBg.ZIndex = 51
    BarBg.Parent = ToastFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 1, 0)
    Bar.BackgroundColor3 = color or Color3.fromRGB(139, 92, 246)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 52
    Bar.Parent = BarBg

    TweenService:Create(ToastFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -185, 0, 25) }):Play()
    TweenService:Create(Bar, TweenInfo.new(10, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

    task.delay(10, function()
        if ToastFrame and ToastFrame.Parent then
            local t = TweenService:Create(ToastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -185, 0, -100), BackgroundTransparency = 1 })
            t:Play()
            t.Completed:Connect(function()
                if ToastGui and ToastGui.Parent then ToastGui:Destroy() end
                ActiveToastLabel = nil
            end)
        end
    end)
end
-- =========================================================================
--   💠 KEY STEAM NASI RENDANG HUB - PHIÊN BẢN CHUẨN GIAO DIỆN (PHẦN 3/4) 💠
-- =========================================================================

local function PlayDeepBounce(btn)
    local origSize = btn.Size
    local origPos = btn.Position
    local shrinkSize = UDim2.new(origSize.X.Scale, origSize.X.Offset - 6, origSize.Y.Scale, origSize.Y.Offset - 4)
    local shrinkPos = UDim2.new(origPos.X.Scale, origPos.X.Offset + 3, origPos.Y.Scale, origPos.Y.Offset + 2)
    
    local t1 = TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = shrinkSize, Position = shrinkPos })
    local t2 = TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = origSize, Position = origPos })
    t1:Play()
    t1.Completed:Connect(function() t2:Play() end)
end

OpenKeySystemUI = function()
    if CoreGui:FindFirstChild("NasiRendang_GetKeyUI") then CoreGui.NasiRendang_GetKeyUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NasiRendang_GetKeyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Khung Form Chính Bo Góc Giống Ảnh Mẫu 5345.jpg
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 420, 0, 310)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 19, 24)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 30
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0.5

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.2
    MainStroke.Color = Color3.fromRGB(40, 42, 54)

    -- HEADER TOP BAR
    local HeaderBar = Instance.new("Frame")
    HeaderBar.Size = UDim2.new(1, -24, 0, 40)
    HeaderBar.Position = UDim2.new(0, 12, 0, 10)
    HeaderBar.BackgroundTransparency = 1
    HeaderBar.ZIndex = 31
    HeaderBar.Parent = MainFrame

    -- Mini Logo NRL Tròn
    local MiniLogo = Instance.new("Frame")
    MiniLogo.Size = UDim2.new(0, 26, 0, 26)
    MiniLogo.Position = UDim2.new(0, 0, 0.5, -13)
    MiniLogo.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
    MiniLogo.ZIndex = 32
    MiniLogo.Parent = HeaderBar
    Instance.new("UICorner", MiniLogo).CornerRadius = UDim.new(1, 0)
    local MiniLogoStroke = Instance.new("UIStroke", MiniLogo)
    MiniLogoStroke.Color = Color3.fromRGB(60, 64, 82)

    local MiniLogoTxt = Instance.new("TextLabel")
    MiniLogoTxt.Size = UDim2.new(1, 0, 1, 0)
    MiniLogoTxt.BackgroundTransparency = 1
    MiniLogoTxt.Text = "NRL"
    MiniLogoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniLogoTxt.TextSize = 9
    MiniLogoTxt.Font = Enum.Font.GothamBlack
    MiniLogoTxt.ZIndex = 33
    MiniLogoTxt.Parent = MiniLogo

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 0, 18)
    TitleLabel.Position = UDim2.new(0, 34, 0, 2)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Key Steam Nasi Rendang Hub"
    TitleLabel.TextColor3 = Color3.fromRGB(240, 242, 248)
    TitleLabel.TextSize = 12
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 32
    TitleLabel.Parent = HeaderBar

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Size = UDim2.new(1, -80, 0, 14)
    SubTitleLabel.Position = UDim2.new(0, 34, 0, 20)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Text = "Free Script Loader"
    SubTitleLabel.TextColor3 = Color3.fromRGB(130, 135, 150)
    SubTitleLabel.TextSize = 9.5
    SubTitleLabel.Font = Enum.Font.GothamMedium
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.ZIndex = 32
    SubTitleLabel.Parent = HeaderBar

    -- Nút đóng góc phải
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -24, 0.5, -12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 155, 170)
    CloseBtn.TextSize = 10
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 32
    CloseBtn.Parent = HeaderBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    -- LOGO TRUNG TÂM NRL (THEO CHUẨN ẢNH)
    local CenterLogoBox = Instance.new("Frame")
    CenterLogoBox.Size = UDim2.new(0, 56, 0, 56)
    CenterLogoBox.Position = UDim2.new(0.5, -28, 0, 54)
    CenterLogoBox.BackgroundColor3 = Color3.fromRGB(24, 25, 33)
    CenterLogoBox.ZIndex = 31
    CenterLogoBox.Parent = MainFrame
    Instance.new("UICorner", CenterLogoBox).CornerRadius = UDim.new(0, 16)
    local CenterLogoStroke = Instance.new("UIStroke", CenterLogoBox)
    CenterLogoStroke.Color = Color3.fromRGB(45, 48, 62)
    CenterLogoStroke.Thickness = 1.2

    local CenterLogoTxt = Instance.new("TextLabel")
    CenterLogoTxt.Size = UDim2.new(1, 0, 1, 0)
    CenterLogoTxt.BackgroundTransparency = 1
    CenterLogoTxt.Text = "NRL"
    CenterLogoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    CenterLogoTxt.TextSize = 18
    CenterLogoTxt.Font = Enum.Font.GothamBlack
    CenterLogoTxt.ZIndex = 32
    CenterLogoTxt.Parent = CenterLogoBox

    -- DÒNG CHỮ TIÊU ĐỀ TRUNG TÂM
    local CenterTitle = Instance.new("TextLabel")
    CenterTitle.Size = UDim2.new(1, -30, 0, 20)
    CenterTitle.Position = UDim2.new(0, 15, 0, 116)
    CenterTitle.BackgroundTransparency = 1
    CenterTitle.Text = "Nasi Rendang LUA Free Script"
    CenterTitle.TextColor3 = Color3.fromRGB(245, 247, 250)
    CenterTitle.TextSize = 13
    CenterTitle.Font = Enum.Font.GothamBlack
    CenterTitle.ZIndex = 31
    CenterTitle.Parent = MainFrame

    local CenterSub = Instance.new("TextLabel")
    CenterSub.Size = UDim2.new(1, -30, 0, 16)
    CenterSub.Position = UDim2.new(0, 15, 0, 136)
    CenterSub.BackgroundTransparency = 1
    CenterSub.Text = "in game: Lấy trộm một quả trứng"
    CenterSub.TextColor3 = Color3.fromRGB(130, 135, 150)
    CenterSub.TextSize = 10
    CenterSub.Font = Enum.Font.GothamMedium
    CenterSub.ZIndex = 31
    CenterSub.Parent = MainFrame

    -- Ô NHẬP KEY (PASTE YOUR KEY)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -36, 0, 38)
    InputBox.Position = UDim2.new(0, 18, 0, 162)
    InputBox.BackgroundColor3 = Color3.fromRGB(24, 25, 33)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderColor3 = Color3.fromRGB(110, 115, 130)
    InputBox.PlaceholderText = "Paste your key (Standard / Lifetime)"
    InputBox.Text = ""
    InputBox.TextSize = 11.5
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.ClearTextOnFocus = false
    InputBox.ZIndex = 31
    InputBox.Parent = MainFrame
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 10)
    local InputStroke = Instance.new("UIStroke", InputBox)
    InputStroke.Color = Color3.fromRGB(38, 41, 52)

    -- HÀNG NÚT: GET KEY & CHECK KEY (ĐÃ BỎ NÚT GOLD VÀ DISCORD)
    local ButtonsRow = Instance.new("Frame")
    ButtonsRow.Size = UDim2.new(1, -36, 0, 42)
    ButtonsRow.Position = UDim2.new(0, 18, 0, 210)
    ButtonsRow.BackgroundTransparency = 1
    ButtonsRow.ZIndex = 31
    ButtonsRow.Parent = MainFrame

    -- NÚT 1: GET KEY (Tông xám tối thanh lịch)
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.5, -6, 1, 0)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    GetKeyBtn.Text = "GET KEY"
    GetKeyBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
    GetKeyBtn.TextSize = 11.5
    GetKeyBtn.Font = Enum.Font.GothamBlack
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.ZIndex = 32
    GetKeyBtn.Parent = ButtonsRow
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)
    local GetKeyStroke = Instance.new("UIStroke", GetKeyBtn)
    GetKeyStroke.Color = Color3.fromRGB(45, 48, 62)

    -- NÚT 2: CHECK KEY (Phủ màu tím phát quang như ảnh mẫu)
    local CheckKeyBtn = Instance.new("TextButton")
    CheckKeyBtn.Size = UDim2.new(0.5, -6, 1, 0)
    CheckKeyBtn.Position = UDim2.new(0.5, 6, 0, 0)
    CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(46, 28, 70)
    CheckKeyBtn.Text = "CHECK KEY"
    CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CheckKeyBtn.TextSize = 11.5
    CheckKeyBtn.Font = Enum.Font.GothamBlack
    CheckKeyBtn.AutoButtonColor = false
    CheckKeyBtn.ZIndex = 32
    CheckKeyBtn.Parent = ButtonsRow
    Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 10)
    local CheckStroke = Instance.new("UIStroke", CheckKeyBtn)
    CheckStroke.Color = Color3.fromRGB(139, 92, 246)
    CheckStroke.Thickness = 1.4

    -- BANNER THÔNG BÁO TRẠNG THÁI NHỎ GỌN DƯỚI CÙNG
    local StatusMsg = Instance.new("TextLabel")
    StatusMsg.Size = UDim2.new(1, -36, 0, 24)
    StatusMsg.Position = UDim2.new(0, 18, 0, 264)
    StatusMsg.BackgroundTransparency = 1
    StatusMsg.Text = "⏱ Hạn dùng: 24 tiếng kể từ khi kích hoạt"
    StatusMsg.TextColor3 = Color3.fromRGB(120, 125, 140)
    StatusMsg.TextSize = 10
    StatusMsg.Font = Enum.Font.GothamMedium
    StatusMsg.ZIndex = 31
    StatusMsg.Parent = MainFrame
    -- =========================================================================
--   💠 KEY STEAM NASI RENDANG HUB - PHIÊN BẢN CHUẨN GIAO DIỆN (PHẦN 4/4) 💠
-- =========================================================================

    -- Animation mở giao diện
    MainFrame.BackgroundTransparency = 1
    MainScale.Scale = 0.4
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

    -- Bấm đóng giao diện
    CloseBtn.MouseButton1Click:Connect(function()
        PlayDeepBounce(CloseBtn)
        TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.4 }):Play()
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    -- Sự kiện bấm nút GET KEY (Copy link)
    GetKeyBtn.MouseButton1Click:Connect(function()
        PlayDeepBounce(GetKeyBtn)
        if setclipboard then setclipboard(KeyUrl) elseif toclipboard then toclipboard(KeyUrl) end
        
        GetKeyBtn.Text = "COPIED LINK!"
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 48, 38)
        GetKeyStroke.Color = Color3.fromRGB(52, 211, 153)
        StatusMsg.Text = "📋 Đã sao chép link nhận key vào bộ nhớ tạm!"
        StatusMsg.TextColor3 = Color3.fromRGB(52, 211, 153)

        task.delay(2.5, function()
            if GetKeyBtn and GetKeyBtn.Parent then
                GetKeyBtn.Text = "GET KEY"
                GetKeyBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
                GetKeyStroke.Color = Color3.fromRGB(45, 48, 62)
                StatusMsg.Text = "⏱ Hạn dùng: 24 tiếng kể từ khi kích hoạt"
                StatusMsg.TextColor3 = Color3.fromRGB(120, 125, 140)
            end
        end)
    end)

    -- Sự kiện bấm nút CHECK KEY (Kích hoạt bản quyền)
    local isChecking = false
    CheckKeyBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        isChecking = true
        PlayDeepBounce(CheckKeyBtn)

        CheckKeyBtn.Text = "CHECKING..."
        StatusMsg.Text = "⏳ Đang xác thực thông tin bản quyền trên hệ thống..."
        StatusMsg.TextColor3 = Color3.fromRGB(196, 181, 253)

        task.wait(0.45)
        local enteredKey = string.gsub(InputBox.Text, "%s+", "")
        local todayKey = GenerateTodayKey()

        if string.lower(enteredKey) == string.lower(todayKey) then
            Save24hKey()
            CheckKeyBtn.Text = "SUCCESS"
            CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(22, 101, 52)
            CheckStroke.Color = Color3.fromRGB(74, 222, 128)
            StatusMsg.Text = "✔ Xác thực thành công! Đang khởi chạy script..."
            StatusMsg.TextColor3 = Color3.fromRGB(74, 222, 128)

            RemoveScreenLockdown()
            LaunchTargetScriptWithWatcher()

            task.wait(0.4)
            TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.5 }):Play()
            task.wait(0.25)
            ScreenGui:Destroy()
        else
            isChecking = false
            CheckKeyBtn.Text = "CHECK KEY"
            StatusMsg.Text = "✖ Mã Key không chính xác hoặc đã hết hạn!"
            StatusMsg.TextColor3 = Color3.fromRGB(239, 68, 68)

            InputStroke.Color = Color3.fromRGB(239, 68, 68)
            task.wait(0.6)
            InputStroke.Color = Color3.fromRGB(38, 41, 52)
        end
    end)
end

-- =========================================================================
--   LUỒNG CHÍNH ĐẾM NGƯỢC 5 PHÚT & BẢO MẬT KHÓA MÀN HÌNH
-- =========================================================================

local keyTimeLeft = GetKeyRemainingTime()
if keyTimeLeft and keyTimeLeft > 0 then
    ShowLiveToast("KEY STEAM NASI RENDANG • BẢN QUYỀN", keyTimeLeft, Color3.fromRGB(139, 92, 246))
    LaunchTargetScriptWithWatcher()
    return
end

local trialData = LoadTrialData()

if not trialData then
    trialData = { StartTime = os.time(), LastSeen = os.time() }
    SaveTrialData(trialData.StartTime, trialData.LastSeen)
end

if trialData.Tampered then
    ApplyScreenLockdown()
    ShowLiveToast("⚠️ BẢO MẬT: PHÁT HIỆN GIAN LẬN", 0, Color3.fromRGB(239, 68, 68))
    OpenKeySystemUI()
    return
end

local targetEndTime = trialData.StartTime + TRIAL_DURATION
local remaining = targetEndTime - os.time()

if remaining <= 0 then
    ApplyScreenLockdown()
    ShowLiveToast("⚠️ HẾT THỜI GIAN DÙNG THỬ", 0, Color3.fromRGB(239, 68, 68))
    OpenKeySystemUI()
    return
else
    ShowLiveToast("NASI RENDANG • ĐANG DÙNG THỬ (TRIAL)", remaining, Color3.fromRGB(139, 92, 246))
    LaunchTargetScriptWithWatcher()

    task.spawn(function()
        local saveInterval = 0

        while true do
            task.wait(1)
            local currentRemaining = targetEndTime - os.time()

            if ActiveToastLabel and ActiveToastLabel.Parent then
                ActiveToastLabel.Text = "Thời gian thử nghiệm còn: " .. FormatTime(currentRemaining)
            end

            saveInterval = saveInterval + 1
            if saveInterval >= 5 then
                saveInterval = 0
                SaveTrialData(trialData.StartTime, os.time())
            end

            if GetKeyRemainingTime() then return end

            if currentRemaining <= 0 then
                SaveTrialData(trialData.StartTime, os.time())
                TerminateTargetScript()
                ApplyScreenLockdown()
                ShowLiveToast("⚠️ HẾT THỜI GIAN DÙNG THỬ", 0, Color3.fromRGB(239, 68, 68))
                task.wait(0.3)
                OpenKeySystemUI()
                break
            end
        end
    end)
end
