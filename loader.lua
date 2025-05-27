local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("ScreenGui")
local hud = screenGui:WaitForChild("HUD")
local right = hud:WaitForChild("Right")
local index = right:WaitForChild("Index")
local indexButton = index:WaitForChild("Button")
local indexFrame = playerGui:WaitForChild("Index")
local NetworkRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteEvent")

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
    ["Cyber Wolf"] = "Epic",
    ["Cyborg Phoenix"] = "Legendary",
    ["Space Invader"] = "Legendary",
    ["Bionic Shard"] = "Legendary",
    ["Mech Robot"] = "Secret",
    ["Sleepy Bunny"] = "Rare",
    ["Starry Lamb"] = "Epic",
    ["Moon Deer"] = "Legendary",
    ["Nebula"] = "Legendary",
    ["Dusk"] = "Legendary",
    ["Dawn"] = "Legendary",
    ["Moonlight"] = "Legendary",
    ["Luminosity"] = "Secret",
    ["Magmas"] = "Legendary",
    ["Dragon Plushie"] = "Legendary",
    ["Dice Split"] = "Legendary",
    ["Fancy Demon"] = "Rare",
    ["Happy Dice"] = "Epic",
    ["Game Master"] = "Legendary",
    ["Jackpot"] = "Legendary",
    ["Hell Demon"] = "Common",
    ["Demon Angel"] = "Rare",
    ["Crimson Butterfly"] = "Legendary",
    ["Demonweb"] = "Legendary",
    ["Crimson Bloodmoon"] = "Legendary",
    ["Lord Shock"] = "Secret",
    ["Cute Deer"] = "Common",
    ["Emerald Wolf"] = "Rare",
    ["Prismatic"] = "Legendary",
    ["Darkness Creature"] = "Legendary",
    ["Corrupt Glitch"] = "Legendary",
    ["Wolflord"] = "Secret",
    ["Sir Doggyton"] = "Legendary",
    ["Vaporium"] = "Legendary",
    ["D0GGY1337"] = "Secret",
    ["Prophet"] = "Secret",
    ["Queen Kitty"] = "Secret",
    ["Toilet Doggy"] = "Legendary",
    ["Capybara Plushie"] = "Legendary",
    ["Neon Doggy"] = "Legendary",
    ["Candy Kitty"] = "Legendary",
    ["Starlight Kitty"] = "Legendary",
    ["Electric Kitty"] = "Legendary",
    ["Frosty Kitty"] = "Legendary",
    ["Frosty Doggy"] = "Legendary",
    ["Neon Bear"] = "Legendary",
    ["Neon Bunny"] = "Legendary",
    ["Neon Fox"] = "Legendary",
    ["Neon Piggy"] = "Legendary",
    ["Neon Deer"] = "Legendary",
    ["Neon Golem"] = "Legendary",
    ["Neon Panda"] = "Legendary",
    ["Neon Kitty"] = "Legendary",
    ["Neon Wolf"] = "Legendary",
    ["Neon Dragon"] = "Legendary",
    ["Neon Angel"] = "Legendary",
    ["Neon Demon"] = "Legendary",
    ["Neon Void"] = "Legendary",
    ["Neon Hell"] = "Legendary",
}

-- Utility to get rarity for a pet name
local function GetRarity(petName)
    return PetRarities[petName] or "Unknown"
end

-- Webhook send function
local function SendWebhook(message)
    if not getgenv().Settings.WebhookURL or getgenv().Settings.WebhookURL == "" then return end

    local data = {
        username = getgenv().Settings.WebhookName or "BGSI Auto Indexer",
        avatar_url = getgenv().Settings.WebhookAvatarURL or "",
        content = message
    }

    local encoded = HttpService:JSONEncode(data)
    local success, err = pcall(function()
        HttpService:PostAsync(getgenv().Settings.WebhookURL, encoded, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Webhook send failed: " .. tostring(err))
    end
end

-- Index toggle functions
local function OpenIndex()
    if not indexFrame.Visible then
        indexButton.MouseButton1Click:Fire()
        wait(getgenv().Settings.TweenDuration or 1)
    end
end

local function CloseIndex()
    if indexFrame.Visible then
        indexButton.MouseButton1Click:Fire()
        wait(getgenv().Settings.TweenDuration or 1)
    end
end

-- Keep Index Frame hidden forcibly (spam toggle visibility)
coroutine.wrap(function()
    while true do
        indexFrame.Visible = false
        wait(0.1)
    end
end)()

-- Example function to Auto-Delete pets by rarity after hatching
local function AutoDeletePets()
    -- This depends on your pet deletion RemoteEvent and method
    -- Usually you find pets in your inventory, check their rarity, and send delete requests
    -- Placeholder example:
    for _, petModel in pairs(workspace.Pets:GetChildren()) do
        local petName = petModel.Name
        local rarity = GetRarity(petName)
        if table.find(getgenv().Settings.AutoDeleteRarities, rarity) then
            -- Fire remote to delete pet (example event name)
            if NetworkRemote then
                NetworkRemote:FireServer("DeletePet", petModel)
                print("Deleted pet:", petName, "rarity:", rarity)
            end
        end
    end
end

-- Hatch eggs logic (simplified)
local function HatchEgg(eggName)
    if not eggName then return end
    print("Hatching egg:", eggName)

    -- Fire remote to hatch egg (example)
    if NetworkRemote then
        NetworkRemote:FireServer("HatchEgg", eggName, getgenv().Settings.HatchAmount)
        SendWebhook("Hatching " .. tostring(getgenv().Settings.HatchAmount) .. " x " .. eggName)
    end

    wait(getgenv().Settings.HatchDelay or 2)
end

-- Main loop example (goes through eggs, hatches, auto deletes)
coroutine.wrap(function()
    while true do
        for i, eggName in ipairs(getgenv().Settings.EggOrder) do
            OpenIndex()

            HatchEgg(eggName)

            AutoDeletePets()

            CloseIndex()

            -- Extra delay every X hatches
            if i % (getgenv().Settings.ExtraDelayEvery or 3) == 0 then
                wait(getgenv().Settings.ExtraDelaySeconds or 3)
            end
        end
        wait(5) -- Delay before next full cycle
    end
end)()
