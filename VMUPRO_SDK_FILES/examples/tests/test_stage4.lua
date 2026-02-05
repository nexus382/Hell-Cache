-- Test Stage 4 - Audio System
-- Tests sound playback and audio control

import "api/system"
import "api/display"
import "api/input"
import "api/audio"

function AppMain()
    vmupro.system.log("Test Stage 4: Audio System")

    -- Try to load a test sound
    local soundLoaded = false
    local testSound = nil

    -- Try to load sound (will fail if asset doesn't exist)
    testSound = vmupro.sound.sample.new("test_sound")
    if testSound ~= nil then
        soundLoaded = true
        vmupro.system.log("Sound loaded successfully")
    else
        vmupro.system.log("No sound file - testing audio system only")
    end

    local frameCount = 0
    local maxFrames = 300
    local soundPlayed = false

    -- Test loop
    while frameCount < maxFrames do
        local startTime = vmupro.system.getSystemTime()

        -- Read input
        vmupro.input.read()

        -- Clear display
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Draw status
        vmupro.graphics.drawText("Audio Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Sound Loaded: " .. tostring(soundLoaded), 10, 30, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Frame: " .. frameCount, 10, 50, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Test: Play sound on A button press
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_A) then
            if soundLoaded and testSound ~= nil and not soundPlayed then
                vmupro.audio.play(testSound)
                soundPlayed = true
                vmupro.system.log("Playing sound")
            end
        else
            soundPlayed = false
        end

        -- Test: Stop sound on B button press
        if vmupro.input.isButtonDown(vmupro.input.BUTTON_B) then
            if soundLoaded and testSound ~= nil then
                vmupro.audio.stop(testSound)
                vmupro.system.log("Stopping sound")
            end
        end

        -- Draw instructions
        local yPos = 80
        vmupro.graphics.drawText("Controls:", 10, yPos, vmupro.graphics.CYAN, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("A - Play Sound", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("B - Stop Sound", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Update audio system
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

        frameCount = frameCount + 1
    end

    -- Cleanup
    if testSound ~= nil then
        vmupro.audio.stop(testSound)
    end

    vmupro.system.log("Test Stage 4: Audio test completed")

    return 0
end
