-- Test Stage 6 - Tamagotchi Integration
-- Tests all systems together in a simple game loop

import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "api/audio"

-- Game state
local gameState = {
    petX = 120,
    petY = 120,
    hunger = 50,
    happiness = 50,
    energy = 100,
    frameCount = 0,
    lastUpdate = 0
}

function AppMain()
    vmupro.system.log("Test Stage 6: Tamagotchi Integration")

    -- Try to load resources
    local petSprite = vmupro.sprite.new("pet")
    local foodSound = vmupro.sound.sample.new("eat")

    if petSprite == nil then
        vmupro.system.log("Using fallback graphics")
    end
    if foodSound == nil then
        vmupro.system.log("Using fallback audio")
    end

    -- Main game loop
    local running = true
    local maxFrames = 900 -- 15 seconds

    while running and gameState.frameCount < maxFrames do
        local startTime = vmupro.system.getSystemTime()

        -- Read input
        vmupro.input.read()

        -- Clear display
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Update game state
        gameState.frameCount = gameState.frameCount + 1

        -- Decrease stats over time
        if gameState.frameCount % 60 == 0 then
            gameState.hunger = math.max(0, gameState.hunger - 1)
            gameState.happiness = math.max(0, gameState.happiness - 1)
            gameState.energy = math.max(0, gameState.energy - 0.5)
        end

        -- Input handling
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_UP) then
            gameState.petY = math.max(0, gameState.petY - 2)
        end
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_DOWN) then
            gameState.petY = math.min(220, gameState.petY + 2)
        end
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_LEFT) then
            gameState.petX = math.max(0, gameState.petX - 2)
        end
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_RIGHT) then
            gameState.petX = math.min(220, gameState.petX + 2)
        end

        -- Feed pet (A button)
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_A) then
            gameState.hunger = math.min(100, gameState.hunger + 5)
            if foodSound ~= nil then
                vmupro.audio.play(foodSound)
            end
        end

        -- Play with pet (B button)
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_B) then
            gameState.happiness = math.min(100, gameState.happiness + 5)
        end

        -- Rest pet (Start button)
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_START) then
            gameState.energy = math.min(100, gameState.energy + 2)
        end

        -- Draw pet
        if petSprite ~= nil then
            vmupro.sprite.setPosition(petSprite, gameState.petX, gameState.petY)
            vmupro.sprite.render(petSprite)
        else
            -- Fallback: Draw a simple pet
            vmupro.graphics.drawCircle(gameState.petX + 10, gameState.petY + 10, 10, vmupro.graphics.YELLOW, true)
            vmupro.graphics.drawPixel(gameState.petX + 7, gameState.petY + 7, vmupro.graphics.BLACK)
            vmupro.graphics.drawPixel(gameState.petX + 13, gameState.petY + 7, vmupro.graphics.BLACK)
        end

        -- Draw UI
        local yPos = 10

        -- Title
        vmupro.graphics.drawText("Tamagotchi Test", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 25

        -- Stats
        local barWidth = 50

        -- Hunger bar
        vmupro.graphics.drawText("Hunger", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawRect(60, yPos, barWidth, 10, vmupro.graphics.WHITE, false)
        if gameState.hunger > 0 then
            local hungerWidth = (gameState.hunger / 100) * barWidth
            local hungerColor = vmupro.graphics.GREEN
            if gameState.hunger < 30 then
                hungerColor = vmupro.graphics.RED
            elseif gameState.hunger < 60 then
                hungerColor = vmupro.graphics.YELLOW
            end
            vmupro.graphics.drawRect(60, yPos, hungerWidth, 10, hungerColor, true)
        end
        yPos = yPos + 20

        -- Happiness bar
        vmupro.graphics.drawText("Happy ", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawRect(60, yPos, barWidth, 10, vmupro.graphics.WHITE, false)
        if gameState.happiness > 0 then
            local happyWidth = (gameState.happiness / 100) * barWidth
            local happyColor = vmupro.graphics.CYAN
            if gameState.happiness < 30 then
                happyColor = vmupro.graphics.RED
            elseif gameState.happiness < 60 then
                happyColor = vmupro.graphics.YELLOW
            end
            vmupro.graphics.drawRect(60, yPos, happyWidth, 10, happyColor, true)
        end
        yPos = yPos + 20

        -- Energy bar
        vmupro.graphics.drawText("Energy", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawRect(60, yPos, barWidth, 10, vmupro.graphics.WHITE, false)
        if gameState.energy > 0 then
            local energyWidth = (gameState.energy / 100) * barWidth
            local energyColor = vmupro.graphics.MAGENTA
            if gameState.energy < 30 then
                energyColor = vmupro.graphics.RED
            elseif gameState.energy < 60 then
                energyColor = vmupro.graphics.YELLOW
            end
            vmupro.graphics.drawRect(60, yPos, energyWidth, 10, energyColor, true)
        end

        -- Draw controls
        yPos = 180
        vmupro.graphics.drawText("Controls:", 10, yPos, vmupro.graphics.CYAN, vmupro.graphics.BLACK)
        yPos = yPos + 15
        vmupro.graphics.drawText("DPad - Move", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 15
        vmupro.graphics.drawText("A - Feed", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 15
        vmupro.graphics.drawText("B - Play", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 15
        vmupro.graphics.drawText("Start - Rest", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Update audio
        vmupro.sound.update()

        -- Refresh display
        vmupro.display.refresh()

        -- Frame timing
        local processingTime = vmupro.system.getSystemTime() - startTime
        local targetTime = 16667
        local delayTime = targetTime - processingTime

        if delayTime > 0 then
            vmupro.system.delayUs(delayTime)
        end
    end

    -- Cleanup
    vmupro.sprite.removeAll()
    if foodSound ~= nil then
        vmupro.audio.stop(foodSound)
    end

    vmupro.system.log("Test Stage 6: Integration test completed")
    vmupro.system.log("Final stats - Hunger: " .. gameState.hunger .. ", Happiness: " .. gameState.happiness .. ", Energy: " .. gameState.energy)

    return 0
end
