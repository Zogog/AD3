--// Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Create Window
local Window = Rayfield:CreateWindow({
    Name = "Zogog Adopt Me Toolkit",
    Icon = nil, -- no icon for now
    LoadingTitle = "Loading Toolkit",
    LoadingSubtitle = "Clean Starter UI",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ZogogToolkit",
        FileName = "ToolkitConfig"
    }
})

--// Tabs
local MainTab      = Window:CreateTab("Main", "home")
local PetsTab      = Window:CreateTab("Pets", "paw-print")
local AilmentsTab  = Window:CreateTab("Ailments", "heart-pulse")
local DebugTab     = Window:CreateTab("Debug", "terminal")

---------------------------------------------------------------------
-- MAIN TAB
---------------------------------------------------------------------
MainTab:CreateSection("Welcome")
MainTab:CreateLabel("Simple, clean UI. Ready to expand.")

MainTab:CreateButton({
    Name = "Reload Script",
    Callback = function()
        Rayfield:Notify({
            Title = "Reloading",
            Content = "Toolkit is restarting...",
            Duration = 2
        })
        -- replace with your raw script URL when hosted
        -- loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()
    end
})

---------------------------------------------------------------------
-- PETS TAB
---------------------------------------------------------------------
PetsTab:CreateSection("Pet Tools")

-- basic pet dropdown (can be expanded later)
local PetDropdown = PetsTab:CreateDropdown({
    Name = "Select Pet (placeholder)",
    Options = {"None"},
    CurrentOption = {"None"},
    MultipleOptions = false,
    Callback = function(option)
        print("Selected pet:", option[1])
    end
})

PetsTab:CreateButton({
    Name = "Refresh Pet List (placeholder)",
    Callback = function()
        local Loads = require(game.ReplicatedStorage.Fsys).load
        local ClientData = Loads("ClientData")

        local pets = {}
        for uuid, data in pairs(ClientData.get("inventory").pets or {}) do
            table.insert(pets, data.id)
        end

        if #pets == 0 then
            pets = {"None"}
        end

        PetDropdown:Refresh(pets)
    end
})

---------------------------------------------------------------------
-- PET SPAWNER MODULE
---------------------------------------------------------------------
PetsTab:CreateSection("Pet Spawner")

local PetNameBox = PetsTab:CreateInput({
    Name = "Pet Name",
    PlaceholderText = "Enter exact pet name (e.g., unicorn)",
    RemoveTextAfterFocusLost = false,
    Callback = function() end
})

local PetTypeDropdown = PetsTab:CreateDropdown({
    Name = "Pet Type",
    Options = {"FR", "NFR", "MFR"},
    CurrentOption = {"FR"},
    MultipleOptions = false,
    Callback = function(option)
        getgenv().SpawnerPetType = option[1]
    end
})

getgenv().SpawnerPetType = "FR"

local function DeepClone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = (type(v) == "table") and DeepClone(v) or v
    end
    return copy
end

local function GenerateProperties()
    local t = getgenv().SpawnerPetType
    return {
        flyable = (t == "FR" or t == "NFR" or t == "MFR"),
        rideable = (t == "FR" or t == "NFR" or t == "MFR"),
        neon = (t == "NFR" or t == "MFR"),
        mega_neon = (t == "MFR"),
        age = 1
    }
end

local function SpawnPet(petName)
    local Loads = require(game.ReplicatedStorage.Fsys).load
    local ClientData = Loads("ClientData")
    local InventoryDB = Loads("InventoryDB")
    local Inventory = ClientData.get("inventory")

    if not Inventory.pets then
        Inventory.pets = {}
    end

    for category, items in pairs(InventoryDB) do
        for id, item in pairs(items) do
            if category == "pets" and item.name:lower() == petName:lower() then
                local new = DeepClone(item)
                local uuid = game.HttpService:GenerateGUID(false)

                new.unique = "uuid_" .. uuid
                new.category = "pets"
                new.properties = GenerateProperties()
                new.newness_order = math.random(1, 999999)

                Inventory.pets[uuid] = new

                Rayfield:Notify({
                    Title = "Pet Spawned",
                    Content = "Added " .. item.name .. " (" .. getgenv().SpawnerPetType .. ") to your inventory",
                    Duration = 3
                })

                return
            end
        end
    end

    Rayfield:Notify({
        Title = "Pet Not Found",
        Content = "No pet named '" .. petName .. "' exists in InventoryDB",
        Duration = 3
    })
end

PetsTab:CreateButton({
    Name = "Spawn Pet",
    Callback = function()
        local name = PetNameBox:Get()
        if name == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a pet name",
                Duration = 2
            })
            return
        end
        SpawnPet(name)
    end
})

---------------------------------------------------------------------
-- AILMENTS TAB
---------------------------------------------------------------------
AilmentsTab:CreateSection("Ailment Tools")

AilmentsTab:CreateDropdown({
    Name = "Disable Ailments (placeholder)",
    Options = {
        "hungry","thirsty","sleepy","dirty","toilet","sick","play","ride",
        "salon","bored","camping","beach_party","pizza_party","moon",
        "school","walk","pet_me"
    },
    CurrentOption = {"None"},
    MultipleOptions = true,
    Callback = function(selected)
        print("Disabled ailments:", selected)
    end
})

AilmentsTab:CreateToggle({
    Name = "Live Ailment Monitor (placeholder)",
    CurrentValue = false,
    Callback = function(enabled)
        print("Ailment monitor:", enabled)
    end
})

---------------------------------------------------------------------
-- DEBUG TAB
---------------------------------------------------------------------
DebugTab:CreateSection("Debug")

DebugTab:CreateButton({
    Name = "Print Inventory",
    Callback = function()
        local Loads = require(game.ReplicatedStorage.Fsys).load
        local ClientData = Loads("ClientData")
        print(ClientData.get("inventory"))
    end
})

DebugTab:CreateToggle({
    Name = "Enable Debug Logging (placeholder)",
    CurrentValue = false,
    Callback = function(v)
        print("Debug logging:", v)
    end
})
