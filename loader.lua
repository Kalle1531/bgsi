local BGSI = {}
BGSI.Version = "1.0.0"
BGSI.LastUpdated = "May 26, 2025"

-- Local references to settings for efficiency
local Settings = getgenv().Settings or {}
local OpenEgg = Settings.OpenEgg
local TargetRifts = Settings.TargetRifts or {}
local MinimumRiftLuck = Settings.MinimumRiftLuck or 0
local TargetHighestLuck = Settings.TargetHighestLuck
local WebhookURL = Settings.Webhook
local DiscordID = Settings.DiscordID
local MinimumSendDifficulty = Settings.MinimumSendDifficulty or "0"
local TradeUsers = Settings.TradeUsers or {}
local Debug = Settings.Debug or {DisableUI = false}

-- Local references to game services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Utility functions
BGSI.Utils = {}

-- Convert string value with suffix (e.g., "1m", "100k") to number
function BGSI.Utils.ParseValueString(valueStr)
    if type(valueStr) ~= "string" then return 0 end
    
    local value = 0
    local multiplier = 1
    
    -- Extract the number and suffix
    local numStr = valueStr:match("^%d+%.?%d*")
    local suffix = valueStr:match("[kmbtqQsS]%a*$")
    
    if numStr then
        value = tonumber(numStr) or 0
    end
    
    if suffix then
        suffix = suffix:lower()
        if suffix:find("k") then
            multiplier = 1e3  -- Thousand
        elseif suffix:find("m") then
            multiplier = 1e6  -- Million
        elseif suffix:find("b") then
            multiplier = 1e9  -- Billion
        elseif suffix:find("t") then
            multiplier = 1e12 -- Trillion
        elseif suffix:find("q") then
            multiplier = 1e15 -- Quadrillion
        elseif suffix:find("s") then
            multiplier = 1e18 -- Sextillion
        end
    end
    
    return value * multiplier
end

-- Send webhook notification to Discord
function BGSI.Utils.SendWebhook(title, description, color, fields)
    if not WebhookURL or WebhookURL == "" then return end
    
    local embed = {
        title = title or "BGSI Auto Farm Notification",
        description = description or "",
        color = color or 0x00ff00,
        fields = fields or {},
        footer = {
            text = "BGSI Auto Farm v" .. BGSI.Version
        },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    -- Mention user if Discord ID is provided
    local content = ""
    if DiscordID and DiscordID ~= "" then
        content = "<@" .. DiscordID .. ">"
    end
    
    local data = {
        content = content,
        embeds = {embed}
    }
    
    local success, err = pcall(function()
        HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("Failed to send webhook: " .. tostring(err))
    end
end

-- Rift management functions
BGSI.Rifts = {}

-- Get all available rifts in the game
function BGSI.Rifts.GetAllRifts()
    local rifts = {}
    
    -- This would need to be implemented based on the actual game structure
    -- Placeholder implementation
    for _, rift in pairs(workspace.Rifts:GetChildren()) do
        if rift:IsA("Model") and rift:FindFirstChild("Luck") then
            table.insert(rifts, {
                Name = rift.Name,
                Luck = rift.Luck.Value,
                Instance = rift
            })
        end
    end
    
    return rifts
end

-- Filter rifts based on settings
function BGSI.Rifts.GetTargetRifts()
    local allRifts = BGSI.Rifts.GetAllRifts()
    local targetRifts = {}
    
    for _, rift in pairs(allRifts) do
        -- Check if rift is in our target list
        local isTargetRift = false
        for _, targetName in pairs(TargetRifts) do
            if rift.Name:find(targetName) then
                isTargetRift = true
                break
            end
        end
        
        -- Check if rift meets minimum luck requirement
        if isTargetRift and rift.Luck >= MinimumRiftLuck then
            table.insert(targetRifts, rift)
        end
    end
    
    return targetRifts
end

-- Get the best rift to farm
function BGSI.Rifts.GetBestRift()
    local targetRifts = BGSI.Rifts.GetTargetRifts()
    if #targetRifts == 0 then return nil end
    
    if TargetHighestLuck then
        -- Sort rifts by luck (highest to lowest)
        table.sort(targetRifts, function(a, b)
            return a.Luck > b.Luck
        end)
        
        return targetRifts[1]
    else
        -- Group rifts by name and find highest luck in each group
        local riftGroups = {}
        for _, rift in pairs(targetRifts) do
            if not riftGroups[rift.Name] or riftGroups[rift.Name].Luck < rift.Luck then
                riftGroups[rift.Name] = rift
            end
        end
        
        -- Find the rift with the highest luck among the best of each group
        local bestRift = nil
        for _, rift in pairs(riftGroups) do
            if not bestRift or bestRift.Luck < rift.Luck then
                bestRift = rift
            end
        end
        
        return bestRift
    end
end

-- Egg opening functions
BGSI.Eggs = {}

-- Open the specified egg
function BGSI.Eggs.OpenEgg()
    if not OpenEgg or OpenEgg == "" then
        print("No egg specified in settings.")
        return
    end
    
    -- This would need to be implemented based on the actual game structure
    -- Placeholder implementation showing the general approach
    local args = {
        [1] = OpenEgg,
        [2] = 1, -- Open 1 egg at a time
        [3] = false -- No auto open
    }
    
    local success, err = pcall(function()
        ReplicatedStorage.Remotes.OpenEgg:FireServer(unpack(args))
    end)
    
    if not success then
        warn("Failed to open egg: " .. tostring(err))
    end
end

-- Pet management functions
BGSI.Pets = {}

-- Get all owned pets
function BGSI.Pets.GetOwnedPets()
    local pets = {}
    
    -- This would need to be implemented based on the actual game structure
    -- Placeholder implementation
    local petsFolder = LocalPlayer.Pets
    if petsFolder then
        for _, pet in pairs(petsFolder:GetChildren()) do
            if pet:IsA("IntValue") or pet:IsA("NumberValue") or pet:IsA("StringValue") then
                table.insert(pets, {
                    ID = pet.Name,
                    Value = pet.Value,
                    Rarity = pet:FindFirstChild("Rarity") and pet.Rarity.Value or "Common"
                })
            end
        end
    end
    
    return pets
end

-- Check if a pet meets the minimum value requirement for webhook notifications
function BGSI.Pets.IsPetValueableEnough(petValue)
    local minValue = BGSI.Utils.ParseValueString(MinimumSendDifficulty)
    return petValue >= minValue
end

-- Trade functions
BGSI.Trading = {}

-- Trade with a player
function BGSI.Trading.TradeWithPlayer(username)
    -- This would need to be implemented based on the actual game structure
    -- Placeholder implementation
    local targetPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == username then
            targetPlayer = player
            break
        end
    end
    
    if not targetPlayer then
        print("Target player " .. username .. " not found in server.")
        return false
    end
    
    local args = {
        [1] = targetPlayer
    }
    
    local success, err = pcall(function()
        ReplicatedStorage.Remotes.SendTradeRequest:FireServer(unpack(args))
    end)
    
    if not success then
        warn("Failed to send trade request: " .. tostring(err))
        return false
    end
    
    return true
end

-- UI management functions
BGSI.UI = {}

-- Disable in-game UI elements if requested
function BGSI.UI.DisableGameUI()
    if not Debug.DisableUI then return end
    
    -- This would need to be implemented based on the actual game structure
    -- Placeholder implementation
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "BGSI_AutoFarm_GUI" then
            gui.Enabled = false
        end
    end
    
    print("Game UI has been disabled as per debug settings.")
end

-- Create our own minimal UI
function BGSI.UI.CreateAutofarmGUI()
    -- This would implement a simple UI to show the auto farm status
    -- Placeholder implementation
    local bgsiGui = Instance.new("ScreenGui")
    bgsiGui.Name = "BGSI_AutoFarm_GUI"
    bgsiGui.ResetOnSpawn = false
    bgsiGui.Parent = LocalPlayer.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 100)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = bgsiGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "BGSI Auto Farm v" .. BGSI.Version
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 30)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Text = "Status: Initializing..."
    status.TextSize = 14
    status.Font = Enum.Font.SourceSans
    status.Parent = frame
    
    BGSI.UI.StatusLabel = status
    
    print("Created BGSI Auto Farm GUI")
    return bgsiGui
end

-- Update the status display in our UI
function BGSI.UI.UpdateStatus(statusText)
    if BGSI.UI.StatusLabel then
        BGSI.UI.StatusLabel.Text = "Status: " .. statusText
    end
    print("Status: " .. statusText)
end

-- Main auto farm loop
function BGSI.StartAutoFarm()
    BGSI.UI.UpdateStatus("Starting auto farm...")
    
    -- Initial setup
    BGSI.UI.DisableGameUI()
    BGSI.UI.CreateAutofarmGUI()
    
    -- Send startup webhook
    BGSI.Utils.SendWebhook(
        "BGSI Auto Farm Started",
        "Auto farming has been initialized with the following settings:\n" ..
        "- Target Egg: " .. (OpenEgg or "None") .. "\n" ..
        "- Minimum Rift Luck: " .. MinimumRiftLuck .. "\n" ..
        "- Target Highest Luck: " .. tostring(TargetHighestLuck),
        0x00ff00
    )
    
    -- Main loop
    spawn(function()
        while wait(1) do
            -- Farm best rift
            local bestRift = BGSI.Rifts.GetBestRift()
            if bestRift then
                BGSI.UI.UpdateStatus("Farming " .. bestRift.Name .. " (Luck: " .. bestRift.Luck .. ")")
                
                -- Teleport to rift (placeholder)
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and bestRift.Instance then
                    character.HumanoidRootPart.CFrame = bestRift.Instance.CFrame
                end
                
                -- Wait for farming animation/process
                wait(5)
            else
                BGSI.UI.UpdateStatus("No suitable rifts found")
                wait(10)
            end
            
            -- Open eggs
            BGSI.UI.UpdateStatus("Opening " .. (OpenEgg or "eggs"))
            for i = 1, 3 do -- Open 3 eggs each cycle
                BGSI.Eggs.OpenEgg()
                wait(1)
            end
            
            -- Check for valuable pets
            local pets = BGSI.Pets.GetOwnedPets()
            for _, pet in pairs(pets) do
                if BGSI.Pets.IsPetValueableEnough(pet.Value) then
                    -- Send webhook for valuable pet
                    BGSI.Utils.SendWebhook(
                        "Valuable Pet Obtained!",
                        "Found a " .. pet.Rarity .. " pet worth " .. tostring(pet.Value),
                        0xff0000,
                        {
                            {name = "Pet ID", value = pet.ID, inline = true},
                            {name = "Value", value = tostring(pet.Value), inline = true}
                        }
                    )
                    
                    -- Try to trade to one of our users
                    for _, username in pairs(TradeUsers) do
                        if BGSI.Trading.TradeWithPlayer(username) then
                            BGSI.UI.UpdateStatus("Trading with " .. username)
                            wait(10) -- Wait for trade process
                            break
                        end
                    end
                end
            end
        end
    end)
    
    BGSI.UI.UpdateStatus("Auto farm running")
    return true
end

-- Error handling wrapper
local success, result = pcall(function()
    return BGSI.StartAutoFarm()
end)

if not success then
    warn("BGSI Auto Farm Error: " .. tostring(result))
    
    -- Send error webhook
    pcall(function()
        if WebhookURL and WebhookURL ~= "" then
            local data = {
                content = DiscordID and ("<@" .. DiscordID .. ">") or "",
                embeds = {
                    {
                        title = "BGSI Auto Farm Error",
                        description = "An error occurred while running the auto farm script:\n```" .. tostring(result) .. "```",
                        color = 0xff0000,
                        footer = {
                            text = "BGSI Auto Farm v" .. BGSI.Version
                        },
                        timestamp = DateTime.now():ToIsoDate()
                    }
                }
            }
            
            HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data))
        end
    end)
end

return BGSI
