local BAD_PATTERNS = {
    "loadstring",
    "assert%s*%(%s*load",
    "pcall%s*%(%s*load",
    "load%s*%(",
    "load",

    "PerformHttpRequest",
    "RegisterNetEvent",
    "TriggerServerEvent",
    "TriggerEvent",

    "rawget%s*%(%s*_G",
    "rawset%s*%(%s*_G",

    "string%.char",
    "\\x%x%x",
    "\\%d%d%d",

    "Citizen%.CreateThread%s*%(%s*function",
}


-- =============================
-- DOSYA TARAMA (STATIK)
-- =============================
local function scanResource(resource)
    local resPath = GetResourcePath(resource)
    if not resPath then return end

    for _, file in ipairs(GetResourceMetadata(resource, "server_script") or {}) do
        local content = LoadResourceFile(resource, file)
        if content then
            local lower = content:lower()
            for _, pattern in ipairs(BAD_PATTERNS) do
                if lower:find(pattern) then
                    print(("^1[BACKDOOR?]^7 %s -> %s (pattern: %s)")
                        :format(resource, file, pattern))
                end
            end
        end
    end
end

-- =============================
-- RUNTIME PRINT DİNLEYİCİ
-- =============================
AddEventHandler('__cfx_internal:serverPrint', function(msg)
    if type(msg) ~= "string" then return end

    local lower = msg:lower()
    for _, pattern in ipairs(BAD_PATTERNS) do
        if lower:find(pattern) then
            print("^3[RUNTIME ŞÜPHELİ]^7", msg)
            break
        end
    end
end)

-- =============================
-- SERVER AÇILIŞ TARAMASI
-- =============================
CreateThread(function()
    Wait(3000)
    print("^3[BackdoorDetector]^7 Static scan started")

    for i = 0, GetNumResources() - 1 do
        local res = GetResourceByFindIndex(i)
        scanResource(res)
    end

    print("^2[BackdoorDetector]^7 Static scan completed")
end)
