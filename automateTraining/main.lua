gameLoaded = false -- Flag set when save game is loaded, a prerequisite to the automatic spell casting
toggleTraining = false -- Flag which is set true or false, when the F12 key is pressed, in order to activate or deactivate the spell casting automation

local function castSpell()
    -- Create menu asking for which magic skill to train

    -- Once a magic school is selected, find all character spells under this school, and choose cheapest cost spell

    -- Equip spell, and activate it endlessly until magicka runs out

        local player = tes3.player

        local magicSlot = tes3.mobilePlayer.currentSpell -- Get current equipped magic spell

        -- Check if player has enough magicka before casting spell

        -- Check if the player has a spell readied
        if magicSlot then
            -- Cast the currently equipped spell
            tes3.cast({
                reference = player,    
                target = tes3.getPlayerTarget(),
                spell = magicSlot,
                alwaysSucceeds = false
            })
            -- tes3.messageBox("Casting equipped spell: %s", magicSlot.id)
        end
end

local function automateTraining()
    castSpell()
end

-- Handles loop for repeated spell casting
local function onEveryFrame(e)
    if toggleTraining then
        -- set toggleTraining to false if creating a menu, so that menu is not appearing repeatedly
        automateTraining()
    end
end

-- Function to check if the pressed key is F12, and to check if game is loaded, in order to activate the automation
local function onKeyPress(e)
    if e.keyCode == 88 and gameLoaded then

        if toggleTraining then
            toggleTraining = false -- Disable spell casting automation
            tes3.messageBox("Deactivating training script.")
        else
            toggleTraining = true -- Enable spell casting automation
            tes3.messageBox("Activating training script.")
        end

    end
end

-- Function to set a flag when a save game is loaded, to prevent running the script whilst on any loading screens
local function onGameLoaded()
    gameLoaded = true
end

-- Function to set a flag whilst on a menu i.e. main menu, pause menu
local function enterMenu()
    gameLoaded = false
end

-- Register the event handler on key press
event.register("keyDown", onKeyPress)

-- Register event handler to check if a game save has been loaded
event.register("loaded", onGameLoaded)

-- Register event handler to check if user is entering a menu
event.register("menuEnter", enterMenu)

-- Register event handler to check if user is exiting a menu
event.register("menuExit", onGameLoaded)

-- Register event handler to perform automated casting without the need for a 'while' loop
event.register(tes3.event.simulate, onEveryFrame)  