-- main.lua (Advanced ESP)
if getgenv().CornyESP then 
    print("ESP already active. Use the toggle to change state.")
    return 
end

getgenv().CornyESP = true
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Configuration Table (Easy to change later)
local Settings = {
    Enabled = true,
    EnemyColor = Color3.fromRGB(255, 0, 0), -- Red
    TeamColor = Color3.fromRGB(0, 255, 0),  -- Green
    TeamCheck = true,
    FillTransparency = 0.5,
    OutlineTransparency = 0
}

local function applyHighlight(player)
    local function create()
        local char = player.Character or player.CharacterAdded:Wait()
        -- Prevent duplicates
        local old = char:FindFirstChild("CornyHighlight")
        if old then old:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.Name = "CornyHighlight"
        highlight.Parent = char
        
        -- Logic for Team Check
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            highlight.FillColor = Settings.TeamColor
        else
            highlight.FillColor = Settings.EnemyColor
        end

        highlight.FillTransparency = Settings.FillTransparency
        highlight.OutlineTransparency = Settings.OutlineTransparency
        highlight.Enabled = Settings.Enabled
    end
    
    create()
    player.CharacterAdded:Connect(create)
end

-- Initialize for all players
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        task.spawn(applyHighlight, p)
    end
end

Players.PlayerAdded:Connect(applyHighlight)

print("Advanced ESP Loaded. Team Check: " .. tostring(Settings.TeamCheck))

-- Notify user
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "CornyScript",
    Text = "Advanced ESP Loaded",
    Duration = 3
})
