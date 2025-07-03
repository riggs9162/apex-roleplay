GM.Name = "Half-Life 2 Roleplay"
GM.Author = "Apex Roleplay, Crow Network, Cortex Community, Aerolite and many more contributors!"
GM.Version = "2.4.3"

-- Load addons and files
GM:LoadFile("resources.lua", "shared")

-- Load the MySQL library
GM:LoadFile("mysql.lua", "server")

-- Load third-party libraries
GM:LoadFolder("thirdparty", nil, true)

-- Pre-load the configs
GM:LoadFile("config.lua", "shared")

-- Include the admin system
GM:LoadFolder("fpp", nil, true)
GM:LoadFolder("fadmin", nil, true)

-- Include the main gamemode files
GM:LoadFolder("client", nil, true)
GM:LoadFolder("shared", nil, true)
GM:LoadFolder("server", nil, true)

-- Continue with the definitions and entities
GM:LoadFile("jobs.lua", "shared")
GM:LoadFile("entities.lua", "shared")
GM:LoadFile("definitions.lua", "shared")

-- Now load the modules
GM:LoadFolder("modules", nil, true)

print("Loaded " .. GM.Name .. " gamemode version " .. GM.Version .. "!")