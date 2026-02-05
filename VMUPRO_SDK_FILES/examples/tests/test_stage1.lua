-- Test Stage 1 - Display and Graphics
-- Tests basic display functionality and drawing primitives

import "api/system"
import "api/display"

function AppMain()
    vmupro.system.log("Test Stage 1: Display and Graphics")

    -- Test 1: Clear with different colors
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.display.refresh()
    vmupro.system.delayUs(500000)

    vmupro.graphics.clear(vmupro.graphics.WHITE)
    vmupro.display.refresh()
    vmupro.system.delayUs(500000)

    -- Test 2: Draw text at various positions
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Stage 1 Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Line 2", 10, 30, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Line 3", 10, 50, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    vmupro.display.refresh()
    vmupro.system.delayUs(2000000)

    -- Test 3: Draw pixels
    for i = 0, 100 do
        vmupro.graphics.drawPixel(i, 100, vmupro.graphics.RED)
    end
    vmupro.display.refresh()
    vmupro.system.delayUs(1000000)

    -- Test 4: Draw lines
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawLine(0, 0, 239, 239, vmupro.graphics.GREEN)
    vmupro.graphics.drawLine(239, 0, 0, 239, vmupro.graphics.BLUE)
    vmupro.display.refresh()
    vmupro.system.delayUs(2000000)

    -- Test 5: Draw rectangles
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawRect(10, 10, 100, 80, vmupro.graphics.WHITE, false)
    vmupro.graphics.drawRect(130, 10, 100, 80, vmupro.graphics.WHITE, true)
    vmupro.display.refresh()
    vmupro.system.delayUs(2000000)

    -- Test 6: Draw circles
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawCircle(120, 120, 50, vmupro.graphics.YELLOW, false)
    vmupro.graphics.drawCircle(120, 120, 30, vmupro.graphics.CYAN, true)
    vmupro.display.refresh()
    vmupro.system.delayUs(2000000)

    vmupro.system.log("Test Stage 1: All display tests passed")

    return 0
end
