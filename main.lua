-- main.lua
if getgenv().CornyHubLoaded then 
    local old = game:GetService("CoreGui"):FindFirstChild("CornyHub")
    if old then old:Destroy() end
end
getgenv().CornyHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESP_Enabled = false
local Fly_Enabled = false
local FlySpeed = 60

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CornyHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local function createButton(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = ScreenGui
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Draggable = true
    btn.Active = true
    local corner = Instance.new("UICorner")
    corner.Parent = btn
    return btn
end

local ESPBtn = createButton("ESPBtn", "ESP: OFF", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(180, 50, 50))
local FlyBtn = createButton("FlyBtn", "FLY: OFF", UDim2.new(0.05, 0, 0.4, 50), Color3.fromRGB(50, 50, 180))

-- FIX: ESP CLEANUP LOGIC
local function clearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local h = player.Character:FindFirstChild("CornyHighlight")
            if h then h:Destroy() end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if ESP_Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local h = player.Character:FindFirstChild("CornyHighlight")
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "CornyHighlight"
                    h.Parent = player.Character
                    h.FillColor = Color3.new(1, 0, 0)
                end
            end
        end
    else
        clearESP()
    end
end)

-- FIX: STABLE FLY LOGIC
local bv, bg
RunService.Heartbeat:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 9e4
        end
        
        hum.PlatformStand = true
        bg.CFrame = workspace.CurrentCamera.CFrame
        
        local moveDir = Vector3.new(0,0,0)
        local cam = workspace.CurrentCamera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
        
        bv.Velocity = moveDir * FlySpeed
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
    end
end)

-- BUTTON EVENTS
ESPBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ESPBtn.Text = ESP_Enabled and "ESP: ON" or "ESP: OFF"
    ESPBtn.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

FlyBtn.MouseButton1Click:Connect(function()
    Fly_Enabled = not Fly_Enabled
    FlyBtn.Text = Fly_Enabled and "FLY: ON" or "FLY: OFF"
    FlyBtn.BackgroundColor3 = Fly_Enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(50, 50, 180)
end)
