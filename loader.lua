local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

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

-- Disable visible Index frame on startup and spam to hide
local indexFrame = playerGui.ScreenGui:FindFirstChild("Index")
if indexFrame then
    task.spawn(function()
        for _ = 1, 20 do
            indexFrame.Visible = false
            task.wait(0.1)
        end
    end)
end

-- Function to toggle index open/close
local function openIndexBook()
    indexButton:SetAttribute("Pressed", true)
    task.wait(getgenv().Settings.IndexButtonToggleDelay)
    indexButton:SetAttribute("Pressed", false)
    task.wait(0.5) -- wait for GUI to fully open
end

local function sendWebhook(message)
    local data = HttpService:JSONEncode({
        content = message,
        username = getgenv().Settings.WebhookName,
        avatar_url = getgenv().Settings.WebhookAvatarURL
    })

    local requestFunc = (syn and syn.request) or http_request or request
    if requestFunc then
        pcall(function()
            requestFunc({
                Url = getgenv().Settings.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
        end)
    else
        warn("No HTTP request function available to send webhook.")
    end
end

-- Find label recursively inside a frame (TextLabel named "Label")
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

-- Check if all pets indexed in a folder
local function areAllPetsIndexed(petsFolder)
    for _, petFrame in pairs(petsFolder:GetChildren()) do
        if petFrame:IsA("Frame") then
            local imageButton = petFrame:FindFirstChildWhichIsA("ImageButton")
            if imageButton then
                local label = findLabelRecursive(imageButton)
                if label and not label.Visible then
                    return false
                end
            end
        end
    end
    return true
end

-- Get list of missing pets
local function getMissingPets(petsFolder)
    local missingPets = {}
    for _, petFrame in pairs(petsFolder:GetChildren()) do
        if petFrame:IsA("Frame") then
            local label = petFrame:FindFirstChildWhichIsA("TextLabel") or petFrame:FindFirstChild("Label")
            if label and not label.Visible then
                table.insert(missingPets, petFrame.Name)
            end
        end
    end
    return missingPets
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
    local tweenInfo = TweenInfo.new(getgenv().Settings.TweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = goalCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- Hatch eggs
local function hatchEgg(eggName, amount)
    remoteEvent:FireServer("HatchEgg", eggName, amount)
end

-- Main logic
task.spawn(function()
    -- Open then close index on start to ensure proper state
    openIndexBook()
    openIndexBook()

    for _, eggName in ipairs(getgenv().Settings.EggOrder) do
        local eggFrame = eggGuiPath:FindFirstChild(eggName)
        if eggFrame and eggFrame:FindFirstChild("Pets") then
            local petsFolder = eggFrame.Pets

            print("[Indexing] Checking egg: " .. eggName)

            -- If all pets already indexed, notify and skip
            if areAllPetsIndexed(petsFolder) then
                print("[Indexing] All pets indexed in " .. eggName)
            else
                -- Send webhook for missing pets
                local missingPets = getMissingPets(petsFolder)
                if #missingPets > 0 then
                    sendWebhook("🔍 Missing pets in **" .. eggName .. "**:\n- " .. table.concat(missingPets, "\n- "))
                end

                -- Tween to egg location
                tweenToEgg(eggName)

                local hatchCount = 0
                repeat
                    hatchEgg(eggName, getgenv().Settings.HatchAmount)
                    hatchCount += 1

                    -- Open index to refresh GUI after every hatch
                    openIndexBook()

                    -- Delay between hatches
                    task.wait(getgenv().Settings.HatchDelay)

                    -- Every few hatches add extra delay
                    if hatchCount % getgenv().Settings.ExtraDelayEvery == 0 then
                        task.wait(getgenv().Settings.ExtraDelaySeconds)
                    end

                until areAllPetsIndexed(petsFolder)

                print("[Indexing] Completed indexing for: " .. eggName)
                sendWebhook("✅ Completed indexing for **" .. eggName .. "**!")
            end
        end
    end

    print("[Indexing] All eggs processed.")
    sendWebhook("🎉 All eggs fully indexed! 🎉")
end)
