local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Player & UI references
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")
local hud = screenGui:WaitForChild("HUD")
local right = hud:WaitForChild("Right")
local index = right:WaitForChild("Index")
local indexButton = index:WaitForChild("Button")

local eggGuiPath = playerGui.ScreenGui.Index.Container.Left.Index.ScrollingFrame
local eggModels = workspace:WaitForChild("Rendered"):WaitForChild("Generic")

local remoteEvent = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("RemoteEvent")

local function openIndexBook()
    indexButton:SetAttribute("Pressed", true)
    task.wait(getgenv().Settings.IndexButtonToggleDelay)
    indexButton:SetAttribute("Pressed", false)
    task.wait(0.5) -- wait for GUI to fully open
end

local function closeIndexBook()
    openIndexBook() -- toggle again closes it
    task.wait(0.5)
end

-- Helper: Send Discord webhook message
local function sendWebhook(message)
    local data = HttpService:JSONEncode({
        username = getgenv().Settings.WebhookName,
        avatar_url = getgenv().Settings.WebhookAvatarURL,
        content = "**[BGSI Auto Indexer]**\n" .. message
    })

    local success, err = pcall(function()
        (syn and syn.request or http_request or request)({
            Url = getgenv().Settings.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
    if not success then
        warn("Webhook send failed:", err)
    end
end

-- Recursive find label in pet frame for visibility check
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

-- Check if all pets in egg are indexed
local function areAllPetsIndexed(petsFolder)
    for _, petFrame in pairs(petsFolder:GetChildren()) do
        if petFrame:IsA("Frame") then
            local imageButton = petFrame:FindFirstChildWhichIsA("ImageButton")
            if imageButton then
                local label = findLabelRecursive(imageButton)
                if label then
                    if not label.Visible then
                        print("[✗] Not indexed: " .. petFrame.Name)
                        return false
                    end
                else
                    print("[!] Missing label in " .. petFrame.Name)
                    return false
                end
            end
        end
    end
    return true
end

-- Tween player to egg model position
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

-- Toggle autodelete for a pet
local function toggleAutoDeletePet(petName)
    remoteEvent:FireServer("ToggleAutoDelete", petName)
    print("[AutoDelete] Toggled autodelete for:", petName)
end

-- Auto delete pets with specified rarities
local function autoDeletePets(petsFolder)
    for _, petFrame in pairs(petsFolder:GetChildren()) do
        if petFrame:IsA("Frame") then
            local petName = petFrame.Name
            local rarity = PetRarities[petName]
            if rarity and table.find(getgenv().Settings.AutoDelete, rarity) then
                toggleAutoDeletePet(petName)
            end
        end
    end
end

-- Hide Index frame by spamming Visible = false
local function hideIndexFrame()
    local indexFrame = playerGui.ScreenGui:FindFirstChild("Index")
    if not indexFrame then return end
    task.spawn(function()
        while true do
            indexFrame.Visible = false
            task.wait(0.1)
        end
    end)
end

-- Main logic
local function main()
    -- Hide the index GUI frame
    hideIndexFrame()

    -- On startup, open and close the index once to reset GUI state
    openIndexBook()
    closeIndexBook()

    for _, eggName in ipairs(getgenv().Settings.EggOrder) do
        local eggFrame = eggGuiPath:FindFirstChild(eggName)
        if eggFrame and eggFrame:FindFirstChild("Pets") then
            local petsFolder = eggFrame.Pets

            sendWebhook("🔍 Checking index for: " .. eggName)

            if areAllPetsIndexed(petsFolder) then
                print("✅ All pets already indexed in: " .. eggName)
                sendWebhook("✅ All pets already indexed in: " .. eggName)
            else
                print("🔁 Indexing missing pets in: " .. eggName)
                sendWebhook("🔁 Indexing missing pets in: " .. eggName)

                tweenToEgg(eggName)

                local hatchCount = 0
                repeat
                    hatchEgg(eggName, getgenv().Settings.HatchAmount)
                    hatchCount = hatchCount + 1

                    -- Open index after every hatch
                    openIndexBook()

                    task.wait(getgenv().Settings.HatchDelay)

                    -- Every X hatches, add extra delay to allow index to refresh fully
                    if hatchCount % getgenv().Settings.ExtraDelayEvery == 0 then
                        task.wait(getgenv().Settings.ExtraDelaySeconds)
                    end

                    -- Auto-delete pets after hatch
                    autoDeletePets(petsFolder)

                until areAllPetsIndexed(petsFolder)

                sendWebhook("✅ Done indexing: " .. eggName)
            end
        else
            warn("Egg frame not found or missing Pets folder: " .. eggName)
        end
    end

    sendWebhook("🎉 All eggs indexed successfully!")
    print("✅✅✅ All pets in all eggs indexed!")
end

-- Start the script
task.spawn(main)
