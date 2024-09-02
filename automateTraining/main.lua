gameLoaded = false

local function automateTraining()
    tes3.messageBox("F12 key was pressed!") -- For testing purposes, remove if no longer needed

    -- Create menu asking for which magic skill to train

    -- Once a magic school is selected, find all character spells under this school, and choose cheapest cost spell

    -- Equip spell, and activate it endlessly until magicka runs out
end

-- Function to check if the pressed key is F12, and to check if game is loaded, in order to activate the automation
local function onKeyPress(e)
    if e.keyCode == 88 and gameLoaded then
        automateTraining()
    end
end

-- Function to set a flag when a save game is loaded, to prevent running the script whilst on any loading screens
local function onGameLoaded()
    gameLoaded = true
end

-- Function to set a flag whilst on a menu i.e. main menu, pause menu
local function onMenu()
    gameLoaded = false
end

-- Register the event handler on key press
event.register("keyDown", onKeyPress)

-- Register event handler to check if a game save has been loaded
event.register("loaded", onGameLoaded)

-- Register event handler to check if user is on main menu / is in process of loading
event.register("menuEnter", onMenu)