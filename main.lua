-- Force reset the loaded state to ensure the new code runs
getgenv().CornyHubLoaded = nil 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Cleanup old GUI if it exists
local oldGui = game:GetService("CoreGui"):FindFirstChild("CornyHub") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CornyHub")
if oldGui then oldGui:Destroy() end

local ESP_Enabled = false
local Fly_Enabled = false
local FlySpeed = 50

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CornyHub"
ScreenGui.Parent = game:GetService("CoreGui") 
ScreenGui.ResetOnSpawn = false

local function createBtn(name, text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = ScreenGui
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Draggable = true
    btn.Active = true
    Instance.new("UICorner", btn)
    return btn
end

local ESPBtn = createBtn("ESPBtn", "ESP: OFF", UDim2.new(0.1, 0, 0.2, 0), Color3.fromRGB(150, 0, 0))
local FlyBtn = createBtn("FlyBtn", "FLY: OFF", UDim2.new(0.1, 0, 0.2, 50), Color3.fromRGB(0, 0, 150))

-- ESP Logic
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("CornyHighlight")
            if ESP_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight", player.Character)
                    highlight.Name = "CornyHighlight"
                    highlight.FillColor = Color3.new(1, 0, 0)
                end
                highlight.Enabled = true
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end)

-- Fly Logic (Aggressive Fix)
local bodyVel, bodyGyro
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if Fly_Enabled and hrp and hum then
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        hum.PlatformStand = true
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        
        local moveDir = Vector3.new(0,0,0)
        local cam = workspace.CurrentCamera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
        
        bodyVel.Velocity = moveDir * FlySpeed
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        if hum then hum.PlatformStand = false end
    end
end)

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
