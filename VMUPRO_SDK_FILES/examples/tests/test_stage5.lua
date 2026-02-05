-- Test Stage 5 - Memory and System
-- Tests memory management and system utilities

import "api/system"
import "api/display"
import "api/input"

function AppMain()
    vmupro.system.log("Test Stage 5: Memory and System")

    -- Test 1: Memory monitoring
    local initialMemory = vmupro.system.getMemoryUsage()
    vmupro.system.log("Initial memory: " .. initialMemory .. " bytes")

    -- Test 2: Create various data structures
    local testArray = {}
    for i = 1, 100 do
        testArray[i] = "Test string " .. i
    end

    local afterAllocMemory = vmupro.system.getMemoryUsage()
    vmupro.system.log("After allocation: " .. afterAllocMemory .. " bytes")

    -- Test 3: Table operations
    local testTable = {
        x = 10,
        y = 20,
        width = 100,
        height = 50,
        name = "Test Object"
    }

    -- Test 4: Math operations
    local result = 0
    for i = 1, 1000 do
        result = result + math.sin(i) * math.cos(i)
    end

    -- Test 5: String operations
    local testString = ""
    for i = 1, 50 do
        testString = testString .. "Line " .. i .. "\n"
    end

    local finalMemory = vmupro.system.getMemoryUsage()
    vmupro.system.log("Final memory: " .. finalMemory .. " bytes")
    vmupro.system.log("Memory used: " .. (finalMemory - initialMemory) .. " bytes")

    -- Display test loop
    local frameCount = 0
    local maxFrames = 300

    while frameCount < maxFrames do
        local startTime = vmupro.system.getSystemTime()

        vmupro.input.read()
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Display memory info
        local currentMemory = vmupro.system.getMemoryUsage()
        local yPos = 10

        vmupro.graphics.drawText("System Test", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 20

        vmupro.graphics.drawText("Memory: " .. currentMemory, 10, yPos, vmupro.graphics.GREEN, vmupro.graphics.BLACK)
        yPos = yPos + 20

        vmupro.graphics.drawText("Initial: " .. initialMemory, 10, yPos, vmupro.graphics.CYAN, vmupro.graphics.BLACK)
        yPos = yPos + 20

        local memDiff = currentMemory - initialMemory
        local memColor = vmupro.graphics.WHITE
        if memDiff > 10000 then
            memColor = vmupro.graphics.RED
        elseif memDiff > 5000 then
            memColor = vmupro.graphics.YELLOW
        end
        vmupro.graphics.drawText("Delta: " .. memDiff, 10, yPos, memColor, vmupro.graphics.BLACK)
        yPos = yPos + 20

        -- Test: System time
        local sysTime = vmupro.system.getSystemTime()
        vmupro.graphics.drawText("Time: " .. sysTime .. "us", 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        yPos = yPos + 20

        -- Display frame count
        vmupro.graphics.drawText("Frame: " .. frameCount, 10, yPos, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Test: Log output periodically
        if frameCount % 60 == 0 then
            vmupro.system.log("Frame " .. frameCount .. " - Memory: " .. currentMemory)
        end

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

    -- Final memory check
    local cleanupMemory = vmupro.system.getMemoryUsage()
    vmupro.system.log("After cleanup: " .. cleanupMemory .. " bytes")

    vmupro.system.log("Test Stage 5: System test completed")

    return 0
end
