-- main.lua (Advanced Bypass Edition)
if getgenv().CornyLoaded then getgenv().CornyCleanup() end
getgenv().CornyLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration (Optimized)
local Settings = {
    ESP = false,
    Fly = false,
    FlySpeed = 2, -- CFrame units
    Noclip = false
}

-- Bypass: Use a metatable hook to hide property changes if the game tries to index them
local Raw = getrawmetatable(game)
setreadonly(Raw, false)
local OldIndex = Raw.__index
Raw.__index = newcclosure(function(Self, Key)
    if not checkcaller() and Settings.Fly and Self:IsA("Humanoid") and (Key == "WalkSpeed" or Key == "JumpPower") then
        return 16 -- Return default values to the server/anti-cheat
    end
    return OldIndex(Self, Key)
end)
setreadonly(Raw, true)

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "CornySystem"

local function createToggle(name, text, pos)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 140, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BorderSizePixel = 0
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Draggable = true
    btn.Active = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local EBtn = createToggle("E", "ESP", UDim2.new(0.05, 0, 0.3, 0))
local FBtn = createToggle("F", "FLY/NOCLIP", UDim2.new(0.05, 0, 0.3, 40))

-- Advanced ESP (Fast Task Scheduling)
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local highlight = p.Character:FindFirstChild("CornyHigh")
            
            if Settings.ESP and root then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "CornyHigh"
                    highlight.OutlineTransparency = 0
                    highlight.FillTransparency = 0.6
                end
                highlight.FillColor = (p.Team ~= LocalPlayer.Team) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Advanced Fly (CFrame Method - Bypasses Velocity Checks)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Settings.Fly then
        -- Noclip Logic: Disable collision for all body parts
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local cam = workspace.CurrentCamera.CFrame
        local move = Vector3.new(0,0,0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
        
        -- Use CFrame instead of Velocity (Harder for Anti-Cheat to track)
        hrp.Velocity = Vector3.new(0, 0.1, 0) -- Tiny velocity to stay "grounded" in game logic
        hrp.CFrame = hrp.CFrame + (move * Settings.FlySpeed)
    end
end)

-- Button Logic
EBtn.MouseButton1Click:Connect(function()
    Settings.ESP = not Settings.ESP
    EBtn.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF")
    EBtn.BackgroundColor3 = Settings.ESP and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(20, 20, 20)
end)

FBtn.MouseButton1Click:Connect(function()
    Settings.Fly = not Settings.Fly
    FBtn.Text = "FLY/NOCLIP: " .. (Settings.Fly and "ON" or "OFF")
    FBtn.BackgroundColor3 = Settings.Fly and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(20, 20, 20)
end)

RunService.Heartbeat:Connect(UpdateESP)

getgenv().CornyCleanup = function()
    ScreenGui:Destroy()
    Settings.Fly = false
    Settings.ESP = false
    getgenv().CornyLoaded = false
end
