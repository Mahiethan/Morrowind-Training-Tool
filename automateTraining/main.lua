gameLoaded = false

local function automateTraining()
    tes3.messageBox("F12 key was pressed!") -- For testing purposes, remove if no longer needed

    -- Define the length of the raycast
    local maxDistance = 500 -- Adjust as needed, this is the distance to check

    -- Get the player's camera position and forward direction
    local camera = tes3.getPlayerEyePosition()
    local direction = tes3.getPlayerEyeVector()

    -- Perform the raycast
    local result = tes3.rayTest{
        position = camera,
        direction = direction,
        maxDistance = maxDistance,
        ignore = { tes3.player },
        root = tes3.game.worldPickRoot, -- Ensures only world objects are tested
    }

    -- Print out the reference which the player is looking at
    if result and result.reference then
        local ref = result.reference
        tes3.messageBox(ref)
    end
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