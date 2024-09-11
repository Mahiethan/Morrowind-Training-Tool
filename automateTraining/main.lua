gameLoaded = false -- Flag set when save game is loaded, a prerequisite to the automatic spell casting
toggleTraining = false -- Flag which is set true or false, when the F12 key is pressed, in order to activate or deactivate the spell casting automation

local selectedMagic -- Value specifying the selected magic school
local spellSelected = false -- Flag set when a magic school is selected from the menu, in order to start repeatedly casting the spell
local cheapestSpell -- Specifies the cheapest magicka cost spell, under the selected magic school

-- IDs for the menu and its buttons
local menuId = tes3ui.registerID("MagicSchoolMenu") -- Register a unique ID for the menu
local buttonBlockId = tes3ui.registerID("MagicSchoolSelection") -- Register a unique ID for button blocks

-- List of magic schools to display and select
local options = {
    "Alteration",
    "Conjuration",
    "Destruction",
    "Illusion",
    "Mysticism",
    "Restoration"
}

-- Dictionary used to convert the magic school string value to its respective index value
local optionValues = {
    ["Alteration"] = tes3.magicSchool.alteration,
    ["Conjuration"] = tes3.magicSchool.conjuration,
    ["Destruction"] = tes3.magicSchool.destruction,
    ["Illusion"] = tes3.magicSchool.illusion,
    ["Mysticism"] = tes3.magicSchool.mysticism,
    ["Restoration"] = tes3.magicSchool.restoration
}

-- Function used to close menu correctly
local function clearMenu()
    local menu = tes3ui.findMenu(menuId)
    if menu then
        menu:destroy() -- Destroy the menu when done
    end

    tes3ui.leaveMenuMode() -- Close the menu
end

-- Function called during a menu button press, which clears the menu and set the appropriate flags and values for automatic spell casting
local function onMagicSelect(selectedOption)
    clearMenu()

    -- Identify which magic school has been selected
    selectedMagic = optionValues[selectedOption]

    tes3.messageBox("Training " .. selectedOption  .. "... Press F12 to stop training.")

    -- Once a magic school is selected, find all character spells under this school, and choose cheapest cost spell

    -- Get the player's mobile object
    local playerObject = tes3.player.object

    -- Ensure the player exists and has spells
    if not playerObject or not playerObject.spells then
        tes3.messageBox("Player has no spells. Deactivating training script.")
        toggleTraining = false
        spellSelected = false
        selectedMagic = tes3.magicSchool.none;
    end

    local lowestCost = math.huge
    cheapestSpell = nil

    for spell in tes3.iterate(playerObject.spells.iterator) do
        if spell.castType == tes3.spellType.spell then -- Only consider standard spells (ignore powers, abilities, and diseases)
            for _, effect in ipairs(spell.effects) do -- Check each effect of the spell in order to identify the magic school it belongs in
                if effect and effect.id ~= -1 and effect.object.school == selectedMagic then -- Ensure the effect is valid and matches the desired school
                    local cost = spell.magickaCost -- Obtain spell cost 
                    if cost < lowestCost then
                        cheapestSpell = spell
                        lowestCost = cost
                    end
                    break -- Stop checking effects if one matches the selected magic school, and move onto next spell
                end
            end
        end
    end

    if(cheapestSpell == nil) then -- If the cheapest spell could not be found, there are no spells under the selected magic school
        tes3.messageBox("No spell found under the " .. selectedOption .. " school. Deactivating training script.")
        toggleTraining = false
        spellSelected = false
        selectedMagic = tes3.magicSchool.none;
    else
        tes3.messageBox("Casting spell: %s",  cheapestSpell.name)
        spellSelected = true -- Set flag to true in order to start automated spell casting
    end
end

-- Function to create the custom menu
local function createCustomMenu()
    -- Check if the menu is already open; if so, close it
    if tes3ui.findMenu(menuId) then
        tes3ui.findMenu(menuId):destroy()
    end

    -- Create the menu and set its properties
    local menu = tes3ui.createMenu({ id = menuId, fixedFrame = true })

    -- Create a block for centering content
    local centeredBlock = menu:createBlock()
    centeredBlock.flowDirection = "top_to_bottom" 
    centeredBlock.autoWidth = true
    centeredBlock.autoHeight = true
    centeredBlock.childAlignX = 0.5 
    centeredBlock.childAlignY = 0.5 

    -- Create labels for the menu
    local labelTitle = centeredBlock:createLabel({ text = "Welcome to the Spell Training Tool" })
    labelTitle.borderBottom = 10
    
    local label = centeredBlock:createLabel({ text = "Select a Magic School:" })
    label.borderBottom = 10

    -- Create a block for the buttons
    local buttonBlock = centeredBlock:createBlock({ id = buttonBlockId })
    buttonBlock.flowDirection = "top_to_bottom"
    buttonBlock.autoWidth = true
    buttonBlock.autoHeight = true
    buttonBlock.paddingAllSides = 4
    buttonBlock.childAlignX = 0.5
    buttonBlock.childAlignY = 0.5

    -- Create buttons for each magic school option
    for _, option in ipairs(options) do
        local button = buttonBlock:createTextSelect({ text = option })
        button.borderBottom = 5
        button:register("mouseClick", function()
            onMagicSelect(option) -- Call this function when a button is clicked
        end)
    end

    -- Create exit button
    local exitButton = buttonBlock:createButton({ text = "Exit" })

    -- Exit back to game when clicking this button
    exitButton:register("mouseClick", function()
        clearMenu()
        tes3.messageBox("Deactivating training script.")
        toggleTraining = false
        spellSelected = false
        selectedMagic = tes3.magicSchool.none;
    end)

    -- Activate the menu mode to make the menu interactive
    tes3ui.enterMenuMode(menuId)
end

-- Function used to cast spell, specific to the magic school selected
local function castSpell()
    -- Equip spell, and activate it endlessly until magicka runs out

    local player = tes3.player

    local spellCost = cheapestSpell.magickaCost

    local totalMagicka = tes3.mobilePlayer.magicka.current

    -- Check if player has enough magicka before casting spell
    if(totalMagicka >= spellCost) then
        if cheapestSpell then
            -- Cast the cheapest spell
            tes3.cast({
                reference = player,    
                target = tes3.getPlayerTarget(),
                spell = cheapestSpell,
                alwaysSucceeds = false
            })
        end
    else
        tes3.messageBox("Not enough magicka to cast current spell. Please restore your magicka.")
        tes3.messageBox("Deactivating training script.")
        toggleTraining = false
        spellSelected = false
        selectedMagic = tes3.magicSchool.none;
        tes3.mobilePlayer.actionData.animationAttackState = tes3.animationState.idle -- stop spell casting animation and return to idle
    end
end

-- Handles loop for repeated spell casting
local function onEveryFrame(e)
    if spellSelected then
        castSpell()
    end
end

-- Function which checks if player's magicka is empty, before starting the spell casting automation
local function checkIfMagickaEmpty()
    local totalMagicka = tes3.mobilePlayer.magicka.current
    if totalMagicka == 0 then
        tes3.messageBox("Player's magicka level at zero. Please restore your magicka.")
        return false
    else
        return true
    end
end

-- Function to check if the pressed key is F12, and to check if game is loaded, in order to activate the automation
local function onKeyPress(e)
    if e.keyCode == 88 and gameLoaded then

        if (checkIfMagickaEmpty()) then
            if toggleTraining then
                toggleTraining = false -- Disable spell casting automation
                spellSelected = false
                selectedMagic = tes3.magicSchool.none;
                tes3.messageBox("Deactivating training script.")

            else
                toggleTraining = true -- Enable spell casting automation
                tes3.messageBox("Activating training script.")
                createCustomMenu()
            end
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