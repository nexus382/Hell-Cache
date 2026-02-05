-- Test Stage 2 - Input Handling
-- Tests button input and state management

import "api/system"
import "api/display"
import "api/input"

function AppMain()
    vmupro.system.log("Test Stage 2: Input Handling")

    local frameCount = 0
    local maxFrames = 300 -- 5 seconds at 60 FPS

    -- Test loop
    while frameCount < maxFrames do
        local startTime = vmupro.system.getSystemTime()

        -- Clear display
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Read input (once per frame)
        vmupro.input.read()

        -- Test button states
        local up = vmupro.input.isButtonDown(vmupro.input.BUTTON_UP)
        local down = vmupro.input.isButtonDown(vmupro.input.BUTTON_DOWN)
        local left = vmupro.input.isButtonDown(vmupro.input.BUTTON_LEFT)
        local right = vmupro.input.isButtonDown(vmupro.input.BUTTON_RIGHT)
        local a = vmupro.input.isButtonDown(vmupro.input.BUTTON_A)
        local b = vmupro.input.isButtonDown(vmupro.input.BUTTON_B)
        local start = vmupro.input.isButtonDown(vmupro.input.BUTTON_START)
        local select = vmupro.input.isButtonDown(vmupro.input.BUTTON_SELECT)

        -- Draw button states
        vmupro.graphics.drawText("Input Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        local yPos = 40
        local color = vmupro.graphics.GREEN

        vmupro.graphics.drawText("UP: " .. tostring(up), 10, yPos, up and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("DOWN: " .. tostring(down), 10, yPos, down and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("LEFT: " .. tostring(left), 10, yPos, left and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("RIGHT: " .. tostring(right), 10, yPos, right and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("A: " .. tostring(a), 10, yPos, a and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("B: " .. tostring(b), 10, yPos, b and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("START: " .. tostring(start), 10, yPos, start and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)
        yPos = yPos + 20
        vmupro.graphics.drawText("SELECT: " .. tostring(select), 10, yPos, select and vmupro.graphics.GREEN or vmupro.graphics.GRAY, vmupro.graphics.BLACK)

        -- Display frame count
        yPos = yPos + 30
        vmupro.graphics.drawText("Frame: " .. frameCount, 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Refresh display
        vmupro.display.refresh()

        -- Frame timing
        local processingTime = vmupro.system.getSystemTime() - startTime
        local targetTime = 16667 -- ~60 FPS
        local delayTime = targetTime - processingTime

        if delayTime > 0 then
            vmupro.system.delayUs(delayTime)
        end

        frameCount = frameCount + 1
    end

    vmupro.system.log("Test Stage 2: Input test completed")

    return 0
end
