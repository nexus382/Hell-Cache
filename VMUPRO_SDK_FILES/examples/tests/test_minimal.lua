-- Test Minimal - Basic VMU Pro App Structure Test
-- This test verifies the most basic app functionality

import "api/system"
import "api/display"
import "api/input"

function AppMain()
    -- Test 1: Basic logging
    vmupro.system.log("Test Minimal: Starting")

    -- Test 2: Clear display
    vmupro.graphics.clear(vmupro.graphics.BLACK)

    -- Test 3: Draw text
    vmupro.graphics.drawText("Minimal Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

    -- Test 4: Refresh display
    vmupro.display.refresh()

    -- Test 5: Wait briefly
    vmupro.system.delayUs(1000000) -- 1 second

    vmupro.system.log("Test Minimal: Completed successfully")

    return 0
end
