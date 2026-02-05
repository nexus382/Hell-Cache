-- Test Stage 3 - Sprite System
-- Tests sprite loading, positioning, and rendering

import "api/system"
import "api/display"
import "api/input"
import "api/sprites"

function AppMain()
    vmupro.system.log("Test Stage 3: Sprite System")

    -- Create a simple test sprite colored rectangle (if no sprite file available)
    local spriteLoaded = false
    local testSprite = nil

    -- Try to load a sprite (will fail if asset doesn't exist, which is ok for testing)
    testSprite = vmupro.sprite.new("test_sprite")
    if testSprite ~= nil then
        spriteLoaded = true
        vmupro.system.log("Sprite loaded successfully")
    else
        vmupro.system.log("No sprite file - drawing test pattern instead")
    end

    local frameCount = 0
    local maxFrames = 300
    local x = 10
    local y = 10
    local dx = 2
    local dy = 2

    -- Test loop
    while frameCount < maxFrames do
        local startTime = vmupro.system.getSystemTime()

        -- Read input
        vmupro.input.read()

        -- Clear display
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Update position
        x = x + dx
        y = y + dy

        -- Bounce off walls
        if x <= 0 or x >= 220 then
            dx = -dx
        end
        if y <= 0 or y >= 220 then
            dy = -dy
        end

        -- Test: Draw sprite or rectangle
        if spriteLoaded and testSprite ~= nil then
            vmupro.sprite.setPosition(testSprite, x, y)
            vmupro.sprite.render(testSprite)
        else
            -- Draw a test rectangle instead
            vmupro.graphics.drawRect(x, y, 20, 20, vmupro.graphics.RED, true)
        end

        -- Draw info
        vmupro.graphics.drawText("Sprite Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Pos: " .. x .. "," .. y, 10, 30, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Frame: " .. frameCount, 10, 50, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Test: Button controls
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_UP) then
            y = y - 2
        end
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_DOWN) then
            y = y + 2
        end
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_LEFT) then
            x = x - 2
        end
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_RIGHT) then
            x = x + 2
        end

        -- Refresh display
        vmupro.display.refresh()

        -- Frame timing
        local processingTime = vmupro.system.getSystemTime() - startTime
        local targetTime = 16667
        local delayTime = targetTime - processingTime

        if delayTime > 0 then
            vmupro.system.delayUs(delayTime)
        end

        frameCount = frameCount + 1
    end

    -- Cleanup sprites
    vmupro.sprite.removeAll()

    vmupro.system.log("Test Stage 3: Sprite test completed")

    return 0
end
