-- Main script logic using getgenv().Settings

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local remoteEvent = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteEvent")

local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")
local hud = screenGui:WaitForChild("HUD")
local right = hud:WaitForChild("Right")
local index = right:WaitForChild("Index")
local indexButton = index:WaitForChild("Button")
local eggGuiPath = playerGui.ScreenGui.Index.Container.Left.Index.ScrollingFrame
local eggModels = workspace:WaitForChild("Rendered"):WaitForChild("Generic")

local Settings = getgenv().Settings

-- Open/Close the index by toggling Pressed attribute
local function toggleIndex()
    indexButton:SetAttribute("Pressed", true)
    task.wait(Settings.IndexButtonToggleDelay)
    indexButton:SetAttribute("Pressed", false)
    task.wait(Settings.IndexButtonToggleDelay)
end

-- Disable visible Index GUI spammy to keep it hidden
local function hideIndexGui()
    local indexGui = playerGui:WaitForChild("ScreenGui"):WaitForChild("Index")
    for _ = 1, 10 do
        indexGui.Visible = false
        task.wait(0.1)
        indexGui.Visible = true
        task.wait(0.1)
    end
    indexGui.Visible = false
end

local function sendWebhook(message)
    local data = HttpService:JSONEncode({
        username = Settings.WebhookName,
        avatar_url = Settings.WebhookAvatarURL,
        content = "**[BGSI Auto Indexer]**\n" .. message
    })

    local requestFunc = (syn and syn.request) or http_request or request
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = Settings.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
        end)
    else
        warn("No HTTP request function available.")
    end
end

-- Find the Label recursively in pet frame (TextLabel named "Label")
local function findLabelRecursive(parent)
    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("TextLabel") and child.Name == "Label" then
            return child
        end
        local found = findLabelRecursive(child)
        if found then return found end
    end
    return nil
end

-- Check if all pets in a single egg are indexed
local function areAllPetsIndexed(petsFolder)
    for _, petFrame in pairs(petsFolder:GetChildren()) do
        if petFrame:IsA("Frame") then
            local imageButton = petFrame:FindFirstChildWhichIsA("ImageButton")
            if imageButton then
                local label = findLabelRecursive(imageButton)
                if label and not label.Visible then
                    return false
                elseif not label then
                    return false
                end
            end
        end
    end
    return true
end

-- Tween to egg model position
local function tweenToEgg(eggName)
    local model = eggModels:FindFirstChild(eggName)
    if not model then
        warn("Egg model not found: " .. eggName)
        return
    end
    local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then
        warn("No valid part to tween to in " .. eggName)
        return
    end

    local goalCFrame = primaryPart.CFrame * CFrame.new(0, 5, 0)
    local tweenInfo = TweenInfo.new(Settings.TweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = goalCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- Hatch eggs
local function hatchEgg(eggName, amount)
    remoteEvent:FireServer("HatchEgg", eggName, amount)
end

-- Main indexing loop
local function main()
    -- Start by opening and closing index once
    toggleIndex()
    toggleIndex()

    -- Hide the Index GUI spammy
    hideIndexGui()

    -- Loop over eggs in specified order
    for _, eggName in ipairs(Settings.EggOrder) do
        local eggFrame = eggGuiPath:FindFirstChild(eggName)
        if eggFrame and eggFrame:FindFirstChild("Pets") then
            local petsFolder = eggFrame:FindFirstChild("Pets")

            if areAllPetsIndexed(petsFolder) then
                sendWebhook("✅ All pets already indexed in: " .. eggName)
            else
                sendWebhook("🔁 Starting indexing of: " .. eggName)
                tweenToEgg(eggName)

                local hatchCount = 0
                repeat
                    hatchEgg(eggName, Settings.HatchAmount)
                    hatchCount += 1
                    task.wait(Settings.HatchDelay)

                    -- Every X hatches add extra delay and open/close index
                    if hatchCount % Settings.ExtraDelayEvery == 0 then
                        toggleIndex()
                        toggleIndex()
                        task.wait(Settings.ExtraDelaySeconds)
                    end

                until areAllPetsIndexed(petsFolder)

                sendWebhook("✅ Done indexing: " .. eggName)
            end
        end
    end

    sendWebhook("🎉 All eggs indexed!")
end

task.spawn(main)
