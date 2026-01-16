-- main.lua
if getgenv().CornyHubLoaded then 
    -- If already loaded, we just refresh the UI
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
local FlySpeed = 50

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CornyHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Helper to make buttons
local function createButton(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = ScreenGui
    btn.Size = UDim2.new(0, 100, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Draggable = true
    btn.Active = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

local ESPBtn = createButton("ESPBtn", "ESP: OFF", UDim2.new(0.1, 0, 0.1, 0), Color3.fromRGB(150, 0, 0))
local FlyBtn = createButton("FlyBtn", "FLY: OFF", UDim2.new(0.1, 0, 0.1, 50), Color3.fromRGB(0, 0, 150))

-- ESP LOGIC
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("CornyHighlight")
            if ESP_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "CornyHighlight"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.new(1, 0, 0)
                end
                highlight.Enabled = true
            else
                if highlight then highlight.Enabled = false end
            end
        end
    end
end)

-- FLY LOGIC (Fixed)
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
        
        hum.PlatformStand = true -- Prevents falling animations
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

-- Button Click Events
ESPBtn.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ESPBtn.Text = ESP_Enabled and "ESP: ON" or "ESP: OFF"
    ESPBtn.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

FlyBtn.MouseButton1Click:Connect(function()
    Fly_Enabled = not Fly_Enabled
    FlyBtn.Text = Fly_Enabled and "FLY: ON" or "FLY: OFF"
    FlyBtn.BackgroundColor3 = Fly_Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(0, 0, 150)
end)
