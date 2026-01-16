-- main.lua (ESP Edition)
if getgenv().ESPLoaded then 
    print("ESP is already running.")
    return 
end
getgenv().ESPLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Function to create the ESP Highlight
local function createESP(player)
    -- We wait for the character to exist
    player.CharacterAdded:Connect(function(character)
        if not character:FindFirstChild("ESPHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red color
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
        end
    end)
    
    -- If they already have a character loaded
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
    end
end

-- Apply to all current players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

-- Apply to any new players who join
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

print("ESP Script Loaded Successfully.")
