local FileSystem = {}

local function normalizePath(path)
    return path:gsub('\\', '/')
end

function FileSystem:ensureDirectoryExists(directoryPath)
    local path = normalizePath(directoryPath)
    
    local cmd
    local osName = string.lower(os.getenv('OS') or '')
    
    if osName:match('windows') then
        local winPath = path:gsub('/', '\\')
        cmd = 'if not exist "' .. winPath .. '" mkdir "' .. winPath .. '"'
    else
        cmd = "mkdir -p '" .. path .. "'"
    end

    local success = os.execute(cmd)

    if success == true or success == 0 then
        return true
    else
        print("Error: failed to create directory '" .. directoryPath .. "'")
        return false
    end
end

return FileSystem