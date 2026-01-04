-- ================================
-- FiveM Anti Backdoor Scanner
-- False-positive safe version
-- ================================

-- 🔒 Trusted resources (DO NOT scan)
local WHITELISTED_RESOURCES = {
    chat = true,
    spawnmanager = true,
    sessionmanager = true,
    hardcap = true,
    baseevents = true
}

-- 🚨 REAL backdoor indicators ONLY
local SUSPICIOUS_PATTERNS = {
    "assert%s*%(%s*load",
    "loadstring%s*%(",
    "load%s*%(",
    "pcall%s*%(%s*load",
    "PerformHttpRequest%s*%(.+function",
    "RunString",
    "raw%.githubusercontent%.com",
    "pastebin%.com",
    "discord%.com/api/webhooks",
    "TriggerClientEvent%s*%(.+%-1"
}

local function scanFile(resource, file)
    local path = GetResourcePath(resource) .. "/" .. file
    local f = io.open(path, "r")
    if not f then return end

    local lineNumber = 0

    for line in f:lines() do
        lineNumber = lineNumber + 1
        local lowerLine = line:lower()

        for _, pattern in ipairs(SUSPICIOUS_PATTERNS) do
            if lowerLine:find(pattern:lower()) then
                print("^1[ANTI-BACKDOOR]^7 Suspicious code detected!")
                print("^3Resource:^7 " .. resource)
                print("^3File:^7 " .. file .. " (Line " .. lineNumber .. ")")
                print("^3Pattern:^7 " .. pattern)
                print("^3Code:^7 " .. line)
                print("^1---------------------------------------^7")
            end
        end
    end

    f:close()
end

local function scanResource(resource)
    -- Skip trusted resources
    if WHITELISTED_RESOURCES[resource] then
        return
    end

    local resourcePath = GetResourcePath(resource)
    if not resourcePath then return end

    -- Only scan SERVER files (backdoors live here)
    local handle = io.popen('dir "' .. resourcePath .. '" /b')
    if not handle then return end

    for file in handle:lines() do
        if file:match("^sv_.*%.lua$") or file:match("server%.lua$") then
            scanFile(resource, file)
        end
    end

    handle:close()
end

CreateThread(function()
    Wait(5000)

    print("^2[ANTI-BACKDOOR]^7 Starting server resource scan...")

    for i = 0, GetNumResources() - 1 do
        local resource = GetResourceByFindIndex(i)
        scanResource(resource)
    end

    print("^2[ANTI-BACKDOOR]^7 Scan completed.")
end)
