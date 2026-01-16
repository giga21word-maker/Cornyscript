-- main.lua
if getgenv().CornyHubLoaded then return end
getgenv().CornyHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Variables for Mods
local ESP_Enabled = false
local Fly_Enabled = false
local FlySpeed = 50

-- Create the GUI
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "CornyHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainButton.Name = "MainButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainButton.Position = UDim2.new(0.1, 0, 0.1, 0)
MainButton.Size = UDim2.new(0, 100, 0, 50)
MainButton.Font = Enum.Font.SourceSansBold
MainButton.Text = "ESP: OFF\nFLY: OFF"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 14
MainButton.Active = true
MainButton.Draggable = true -- Allows you to move the button

UICorner.Parent = MainButton

-- Logic for ESP
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("CornyESP")
            if highlight then
                highlight.Enabled = ESP_Enabled
            elseif ESP_Enabled then
                local newHighlight = Instance.new("Highlight")
                newHighlight.Name = "CornyESP"
                newHighlight.Parent = player.Character
                newHighlight.FillColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

-- Logic for Flying (Optimized)
local bv, bg
RunService.RenderStepped:Connect(function()
    if Fly_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1,1,1) * math.huge
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1,1,1) * math.huge
            bg.P = 9e4
        end
        
        local cam = workspace.CurrentCamera
        local direction = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
        
        bv.Velocity = direction * FlySpeed
        bg.CFrame = cam.CFrame
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
    end
    
    if ESP_Enabled then updateESP() end
end)

-- Button Interaction
MainButton.MouseButton1Click:Connect(function()
    if not ESP_Enabled and not Fly_Enabled then
        ESP_Enabled = true
        MainButton.Text = "ESP: ON\nFLY: OFF"
    elseif ESP_Enabled and not Fly_Enabled then
        Fly_Enabled = true
        MainButton.Text = "ESP: ON\nFLY: ON"
    elseif ESP_Enabled and Fly_Enabled then
        ESP_Enabled = false
        MainButton.Text = "ESP: OFF\nFLY: ON"
    else
        Fly_Enabled = false
        MainButton.Text = "ESP: OFF\nFLY: OFF"
    end
end)
