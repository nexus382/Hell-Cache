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
