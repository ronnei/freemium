-- =========================================================================
--   🍃 KEY STEAM ON HUB - FULL LOCKDOWN & INSTANT TERMINATOR ENGINE 🍃
-- =========================================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local KeyUrl = "https://link4m.org/Ehiwz"
local TutorialUrl = "https://cbrowse.github.io/browse/getkey.html"
local TargetScriptUrl = "https://raw.githubusercontent.com/robvxs24/freemium/refs/heads/main/script.lua"

local KeyFileName = "OnHub_KeyData.json"
local TrialFileName = "OnHub_TrialData.json"
local TRIAL_DURATION = 600 -- 10 phút = 600 giây

local InitialGuis = {}
local ScriptConnections = {}
local ActiveBlurEffect = nil
local InputBlockerScreen = nil
local OpenKeySystemUI = nil

-- =========================================================================
--   1. MODULE MÃ HÓA & LƯU TRỮ CHỐNG GIAN LẬN
-- =========================================================================
local CIPHER_KEY = 85

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

local function GenerateTodayKey()
    local vnTime = os.time() + (7 * 3600)
    local d = os.date("!*t", vnTime)
    local v1 = (d.day * 3141 + d.month * 2718 + d.year * 89) % 65535
    local v2 = (d.day * 5821 + d.month * 4111 + d.year * 193) % 65535
    local v3 = (d.day * 7333 + d.month * 6177 + d.year * 257) % 65535
    return string.format("onhubfreemium-%04X-%04X-%04X", v1, v2, v3)
end

-- =========================================================================
--   2. HỆ THỐNG KHÓA CỨNG: LÀM MỜ NỀN, ĐÓNG BĂNG & TIÊU DIỆT SCRIPT GỐC
-- =========================================================================

-- Chụp ảnh toàn bộ GUI đang có trước khi chạy script gốc
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

-- Kích hoạt làm mờ màn hình và chặn toàn bộ tương tác
local function ApplyScreenLockdown()
    -- 1. Làm mờ màn hình game qua Lighting
    if not ActiveBlurEffect then
        ActiveBlurEffect = Instance.new("BlurEffect")
        ActiveBlurEffect.Name = "OnHub_LockdownBlur"
        ActiveBlurEffect.Size = 28
        ActiveBlurEffect.Parent = Lighting
    end

    -- 2. Đóng băng nhân vật chơi
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

    -- 3. Màn chắn trong suốt hấp thụ toàn bộ thao tác vuốt chạm
    if not InputBlockerScreen then
        InputBlockerScreen = Instance.new("ScreenGui")
        InputBlockerScreen.Name = "OnHub_InputBlocker"
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

-- Gỡ bỏ khóa khi kích hoạt key thành công
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

-- Tiêu diệt triệt để script gốc
local function TerminateTargetScript()
    getgenv().OnHub_Active = false
    getgenv().OnHub_TrialExpired = true

    for _, conn in ipairs(ScriptConnections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(ScriptConnections)

    -- Quét sạch mọi GUI sinh ra sau khi script gốc chạy
    local containers = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
    for _, c in ipairs(containers) do
        if c then
            for _, child in ipairs(c:GetChildren()) do
                if not InitialGuis[child] and child.Name ~= "OnHub_GetKeyUI" and child.Name ~= "OnHub_ToastUI" and child.Name ~= "OnHub_InputBlocker" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function LaunchTargetScriptWithWatcher()
    TakeGuiSnapshot()
    getgenv().OnHub_Active = true

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
    if CoreGui:FindFirstChild("OnHub_ToastUI") then CoreGui.OnHub_ToastUI:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("OnHub_ToastUI") then
        LocalPlayer.PlayerGui.OnHub_ToastUI:Destroy()
    end

    local ToastGui = Instance.new("ScreenGui")
    ToastGui.Name = "OnHub_ToastUI"
    ToastGui.ResetOnSpawn = false
    pcall(function() ToastGui.Parent = CoreGui end)
    if not ToastGui.Parent then ToastGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local ToastFrame = Instance.new("Frame")
    ToastFrame.Size = UDim2.new(0, 370, 0, 74)
    ToastFrame.Position = UDim2.new(0.5, -185, 0, -100)
    ToastFrame.BackgroundColor3 = Color3.fromRGB(10, 16, 12)
    ToastFrame.BorderSizePixel = 0
    ToastFrame.ZIndex = 50
    ToastFrame.Parent = ToastGui

    Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 14)
    local Stroke = Instance.new("UIStroke", ToastFrame)
    Stroke.Thickness = 1.6
    Stroke.Color = color or Color3.fromRGB(52, 211, 153)

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 42, 1, 0)
    Icon.Position = UDim2.new(0, 8, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🍃"
    Icon.TextSize = 22
    Icon.ZIndex = 51
    Icon.Parent = ToastFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 0, 20)
    Title.Position = UDim2.new(0, 50, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = color or Color3.fromRGB(167, 243, 208)
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
    Msg.TextColor3 = Color3.fromRGB(209, 250, 229)
    Msg.TextSize = 11
    Msg.Font = Enum.Font.GothamBold
    Msg.TextXAlignment = Enum.TextXAlignment.Left
    Msg.ZIndex = 51
    Msg.Parent = ToastFrame

    ActiveToastLabel = Msg

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -20, 0, 3)
    BarBg.Position = UDim2.new(0, 10, 1, -6)
    BarBg.BackgroundColor3 = Color3.fromRGB(18, 32, 24)
    BarBg.BorderSizePixel = 0
    BarBg.ZIndex = 51
    BarBg.Parent = ToastFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 1, 0)
    Bar.BackgroundColor3 = color or Color3.fromRGB(52, 211, 153)
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
--   3. GIAO DIỆN KEY STEAM ON HUB
-- =========================================================================
local Languages = {
    VI = {
        LangBtnText = "🇻🇳 VN ▾",
        SelectLangTitle = "🍃 CHỌN NGÔN NGỮ / LANGUAGE",
        Title = "🍃 KEY STEAM ON HUB",
        SubTitle = "Hệ thống bảo mật & Xác thực bản quyền cao cấp",
        Placeholder = "Nhập mã Key On Hub (onhubfreemium-...) tại đây...",
        GetKey = "⚡ LẤY KEY NGAY",
        CheckKey = "✔ KÍCH HOẠT KEY",
        Tutorial = "▶ Video Hướng Dẫn Vượt Link",
        StatusDaily = "⏱ Thời hạn: 24 tiếng kể từ khi kích hoạt",
        CopiedLink = "📋 ĐÃ SAO CHÉP LINK! DÁN VÀO TRÌNH DUYỆT ĐỂ LẤY KEY",
        CopiedVideo = "🎬 ĐÃ SAO CHÉP LINK VIDEO HƯỚNG DẪN!",
        BtnCopied = "✔ ĐÃ SAO CHÉP",
        Checking = "⏳ Đang giải mã...",
        CheckingMsg = "Đang xác thực thông tin bản quyền trên hệ thống On Hub...",
        Success = "✔ Xác thực thành công! Đang tải On Hub...",
        SuccessBtn = "✔ THÀNH CÔNG",
        Error = "✖ Key không chính xác hoặc phiên 24h đã hết hạn!",
        Note = "📌 Lưu ý:\n• Lấy key chỉ mất 1-2 phút của bạn, key hoạt động trong 24 giờ kể từ khi kích hoạt.\n• Chúc Bạn Chơi Game Vui Vẻ! 🥰"
    },
    EN = {
        LangBtnText = "🇺🇸 EN ▾",
        SelectLangTitle = "🍃 SELECT LANGUAGE / NGÔN NGỮ",
        Title = "🍃 KEY STEAM ON HUB",
        SubTitle = "Premium License Security & Authentication",
        Placeholder = "Enter your On Hub Key here...",
        GetKey = "⚡ GET KEY LINK",
        CheckKey = "✔ ACTIVATE KEY",
        Tutorial = "▶ Tutorial Video Bypass",
        StatusDaily = "⏱ Validity: 24 hours from activation moment",
        CopiedLink = "📋 LINK COPIED! PASTE INTO BROWSER TO GET KEY",
        CopiedVideo = "🎬 TUTORIAL VIDEO LINK COPIED!",
        BtnCopied = "✔ COPIED",
        Checking = "⏳ Decrypting...",
        CheckingMsg = "Verifying license credentials with server...",
        Success = "✔ Verification Success! Launching On Hub...",
        SuccessBtn = "✔ SUCCESS",
        Error = "✖ Invalid key or expired 24h license!",
        Note = "📌 Notice:\n• Getting the key takes only 1-2 minutes, key is valid for 24 hours from activation.\n• Have fun playing! 🥰"
    }
}
local CurrentLang = "VI"

local function PlayDeepBounce(btn)
    local origSize = btn.Size
    local origPos = btn.Position
    local shrinkSize = UDim2.new(origSize.X.Scale, origSize.X.Offset - 8, origSize.Y.Scale, origSize.Y.Offset - 6)
    local shrinkPos = UDim2.new(origPos.X.Scale, origPos.X.Offset + 4, origPos.Y.Scale, origPos.Y.Offset + 3)
    
    local t1 = TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = shrinkSize, Position = shrinkPos })
    local t2 = TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = origSize, Position = origPos })
    t1:Play()
    t1.Completed:Connect(function() t2:Play() end)
end

OpenKeySystemUI = function()
    if CoreGui:FindFirstChild("OnHub_GetKeyUI") then CoreGui.OnHub_GetKeyUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OnHub_GetKeyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 410, 0, 420)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(9, 14, 11)
    MainFrame.BackgroundTransparency = 0.04
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = false
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 30
    MainFrame.Parent = ScreenGui

    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0.5
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.8
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Color = Color3.fromRGB(52, 211, 153)

    RunService.RenderStepped:Connect(function()
        local val = (math.sin(tick() * 2.2) + 1) / 2
        local r = (30 + math.floor(val * 25)) / 255
        local g = (180 + math.floor(val * 45)) / 255
        local b = (120 + math.floor(val * 35)) / 255
        MainStroke.Color = Color3.new(r, g, b)
    end)

    local HeaderBar = Instance.new("Frame")
    HeaderBar.Size = UDim2.new(1, -30, 0, 40)
    HeaderBar.Position = UDim2.new(0, 15, 0, 12)
    HeaderBar.BackgroundTransparency = 1
    HeaderBar.ZIndex = 31
    HeaderBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -110, 0, 22)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Languages[CurrentLang].Title
    TitleLabel.TextColor3 = Color3.fromRGB(167, 243, 208)
    TitleLabel.TextSize = 12.5
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 32
    TitleLabel.Parent = HeaderBar

    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Size = UDim2.new(1, -110, 0, 14)
    SubTitleLabel.Position = UDim2.new(0, 0, 0, 22)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Text = Languages[CurrentLang].SubTitle
    SubTitleLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
    SubTitleLabel.TextSize = 9
    SubTitleLabel.Font = Enum.Font.GothamMedium
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.ZIndex = 32
    SubTitleLabel.Parent = HeaderBar

    local OpenLangBtn = Instance.new("TextButton")
    OpenLangBtn.Size = UDim2.new(0, 95, 0, 28)
    OpenLangBtn.Position = UDim2.new(1, -95, 0, 5)
    OpenLangBtn.BackgroundColor3 = Color3.fromRGB(16, 28, 20)
    OpenLangBtn.Text = Languages[CurrentLang].LangBtnText
    OpenLangBtn.TextColor3 = Color3.fromRGB(52, 211, 153)
    OpenLangBtn.TextSize = 11
    OpenLangBtn.Font = Enum.Font.GothamBold
    OpenLangBtn.AutoButtonColor = false
    OpenLangBtn.ZIndex = 32
    OpenLangBtn.Parent = HeaderBar
    Instance.new("UICorner", OpenLangBtn).CornerRadius = UDim.new(0, 8)
    local LangStroke = Instance.new("UIStroke", OpenLangBtn)
    LangStroke.Color = Color3.fromRGB(16, 185, 129)
    LangStroke.Thickness = 1

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -30, 0, 36)
    InputBox.Position = UDim2.new(0, 15, 0, 60)
    InputBox.BackgroundColor3 = Color3.fromRGB(14, 22, 17)
    InputBox.TextColor3 = Color3.fromRGB(236, 253, 245)
    InputBox.PlaceholderColor3 = Color3.fromRGB(110, 130, 120)
    InputBox.PlaceholderText = Languages[CurrentLang].Placeholder
    InputBox.Text = ""
    InputBox.TextSize = 11.5
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.ClearTextOnFocus = false
    InputBox.ZIndex = 31
    InputBox.Parent = MainFrame
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 10)
    local InputStroke = Instance.new("UIStroke", InputBox)
    InputStroke.Color = Color3.fromRGB(30, 50, 38)

    local ButtonsRow = Instance.new("Frame")
    ButtonsRow.Size = UDim2.new(1, -30, 0, 38)
    ButtonsRow.Position = UDim2.new(0, 15, 0, 104)
    ButtonsRow.BackgroundTransparency = 1
    ButtonsRow.ZIndex = 31
    ButtonsRow.Parent = MainFrame

    -- Nút 1: Lấy Key (Soft Mint Green)
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.5, -5, 1, 0)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
    GetKeyBtn.Text = Languages[CurrentLang].GetKey
    GetKeyBtn.TextColor3 = Color3.fromRGB(6, 32, 18)
    GetKeyBtn.TextSize = 12
    GetKeyBtn.Font = Enum.Font.GothamBlack
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.ZIndex = 32
    GetKeyBtn.Parent = ButtonsRow
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)
    local GetKeyStroke = Instance.new("UIStroke", GetKeyBtn)
    GetKeyStroke.Color = Color3.fromRGB(110, 231, 183)
    GetKeyStroke.Thickness = 1.4

    -- Nút 2: Kích Hoạt Key
    local CheckKeyBtn = Instance.new("TextButton")
    CheckKeyBtn.Size = UDim2.new(0.5, -5, 1, 0)
    CheckKeyBtn.Position = UDim2.new(0.5, 5, 0, 0)
    CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(18, 38, 26)
    CheckKeyBtn.Text = Languages[CurrentLang].CheckKey
    CheckKeyBtn.TextColor3 = Color3.fromRGB(167, 243, 208)
    CheckKeyBtn.TextSize = 12
    CheckKeyBtn.Font = Enum.Font.GothamBlack
    CheckKeyBtn.AutoButtonColor = false
    CheckKeyBtn.ZIndex = 32
    CheckKeyBtn.Parent = ButtonsRow
    Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 10)
    local CheckStroke = Instance.new("UIStroke", CheckKeyBtn)
    CheckStroke.Color = Color3.fromRGB(52, 211, 153)
    CheckStroke.Thickness = 1.4

    local TutorialBtn = Instance.new("TextButton")
    TutorialBtn.Size = UDim2.new(1, -30, 0, 30)
    TutorialBtn.Position = UDim2.new(0, 15, 0, 150)
    TutorialBtn.BackgroundColor3 = Color3.fromRGB(14, 24, 18)
    TutorialBtn.Text = Languages[CurrentLang].Tutorial
    TutorialBtn.TextColor3 = Color3.fromRGB(110, 231, 183)
    TutorialBtn.TextSize = 10.5
    TutorialBtn.Font = Enum.Font.GothamBold
    TutorialBtn.AutoButtonColor = false
    TutorialBtn.ZIndex = 31
    TutorialBtn.Parent = MainFrame
    Instance.new("UICorner", TutorialBtn).CornerRadius = UDim.new(0, 8)
    local TutorialStroke = Instance.new("UIStroke", TutorialBtn)
    TutorialStroke.Color = Color3.fromRGB(24, 48, 32)
    TutorialStroke.Thickness = 1

    local StatusBanner = Instance.new("Frame")
    StatusBanner.Size = UDim2.new(1, -30, 0, 34)
    StatusBanner.Position = UDim2.new(0, 15, 0, 188)
    StatusBanner.BackgroundColor3 = Color3.fromRGB(12, 20, 15)
    StatusBanner.ClipsDescendants = true
    StatusBanner.ZIndex = 31
    StatusBanner.Parent = MainFrame
    Instance.new("UICorner", StatusBanner).CornerRadius = UDim.new(0, 8)
    local StatusBannerStroke = Instance.new("UIStroke", StatusBanner)
    StatusBannerStroke.Color = Color3.fromRGB(28, 48, 34)

    local StatusMsg = Instance.new("TextLabel")
    StatusMsg.Size = UDim2.new(1, -12, 1, 0)
    StatusMsg.Position = UDim2.new(0, 6, 0, 0)
    StatusMsg.BackgroundTransparency = 1
    StatusMsg.Text = Languages[CurrentLang].StatusDaily
    StatusMsg.TextColor3 = Color3.fromRGB(209, 250, 229)
    StatusMsg.TextSize = 11.5
    StatusMsg.Font = Enum.Font.GothamBold
    StatusMsg.TextWrapped = true
    StatusMsg.ZIndex = 32
    StatusMsg.Parent = StatusBanner

    local StatusProgressBar = Instance.new("Frame")
    StatusProgressBar.Size = UDim2.new(0, 0, 1, 0)
    StatusProgressBar.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
    StatusProgressBar.BackgroundTransparency = 0.8
    StatusProgressBar.BorderSizePixel = 0
    StatusProgressBar.ZIndex = 31
    StatusProgressBar.Parent = StatusBanner

    local NoteCard = Instance.new("Frame")
    NoteCard.Size = UDim2.new(1, -30, 0, 178)
    NoteCard.Position = UDim2.new(0, 15, 0, 230)
    NoteCard.BackgroundColor3 = Color3.fromRGB(12, 18, 14)
    NoteCard.ZIndex = 31
    NoteCard.Parent = MainFrame
    Instance.new("UICorner", NoteCard).CornerRadius = UDim.new(0, 12)
    local NoteStroke = Instance.new("UIStroke", NoteCard)
    NoteStroke.Color = Color3.fromRGB(24, 40, 30)
    NoteStroke.Thickness = 1

    local NoteLabel = Instance.new("TextLabel")
    NoteLabel.Size = UDim2.new(1, -18, 1, -12)
    NoteLabel.Position = UDim2.new(0, 9, 0, 6)
    NoteLabel.BackgroundTransparency = 1
    NoteLabel.TextColor3 = Color3.fromRGB(167, 243, 208)
    NoteLabel.TextSize = 10.5
    NoteLabel.Font = Enum.Font.GothamMedium
    NoteLabel.TextWrapped = true
    NoteLabel.TextYAlignment = Enum.TextYAlignment.Top
    NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
    NoteLabel.ZIndex = 32
    NoteLabel.Text = Languages[CurrentLang].Note
    NoteLabel.Parent = NoteCard
        -- Modal ngôn ngữ
    local LangModal = Instance.new("Frame")
    LangModal.Size = UDim2.new(1, 0, 1, 0)
    LangModal.Position = UDim2.new(0, 0, 1, 0)
    LangModal.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
    LangModal.BackgroundTransparency = 0.03
    LangModal.ZIndex = 40
    LangModal.Parent = MainFrame
    Instance.new("UICorner", LangModal).CornerRadius = UDim.new(0, 18)

    local ModalTitle = Instance.new("TextLabel")
    ModalTitle.Size = UDim2.new(1, -60, 0, 30)
    ModalTitle.Position = UDim2.new(0, 20, 0, 18)
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.Text = Languages[CurrentLang].SelectLangTitle
    ModalTitle.TextColor3 = Color3.fromRGB(52, 211, 153)
    ModalTitle.TextSize = 12
    ModalTitle.Font = Enum.Font.GothamBlack
    ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
    ModalTitle.ZIndex = 41
    ModalTitle.Parent = LangModal

    local CloseModalBtn = Instance.new("TextButton")
    CloseModalBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseModalBtn.Position = UDim2.new(1, -40, 0, 18)
    CloseModalBtn.BackgroundColor3 = Color3.fromRGB(24, 18, 18)
    CloseModalBtn.Text = "✕"
    CloseModalBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
    CloseModalBtn.TextSize = 13
    CloseModalBtn.Font = Enum.Font.GothamBold
    CloseModalBtn.ZIndex = 41
    CloseModalBtn.Parent = LangModal
    Instance.new("UICorner", CloseModalBtn).CornerRadius = UDim.new(0, 6)

    local LangList = Instance.new("Frame")
    LangList.Size = UDim2.new(1, -40, 0, 150)
    LangList.Position = UDim2.new(0, 20, 0, 60)
    LangList.BackgroundTransparency = 1
    LangList.ZIndex = 41
    LangList.Parent = LangModal

    local OptViBtn = Instance.new("TextButton")
    OptViBtn.Size = UDim2.new(1, 0, 0, 56)
    OptViBtn.BackgroundColor3 = Color3.fromRGB(16, 32, 22)
    OptViBtn.Text = "🇻🇳  Tiếng Việt (Vietnamese)  ✓"
    OptViBtn.TextColor3 = Color3.fromRGB(52, 211, 153)
    OptViBtn.TextSize = 13
    OptViBtn.Font = Enum.Font.GothamBlack
    OptViBtn.ZIndex = 42
    OptViBtn.AutoButtonColor = false
    OptViBtn.Parent = LangList
    Instance.new("UICorner", OptViBtn).CornerRadius = UDim.new(0, 12)
    local OptViStroke = Instance.new("UIStroke", OptViBtn)
    OptViStroke.Color = Color3.fromRGB(52, 211, 153)
    OptViStroke.Thickness = 1.5

    local OptEnBtn = Instance.new("TextButton")
    OptEnBtn.Size = UDim2.new(1, 0, 0, 56)
    OptEnBtn.Position = UDim2.new(0, 0, 0, 68)
    OptEnBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 14)
    OptEnBtn.Text = "🇺🇸  English (Global)"
    OptEnBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
    OptEnBtn.TextSize = 13
    OptEnBtn.Font = Enum.Font.GothamMedium
    OptEnBtn.ZIndex = 42
    OptEnBtn.AutoButtonColor = false
    OptEnBtn.Parent = LangList
    Instance.new("UICorner", OptEnBtn).CornerRadius = UDim.new(0, 12)
    local OptEnStroke = Instance.new("UIStroke", OptEnBtn)
    OptEnStroke.Color = Color3.fromRGB(28, 44, 34)

    local function SetLanguage(code)
        CurrentLang = code
        local data = Languages[code]
        OpenLangBtn.Text = data.LangBtnText
        TitleLabel.Text = data.Title
        SubTitleLabel.Text = data.SubTitle
        InputBox.PlaceholderText = data.Placeholder
        GetKeyBtn.Text = data.GetKey
        CheckKeyBtn.Text = data.CheckKey
        TutorialBtn.Text = data.Tutorial
        StatusMsg.Text = data.StatusDaily
        NoteLabel.Text = data.Note
        ModalTitle.Text = data.SelectLangTitle

        if code == "VI" then
            OptViBtn.Text = "🇻🇳  Tiếng Việt (Vietnamese)  ✓"
            OptViBtn.TextColor3 = Color3.fromRGB(52, 211, 153)
            OptViBtn.Font = Enum.Font.GothamBlack
            OptViStroke.Color = Color3.fromRGB(52, 211, 153)
            OptViBtn.BackgroundColor3 = Color3.fromRGB(16, 32, 22)

            OptEnBtn.Text = "🇺🇸  English (Global)"
            OptEnBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
            OptEnBtn.Font = Enum.Font.GothamMedium
            OptEnStroke.Color = Color3.fromRGB(28, 44, 34)
            OptEnBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 14)
        else
            OptEnBtn.Text = "🇺🇸  English (Global)  ✓"
            OptEnBtn.TextColor3 = Color3.fromRGB(52, 211, 153)
            OptEnBtn.Font = Enum.Font.GothamBlack
            OptEnStroke.Color = Color3.fromRGB(52, 211, 153)
            OptEnBtn.BackgroundColor3 = Color3.fromRGB(16, 32, 22)

            OptViBtn.Text = "🇻🇳  Tiếng Việt (Vietnamese)"
            OptViBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
            OptViBtn.Font = Enum.Font.GothamMedium
            OptViStroke.Color = Color3.fromRGB(28, 44, 34)
            OptViBtn.BackgroundColor3 = Color3.fromRGB(12, 18, 14)
        end
    end

    local function OpenLangModal()
        TweenService:Create(LangModal, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
    end
    local function CloseLangModal()
        TweenService:Create(LangModal, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(0, 0, 1, 0) }):Play()
    end

    OpenLangBtn.MouseButton1Click:Connect(function() PlayDeepBounce(OpenLangBtn); OpenLangModal() end)
    CloseModalBtn.MouseButton1Click:Connect(function() PlayDeepBounce(CloseModalBtn); CloseLangModal() end)
    OptViBtn.MouseButton1Click:Connect(function() PlayDeepBounce(OptViBtn); SetLanguage("VI"); task.wait(0.15); CloseLangModal() end)
    OptEnBtn.MouseButton1Click:Connect(function() PlayDeepBounce(OptEnBtn); SetLanguage("EN"); task.wait(0.15); CloseLangModal() end)

    MainFrame.BackgroundTransparency = 1
    MainScale.Scale = 0.4
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0.04 }):Play()
    TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

    GetKeyBtn.MouseButton1Click:Connect(function()
        PlayDeepBounce(GetKeyBtn)
        if setclipboard then setclipboard(KeyUrl) elseif toclipboard then toclipboard(KeyUrl) end
        StatusBanner.BackgroundColor3 = Color3.fromRGB(8, 38, 24)
        StatusBannerStroke.Color = Color3.fromRGB(52, 211, 153)
        StatusMsg.TextColor3 = Color3.fromRGB(110, 231, 183)
        StatusMsg.Text = Languages[CurrentLang].CopiedLink
        GetKeyBtn.Text = Languages[CurrentLang].BtnCopied
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)

        task.delay(2.5, function()
            if GetKeyBtn and GetKeyBtn.Parent then
                GetKeyBtn.Text = Languages[CurrentLang].GetKey
                GetKeyBtn.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
                StatusBanner.BackgroundColor3 = Color3.fromRGB(12, 20, 15)
                StatusBannerStroke.Color = Color3.fromRGB(28, 48, 34)
                StatusMsg.TextColor3 = Color3.fromRGB(209, 250, 229)
                StatusMsg.Text = Languages[CurrentLang].StatusDaily
            end
        end)
    end)

    TutorialBtn.MouseButton1Click:Connect(function()
        PlayDeepBounce(TutorialBtn)
        if setclipboard then setclipboard(TutorialUrl) elseif toclipboard then toclipboard(TutorialUrl) end
        StatusBanner.BackgroundColor3 = Color3.fromRGB(14, 28, 20)
        StatusBannerStroke.Color = Color3.fromRGB(52, 211, 153)
        StatusMsg.TextColor3 = Color3.fromRGB(110, 231, 183)
        StatusMsg.Text = Languages[CurrentLang].CopiedVideo
        TutorialBtn.Text = Languages[CurrentLang].BtnCopied

        task.delay(2.5, function()
            if TutorialBtn and TutorialBtn.Parent then
                TutorialBtn.Text = Languages[CurrentLang].Tutorial
                StatusBanner.BackgroundColor3 = Color3.fromRGB(12, 20, 15)
                StatusBannerStroke.Color = Color3.fromRGB(28, 48, 34)
                StatusMsg.TextColor3 = Color3.fromRGB(209, 250, 229)
                StatusMsg.Text = Languages[CurrentLang].StatusDaily
            end
        end)
    end)

    local isChecking = false
    CheckKeyBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        isChecking = true
        PlayDeepBounce(CheckKeyBtn)

        CheckKeyBtn.Text = Languages[CurrentLang].Checking
        StatusBanner.BackgroundColor3 = Color3.fromRGB(16, 28, 20)
        StatusMsg.TextColor3 = Color3.fromRGB(209, 250, 229)
        StatusMsg.Text = Languages[CurrentLang].CheckingMsg

        StatusProgressBar.Size = UDim2.new(0, 0, 1, 0)
        TweenService:Create(StatusProgressBar, TweenInfo.new(0.4, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) }):Play()

        task.wait(0.45)
        local enteredKey = string.gsub(InputBox.Text, "%s+", "")
        local todayKey = GenerateTodayKey()

        if string.lower(enteredKey) == string.lower(todayKey) then
            Save24hKey()
            StatusBanner.BackgroundColor3 = Color3.fromRGB(6, 40, 22)
            StatusBannerStroke.Color = Color3.fromRGB(52, 211, 153)
            StatusMsg.TextColor3 = Color3.fromRGB(110, 231, 183)
            StatusMsg.Text = Languages[CurrentLang].Success
            CheckKeyBtn.Text = Languages[CurrentLang].SuccessBtn
            CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)

            RemoveScreenLockdown()
            LaunchTargetScriptWithWatcher()

            task.wait(0.4)
            TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.5 }):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 1.2, 0) }):Play()

            task.wait(0.25)
            ScreenGui:Destroy()
        else
            isChecking = false
            CheckKeyBtn.Text = Languages[CurrentLang].CheckKey
            StatusBanner.BackgroundColor3 = Color3.fromRGB(45, 15, 15)
            StatusBannerStroke.Color = Color3.fromRGB(239, 68, 68)
            StatusMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
            StatusMsg.Text = Languages[CurrentLang].Error
            StatusProgressBar.Size = UDim2.new(0, 0, 1, 0)

            InputStroke.Color = Color3.fromRGB(239, 68, 68)
            task.wait(0.6)
            InputStroke.Color = Color3.fromRGB(30, 50, 38)
        end
    end)
end

-- =========================================================================
--   4. LUỒNG THI HÀNH VỚI MỐC THỜI GIAN THỰC (INSTANT LOCKDOWN AT 600S)
-- =========================================================================

-- 1. Đã có Key 24h: Mở thẳng script gốc
local keyTimeLeft = GetKeyRemainingTime()
if keyTimeLeft and keyTimeLeft > 0 then
    ShowLiveToast("KEY STEAM ON HUB • BẢN QUYỀN", keyTimeLeft, Color3.fromRGB(52, 211, 153))
    LaunchTargetScriptWithWatcher()
    return
end

-- 2. Kiểm tra dữ liệu Trial
local trialData = LoadTrialData()

if not trialData then
    trialData = { StartTime = os.time(), LastSeen = os.time() }
    SaveTrialData(trialData.StartTime, trialData.LastSeen)
    print("[On Hub]: Bắt đầu tính giờ 10 phút dùng thử đầu tiên!")
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
    -- Đã hết 10 phút: Làm mờ màn hình, khóa tương tác & mở Key UI
    ApplyScreenLockdown()
    ShowLiveToast("⚠️ HẾT THỜI GIAN DÙNG THỬ", 0, Color3.fromRGB(239, 68, 68))
    OpenKeySystemUI()
    return
else
    -- Còn hạn dùng thử: Chạy script gốc kèm theo dõi thời gian thực
    ShowLiveToast("ON HUB • ĐANG DÙNG THỬ (TRIAL)", remaining, Color3.fromRGB(52, 211, 153))
    LaunchTargetScriptWithWatcher()

    task.spawn(function()
        local saveInterval = 0

        while true do
            task.wait(1)
            local currentRemaining = targetEndTime - os.time()

            -- Nhảy số thời gian thực trên Toast
            if ActiveToastLabel and ActiveToastLabel.Parent then
                ActiveToastLabel.Text = "Thời gian thử nghiệm còn: " .. FormatTime(currentRemaining)
            end

            -- Lưu mốc chống lùi đồng hồ định kỳ 5 giây
            saveInterval = saveInterval + 1
            if saveInterval >= 5 then
                saveInterval = 0
                SaveTrialData(trialData.StartTime, os.time())
            end

            -- Nếu người chơi đã kích hoạt Key thì dừng theo dõi
            if GetKeyRemainingTime() then return end

            -- CHẠM MỐC 10 PHÚT: KHÓA NGAY LẬP TỨC TRONG GAME
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
