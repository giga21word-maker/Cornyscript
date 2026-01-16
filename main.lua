--[[
    CORNY HUB - TITANIUM-X ELITE
    Version: 6.0.0 (Bypass Optimized)
    
    Features:
    - OOP Architecture (Object Oriented)
    - Metatable Hooking (Anti-Cheat Bypass)
    - Ghost-CFrame Flight (No-Physics)
    - Smart ESP (Team-Aware)
    - Draggable Professional UI
]]

-- // 1. INITIALIZATION & SAFETY //
if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().CornyTitaniumLoaded then 
    getgenv().CornyCleanup() 
end
getgenv().CornyTitaniumLoaded = true

-- // 2. SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- // 3. LOCAL VARIABLES //
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // 4. CONFIGURATION //
local Config = {
    Fly = {
        Enabled = false,
        Speed = 2.5,
        VerticalSpeed = 2,
        Smoothness = 0.1,
        Noclip = false
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        Color = Color3.fromRGB(255, 60, 60),
        TeamColor = Color3.fromRGB(60, 255, 60)
    },
    UI = {
        Accent = Color3.fromRGB(255, 45, 45),
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25)
    }
}

-- // 5. SECURITY LAYER (METATABLE SPOOFER) //
-- This "lies" to the game scripts to bypass speed/jump checks
local function InitiateBypass()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if not checkcaller() then
            if t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
                return k == "WalkSpeed" and 16 or 50 -- Returns default values to AC
            end
            if t:IsA("BasePart") and (k == "Velocity" or k == "AssemblyLinearVelocity") then
                return Vector3.new(0,0,0) -- Hides fly velocity
            end
        end
        return oldIndex(t, k)
    end)

    setreadonly(mt, true)
end
pcall(InitiateBypass)

-- // 6. UTILITY CLASSES //
local Utils = {}
function Utils:Tween(obj, info, goal)
    return TweenService:Create(obj, TweenInfo.new(unpack(info)), goal):Play()
end

function Utils:MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // 7. UI FRAMEWORK //
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    
    self.Main = Instance.new("ScreenGui", CoreGui)
    self.Main.Name = "CornyTitanium_" .. HttpService:GenerateGUID(false)
    
    self.Container = Instance.new("Frame", self.Main)
    self.Container.Size = UDim2.new(0, 450, 0, 320)
    self.Container.Position = UDim2.new(0.5, -225, 0.5, -160)
    self.Container.BackgroundColor3 = Config.UI.Background
    self.Container.BorderSizePixel = 0
    Instance.new("UICorner", self.Container)
    
    self.Sidebar = Instance.new("Frame", self.Container)
    self.Sidebar.Size = UDim2.new(0, 130, 1, 0)
    self.Sidebar.BackgroundColor3 = Config.UI.Secondary
    self.Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", self.Sidebar)
    
    self.Title = Instance.new("TextLabel", self.Sidebar)
    self.Title.Size = UDim2.new(1, 0, 0, 50)
    self.Title.Text = "TITANIUM-X"
    self.Title.TextColor3 = Config.UI.Accent
    self.Title.Font = Enum.Font.FredokaOne
    self.Title.TextSize = 20
    self.Title.BackgroundTransparency = 1
    
    self.Content = Instance.new("ScrollingFrame", self.Container)
    self.Content.Position = UDim2.new(0, 140, 0, 10)
    self.Content.Size = UDim2.new(1, -150, 1, -20)
    self.Content.BackgroundTransparency = 1
    self.Content.BorderSizePixel = 0
    self.Content.ScrollBarThickness = 2
    
    Utils:MakeDraggable(self.Sidebar, self.Container)
    
    return self
end

function UI:CreateToggle(name, callback)
    local btn = Instance.new("TextButton", self.Content)
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Config.UI.Accent or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
    
    local layout = self.Content:FindFirstChild("UIListLayout") or Instance.new("UIListLayout", self.Content)
    layout.Padding = UDim.new(0, 8)
end

-- // 8. CORE MODULES //

-- [ GHOST-CFRAME FLY ]
local function HandleFly()
    RunService.RenderStepped:Connect(function(dt)
        if not Config.Fly.Enabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if root and hum then
            hum.PlatformStand = true
            local moveDir = Vector3.zero
            local camCF = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, Config.Fly.VerticalSpeed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, Config.Fly.VerticalSpeed, 0) end
            
            local targetPos = root.Position + (moveDir * Config.Fly.Speed)
            root.CFrame = root.CFrame:Lerp(CFrame.new(targetPos, targetPos + camCF.LookVector), Config.Fly.Smoothness)
            root.Velocity = Vector3.zero
        end
    end)
end

-- [ ADVANCED NOCLIP ]
local function HandleNoclip()
    RunService.Stepped:Connect(function()
        if Config.Fly.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

-- [ ELITE ESP ]
local function HandleESP()
    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("CornyESP")
                if Config.ESP.Enabled then
                    if not highlight then
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "CornyESP"
                    end
                    highlight.FillColor = (p.Team == LocalPlayer.Team) and Config.ESP.TeamColor or Config.ESP.Color
                    highlight.Enabled = true
                elseif highlight then
                    highlight.Enabled = false
                end
            end
        end
    end)
end

-- // 9. EXECUTION //
local Hub = UI.new()

Hub:CreateToggle("Ghost Fly", function(s) 
    Config.Fly.Enabled = s 
    if not s and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
end)

Hub:CreateToggle("Noclip Bypass", function(s) 
    Config.Fly.Noclip = s 
end)

Hub:CreateToggle("Enhanced ESP", function(s) 
    Config.ESP.Enabled = s 
end)

Hub:CreateToggle("Anti-Idle Bypass", function(s)
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if s then vu:Button2Down(Vector2.new(0,0), Camera.CFrame) wait(1) vu:Button2Up(Vector2.new(0,0), Camera.CFrame) end
    end)
end)

-- Start Loops
HandleFly()
HandleNoclip()
HandleESP()

-- // 10. CLEANUP //
getgenv().CornyCleanup = function()
    Hub.Main:Destroy()
    Config.Fly.Enabled = false
    Config.Fly.Noclip = false
    Config.ESP.Enabled = false
    getgenv().CornyTitaniumLoaded = false
end

StarterGui:SetCore("SendNotification", {
    Title = "Corny Hub";
    Text = "Titanium-X v6.0.0 Successfully Loaded!";
    Duration = 5;
})
