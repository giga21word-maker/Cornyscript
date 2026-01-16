--[[
    CORNY HUB - TITANIUM EDITION (v4.0)
    Advanced Physics Bypass & GUI System
    
    Credits: Giga21Word-Maker
    Updated: 2026-01-16
]]

-- // 1. INIT & SAFETY CHECKS //
if getgenv().CornyLoaded then
    if getgenv().CornyCleanup then getgenv().CornyCleanup() end
end
getgenv().CornyLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // 2. SETTINGS & CONFIGURATION //
local Settings = {
    ESP = false,
    Fly = false,
    Noclip = false,
    FlySpeed = 75, -- Faster default speed
    VerticalSpeed = 50,
    SafeMode = true -- Tries to hide from basic AC
}

-- // 3. UI LIBRARY (Advanced Look) //
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CornyTitanium"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Create the "Minimap" Toggle Button
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "Toggle"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "C"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Font = Enum.Font.FredokaOne
ToggleBtn.TextSize = 24
ToggleBtn.Draggable = true
ToggleBtn.Active = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(255, 50, 50)

-- Main Hub Window
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

-- Stylish Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "CORNY HUB TITANIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Container for buttons
local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -10, 1, -50)
Container.Position = UDim2.new(0, 5, 0, 45)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2

-- UI Helper Function
local buttonCount = 0
local function createSwitch(name, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, buttonCount * 45)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. (enabled and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(40, 40, 40)
        callback(enabled)
    end)
    buttonCount = buttonCount + 1
    Container.CanvasSize = UDim2.new(0, 0, 0, buttonCount * 45)
end

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // 4. ADVANCED FLY SYSTEM (LinearVelocity + Anti-Fall) //
local flyConnection
local function setFly(state)
    Settings.Fly = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    if state and hrp and hum then
        -- Create physics movers
        local lv = Instance.new("LinearVelocity", hrp)
        lv.Name = "CornyFlyVelocity"
        lv.MaxForce = math.huge
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.Attachment0 = hrp:FindFirstChild("RootAttachment") or Instance.new("Attachment", hrp)
        
        -- Anti-Spin
        local av = Instance.new("AngularVelocity", hrp)
        av.Name = "CornyFlyGyro"
        av.MaxTorque = math.huge
        av.AngularVelocity = Vector3.zero
        av.Attachment0 = hrp:FindFirstChild("RootAttachment")

        -- Disable Gravity Effects
        hum.PlatformStand = true
        
        -- The Fly Loop
        flyConnection = RunService.RenderStepped:Connect(function()
            if not Settings.Fly then return end
            
            -- Direction Calculation
            local moveDir = Vector3.zero
            local camCF = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            -- Apply Velocity
            lv.VectorVelocity = moveDir * Settings.FlySpeed
        end)
    else
        -- Cleanup
        if flyConnection then flyConnection:Disconnect() end
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, child in pairs(hrp:GetChildren()) do
                    if child.Name == "CornyFlyVelocity" or child.Name == "CornyFlyGyro" then
                        child:Destroy()
                    end
                end
            end
            if hum then hum.PlatformStand = false end
        end
    end
end

-- // 5. NOCLIP (Physics Stepped Hook) //
RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- // 6. ESP SYSTEM //
local function toggleESP(state)
    Settings.ESP = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("CornyESP") then
                p.Character.CornyESP:Destroy()
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("CornyESP")
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "CornyESP"
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                end
                -- Team Check
                if p.Team == LocalPlayer.Team then
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                else
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end)

-- // 7. ANTI-CHEAT BYPASS (State Disabler) //
local function secureCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(old, new)
        -- Prevent games from forcing you into 'Falling' or 'Landed' states which often triggers AC lagbacks
        if Settings.Fly and (new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll) then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(secureCharacter)
if LocalPlayer.Character then secureCharacter(LocalPlayer.Character) end

-- // 8. REGISTER BUTTONS //
createSwitch("ESP Wallhack", toggleESP)
createSwitch("Titanium Fly", setFly)
createSwitch("Noclip Bypass", function(s) Settings.Noclip = s end)
createSwitch("Anti-AFK", function(s) 
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- // 9. CLEANUP HANDLER //
getgenv().CornyCleanup = function()
    ScreenGui:Destroy()
    Settings.Fly = false
    Settings.Noclip = false
    Settings.ESP = false
    if flyConnection then flyConnection:Disconnect() end
end

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Corny Hub";
    Text = "Titanium Edition Loaded!";
    Duration = 5;
})
