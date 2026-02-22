import "api/system"

if vmupro and vmupro.system and vmupro.system.log then
    vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "wrapper app.lua loaded")
end

local ok, err = pcall(function()
    import "app_full"
end)

if vmupro and vmupro.system and vmupro.system.log then
    if ok then
        vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "import app_full ok")
    else
        vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "import app_full FAIL err=" .. tostring(err))
    end
end

if not ok then
    import "api/display"
    import "api/text"
    import "api/input"

    local bootErr = tostring(err or "unknown import failure")
    local function bootErrLine(n)
        local maxChars = 34
        local startPos = ((n - 1) * maxChars) + 1
        return string.sub(bootErr, startPos, startPos + maxChars - 1)
    end

    function AppMain()
        if vmupro and vmupro.text and vmupro.text.setFont then
            pcall(vmupro.text.setFont, vmupro.text.FONT_TINY_6x8 or vmupro.text.FONT_SMALL or 1)
        end
        while true do
            vmupro.graphics.clear(0x0000)
            vmupro.graphics.drawText("BOOT IMPORT ERROR", 6, 8, 0x00F8, 0x0000)
            vmupro.graphics.drawText("app_full failed to load", 6, 24, 0xFFFF, 0x0000)
            vmupro.graphics.drawText(bootErrLine(1), 6, 44, 0xFFFF, 0x0000)
            vmupro.graphics.drawText(bootErrLine(2), 6, 56, 0xFFFF, 0x0000)
            vmupro.graphics.drawText(bootErrLine(3), 6, 68, 0xFFFF, 0x0000)
            vmupro.graphics.drawText(bootErrLine(4), 6, 80, 0xFFFF, 0x0000)
            vmupro.graphics.drawText("Check BOOT logs for full stack.", 6, 104, 0xE007, 0x0000)
            vmupro.graphics.drawText("POWER: close app", 6, 220, 0xFFFF, 0x0000)
            vmupro.graphics.refresh()
            if vmupro.input and vmupro.input.pressed and vmupro.input.pressed(vmupro.input.POWER) then
                break
            end
            vmupro.system.delayMs(80)
        end
    end
end
