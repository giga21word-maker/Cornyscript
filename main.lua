-- Main Script (Host this on GitHub)
if getgenv().HelloWorldLoaded then 
    print("Script is already active.")
    return 
end

getgenv().HelloWorldLoaded = true

-- The Functionality
print("HELLO WORLD!")

-- Optional: UI Notification to show it worked in-game
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Success!",
    Text = "HELLO WORLD! Script Executed.",
    Duration = 5
})
