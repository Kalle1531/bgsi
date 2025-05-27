-- loader.lua

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")
local indexFrame = screenGui:WaitForChild("Index")
local networkRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteEvent")

-- Your global config
if not getgenv().Settings then
    getgenv().Settings = {
        WebhookURL = "https://discord.com/api/webhooks/1376881027112239155/nQtZhLMRAo3b1gOw9y0J2woPBmtF3sfyKdA6btPGsHPJ6yRq_jrUDMP3-zYVe8YSsWjp",
        WebhookName = "Cat Index",
        WebhookAvatarURL = "https://i.imgur.com/ur1iXmZ.png",

        HatchAmount = 3,
        HatchDelay = 2,
        ExtraDelayEvery = 3,
        ExtraDelaySeconds = 3,

        TweenDuration = 1,
        IndexButtonToggleDelay = 0.2,

        EggOrder = {
            "Common Egg", "Spotted Egg", "Iceshard Egg", "Spikey Egg",
            "Magma Egg", "Crystal Egg", "Lunar Egg", "Void Egg",
            "Hell Egg", "Nightmare Egg", "Rainbow Egg"
        },

        AutoDeleteRarities = { "Common", "Rare" }
    }
end

-- Pet rarities table (FULL list)
local PetRarities = {
    ["Doggy"] = "Common",
    ["Kitty"] = "Common",
    ["Bunny"] = "Unique",
    ["Bear"] = "Rare",
    ["King Doggy"] = "Secret",
    ["Mouse"] = "Common",
    ["Wolf"] = "Common",
    ["Fox"] = "Unique",
    ["Polar Bear"] = "Rare",
    ["Panda"] = "Epic",
    ["Ice Kitty"] = "Common",
    ["Deer"] = "Common",
    ["Ice Wolf"] = "Unique",
    ["Piggy"] = "Rare",
    ["Ice Deer"] = "Rare",
    ["Ice Dragon"] = "Epic",
    ["Golem"] = "Common",
    ["Dinosaur"] = "Common",
    ["Ruby Golem"] = "Unique",
    ["Dragon"] = "Rare",
    ["Dark Dragon"] = "Epic",
    ["Emerald Golem"] = "Legendary",
    ["Magma Doggy"] = "Common",
    ["Magma Deer"] = "Unique",
    ["Magma Fox"] = "Unique",
    ["Magma Bear"] = "Rare",
    ["Demon"] = "Epic",
    ["Inferno Dragon"] = "Legendary",
    ["Cave Bat"] = "Common",
    ["Dark Bat"] = "Unique",
    ["Angel"] = "Rare",
    ["Emerald Bat"] = "Epic",
    ["Unicorn"] = "Legendary",
    ["Flying Pig"] = "Legendary",
    ["Space Mouse"] = "Common",
    ["Space Bull"] = "Unique",
    ["Lunar Fox"] = "Rare",
    ["Lunarcorn"] = "Epic",
    ["Lunar Serpent"] = "Legendary",
    ["Electra"] = "Legendary",
    ["Void Kitty"] = "Common",
    ["Void Bat"] = "Unique",
    ["Void Fox"] = "Rare",
    ["Void Demon"] = "Epic",
    ["Dark Phoenix"] = "Legendary",
    ["Neon Elemental"] = "Legendary",
    ["NULLVoid"] = "Legendary",
    ["Hell Piggy"] = "Common",
    ["Hell Dragon"] = "Unique",
    ["Hell Crawler"] = "Rare",
    ["Inferno Demon"] = "Epic",
    ["Inferno Cube"] = "Legendary",
    ["Virus"] = "Legendary",
    ["Demon Doggy"] = "Common",
    ["Skeletal Deer"] = "Unique",
    ["Night Crawler"] = "Rare",
    ["Hell Bat"] = "Epic",
    ["Green Hydra"] = "Legendary",
    ["Demonic Hydra"] = "Legendary",
    ["The Overlord"] = "Secret",
    ["Red Golem"] = "Common",
    ["Orange Deer"] = "Unique",
    ["Yellow Fox"] = "Rare",
    ["Green Angel"] = "Epic",
    ["Hexarium"] = "Legendary",
    ["Rainbow Shock"] = "Legendary",
    ["Manny"] = "Rare",
    ["Manicorn"] = "Epic",
    ["Sigma Serpent"] = "Legendary",
    ["Manarium"] = "Legendary",
    ["MAN FACE GOD"] = "Secret",
    ["Bunnnny"] = "Common",
    ["Long Kitty"] = "Rare",
    ["DOOF"] = "Legendary",
    ["ROUND"] = "Legendary",
    ["Silly Doggy :)"] = "Secret",
    ["Enlightened Kitty"] = "Rare",
    ["Judgement"] = "Epic",
    ["Ophanim"] = "Legendary",
    ["Seraph"] = "Legendary",
    ["Lunar Deity"] = "Legendary",
    ["Solar Deity"] = "Legendary",
    ["Crescent Empress"] = "Legendary",
    ["Avernus"] = "Secret",
    ["Discord Imp"] = "Legendary",
    ["Flying Gem"] = "Legendary",
    ["Umbra"] = "Legendary",
    ["Trio Cube"] = "Legendary",
    ["Evil Shock"] = "Legendary",
    ["Holy Shock"] = "Legendary",
    ["King Soul"] = "Legendary",
    ["Demonic Dogcat"] = "Legendary",
    ["Rainbow Blitz"] = "Legendary",
    ["Kitsune"] = "Legendary",
    ["Abyssal Dragon"] = "Legendary",
    ["Hacker Prism"] = "Legendary",
    ["Moonburst"] = "Legendary",
    ["Sunburst"] = "Legendary",
    ["Midas"] = "Legendary",
    ["Patronus"] = "Legendary",
    ["Dowodle"] = "Legendary",
    ["Beta TV"] = "Legendary",
    ["Enraged Phoenix"] = "Legendary",
    ["Electra Hydra"] = "Legendary",
    ["Paper Doggy"] = "Common",
    ["Paper Bunny"] = "Unique",
    ["Chubby Bunny"] = "Rare",
    ["Hatchling"] = "Epic",
    ["Sweet Treat"] = "Legendary",
    ["Rainbow Marshmellow"] = "Legendary",
    ["Giant Chocolate Chicken"] = "Secret",
    ["Bunny Doggy"] = "Common",
    ["Egg Bunny"] = "Unique",
    ["Angel Bunny"] = "Epic",
    ["Seraphic Bunny"] = "Legendary",
    ["Ethereal Bunny"] = "Legendary",
    ["Cardinal Bunny"] = "Legendary",
    ["Easter Basket"] = "Secret",
    ["Bow Bunny"] = "Common",
    ["Easter Egg"] = "Unique",
    ["Flying Bunny"] = "Epic",
    ["Easter Serpent"] = "Legendary",
    ["Dualcorn"] = "Legendary",
    ["Holy Egg"] = "Legendary",
    ["Godly Gem"] = "Secret",
    ["Dementor"] = "Secret",
    ["Bronze Bunny"] = "Common",
    ["Silver Fox"] = "Unique",
    ["Golden Dragon"] = "Epic",
    ["Diamond Serpent"] = "Legendary",
    ["Diamond Hexarium"] = "Legendary",
    ["King Pufferfish"] = "Legendary",
    ["Royal Trophy"] = "Secret",
    ["Chocolate Bunny"] = "Legendary",
    ["Easter Fluffle"] = "Legendary",
    ["Dark Serpent"] = "Legendary",
    ["Infernus"] = "Legendary",
    ["Elite Challenger"] = "Legendary",
    ["Elite Soul"] = "Legendary",
    ["Competitor Doggy"] = "Rare",
    ["Golden Golem"] = "Epic",
    ["Parasite"] = "Legendary",
    ["Starlight"] = "Legendary",
    ["Overseer"] = "Legendary",
    ["Game Doggy"] = "Common",
    ["Gamer Boi"] = "Common",
    ["Queen of Hearts"] = "Rare",
    ["Mining Doggy"] = "Common",
    ["Mining Bat"] = "Unique",
    ["Cave Mole"] = "Rare",
    ["Ore Golem"] = "Epic",
    ["Crystal Unicorn"] = "Legendary",
    ["Stone Gargoyle"] = "Legendary",
    ["Robo Kitty"] = "Common",
    ["Martian Kitty"] = "Unique",
    ["Alien Kitty"] = "Rare",
    ["Alien Dragon"] = "Epic",
    ["Alien God"] = "Legendary",
    ["Robo Bunny"] = "Common",
    ["Robo Bunny Jr."] = "Unique",
    ["The King"] = "Secret",
    ["Rainbow Unicorn"] = "Legendary",
    ["Minerals"] = "Common",
    ["Mineral Bunny"] = "Unique",
    ["Mineral Dragon"] = "Rare",
    ["Mineral Phoenix"] = "Epic",
    ["Mineral Hydra"] = "Legendary",
    ["Steel Kitty"] = "Common",
    ["Steel Bunny"] = "Unique",
    ["Steel Dragon"] = "Rare",
    ["Steel Phoenix"] = "Epic",
    ["Steel Hydra"] = "Legendary",
    ["Void Stone"] = "Common",
    ["Void Bunny"] = "Unique",
    ["Void Dragon"] = "Rare",
    ["Void Phoenix"] = "Epic",
    ["Void Hydra"] = "Legendary",
}

-- Utility to send webhook messages
local function sendWebhook(message)
    local success, err = pcall(function()
        local data = HttpService:JSONEncode({
            username = getgenv().Settings.WebhookName or "Cat Index",
            avatar_url = getgenv().Settings.WebhookAvatarURL or "https://i.imgur.com/ur1iXmZ.png",
            content = message
        })
        local requestFunc = (syn and syn.request) or (http_request) or (request)
        if requestFunc then
            requestFunc({
                Url = getgenv().Settings.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
        else
            warn("No HTTP request function available for webhook")
        end
    end)
    if not success then
        warn("Webhook failed:", err)
    end
end

-- Function to toggle autodelete for a pet and notify webhook
local function toggleAutoDelete(petName, toggle)
    if not petName then return end
    networkRemote:FireServer("ToggleAutoDelete", petName)
    sendWebhook("AutoDelete toggled **" .. (toggle and "ON" or "OFF") .. "** for pet: **" .. petName .. "** (rarity: " .. (PetRarities[petName] or "Unknown") .. ")")
end

-- Run autodelete for all pets of specified rarities
local function runAutoDelete()
    local settings = getgenv().Settings
    if not settings or not settings.AutoDeleteRarities then return end

    for petName, rarity in pairs(PetRarities) do
        for _, delRarity in ipairs(settings.AutoDeleteRarities) do
            if rarity == delRarity then
                toggleAutoDelete(petName, true)
                task.wait(0.2)
                break
            end
        end
    end
end

-- Opens the index for a given egg and waits for it to open
local function openIndex(eggName)
    if not eggName then return false end
    local openButton = indexFrame:FindFirstChild(eggName)
    if not openButton then return false end

    openButton.MouseButton1Click:Fire()
    task.wait(getgenv().Settings.IndexButtonToggleDelay or 0.2)

    -- Wait for the egg's index page to be visible (you might have to adjust the path)
    local eggIndexFrame = indexFrame:FindFirstChild(eggName .. "Index")
    if not eggIndexFrame then return false end

    -- Tween in for smoothness (optional)
    TweenService:Create(eggIndexFrame, TweenInfo.new(getgenv().Settings.TweenDuration or 1), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(getgenv().Settings.TweenDuration or 1)
    return true
end

-- Closes the index for a given egg
local function closeIndex(eggName)
    if not eggName then return end
    local closeButton = indexFrame:FindFirstChild(eggName)
    if closeButton then
        closeButton.MouseButton1Click:Fire()
        task.wait(getgenv().Settings.IndexButtonToggleDelay or 0.2)
    end
end

-- Check if pet is missing on the index egg page
local function isPetMissing(eggName, petName)
    local eggIndexFrame = indexFrame:FindFirstChild(eggName .. "Index")
    if not eggIndexFrame then return true end

    local petLabel = eggIndexFrame:FindFirstChild(petName)
    if not petLabel then return true end

    -- If label visible = pet obtained, else missing
    return not petLabel.Visible
end

-- Main hatch function
local function hatchEgg(eggName, amount)
    for i = 1, amount do
        networkRemote:FireServer("BuyEgg", eggName, false) -- false = normal hatch, true=auto hatch? Adjust if needed
        sendWebhook("Hatched **".. eggName .."** (egg #" .. i .. "/" .. amount .. ")")
        task.wait(getgenv().Settings.HatchDelay or 2)

        -- Every ExtraDelayEvery hatches, wait ExtraDelaySeconds
        if i % (getgenv().Settings.ExtraDelayEvery or 3) == 0 then
            task.wait(getgenv().Settings.ExtraDelaySeconds or 3)
        end
    end
end

-- Main indexer logic
local function runIndex()
    runAutoDelete()

    for _, eggName in ipairs(getgenv().Settings.EggOrder) do
        if openIndex(eggName) then
            -- Loop through all pets in this egg rarity and check missing
            local missingPets = {}

            for petName, rarity in pairs(PetRarities) do
                -- Simplify: We assume pet belongs to egg if petName contains eggName (or you can have a mapping)
                -- For real BGSI, mapping is more complex, so here simplified:
                if petName:find(eggName:gsub(" Egg", "")) then
                    if isPetMissing(eggName, petName) then
                        table.insert(missingPets, petName)
                    end
                end
            end

            -- Send webhook if any missing pets for this egg
            if #missingPets > 0 then
                sendWebhook("Missing pets in egg **".. eggName .."**: ".. table.concat(missingPets, ", "))
            end

            -- Hatch missing pets
            hatchEgg(eggName, getgenv().Settings.HatchAmount or 3)

            closeIndex(eggName)
            task.wait(1)
        else
            warn("Failed to open index for egg:", eggName)
        end
    end

    sendWebhook("Indexing complete.")
end

-- Run main
runIndex()
