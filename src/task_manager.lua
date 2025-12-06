local TaskManager = {}

local FileSystem = require('fs_utils')

local function getOSName()
    local windir = os.getenv("windir")
    if windir then
        return "Windows"
    end
    
    local f = io.popen("uname -s 2>/dev/null", "r")
    if f then
        local result = f:read("*a")
        f:close()
        if result then
            result = result:lower():gsub("%s+", "")
            if result:find("linux") then
                return "Linux"
            elseif result:find("darwin") then
                return "Darwin"
            end
        end
    end

    return "Unknown"
end

local function getFilepath()
    local operatingSystemName = getOSName()
    local base = nil

    if operatingSystemName == 'Windows' then -- Windows
        local win_base = os.getenv('LOCALAPPDATA')
        if not win_base then
            print('Error: localappdata directory not found')
            os.exit(1)
        end
        base = string.gsub(win_base, '\\', '/')
    elseif operatingSystemName == 'Darwin' then -- macOS
        base = '/Library/Application Support'
    else -- Linux and others
        base = os.getenv('XDG_DATA_HOME') or (os.getenv('HOME') .. '/.local/share')
    end

    return base .. '/ingStudios/Lua Task Manager'
end

function TaskManager:fetch()
    local directory = getFilepath()
    local filepath = directory .. '/tasks.txt'

    if not FileSystem:ensureDirectoryExists(directory) then os.exit(1) end

    local file = io.open(filepath, 'r')

    if not file then
        print('File not found, creating...')

        local newFile, err = io.open(filepath, 'w')

        if newFile then
            newFile:write('{}')
            newFile:close()
        else
            print('Error: failed to create file:', err)
            os.exit(1)
        end

        return {}
    else
        local contents = file:read('*a')
        file:close()

        local tasks = {}

        for task in string.gmatch(contents, '([^,]+)') do
            table.insert(tasks, task)
        end

        return tasks
    end
end

function TaskManager:fetchCompleted()
    local directory = getFilepath()
    local filepath = directory .. '/completed.txt'

    if not FileSystem:ensureDirectoryExists(directory) then
        print("Error: failed to create directory '" .. directory .. "'")
        os.exit(1)
    end

    local file = io.open(filepath, 'r')

    if not file then
        local newFile, err = io.open(filepath, 'w')

        if newFile then
            newFile:write('{}')
            newFile:close()
        else
            print('Error: failed to create file:', err)
            os.exit(1)
        end

        return {}
    else
        local contents = file:read('*a')
        file:close()

        local tasks = {}

        for task in string.gmatch(contents, '([^,]+)') do
            table.insert(tasks, task)
        end

        return tasks
    end
end

function TaskManager:save(tasks)
    local filepath = getFilepath() .. '/tasks.txt'

    local file, err = io.open(filepath, 'w')

    if file then
        file:write(table.concat(tasks, ','))
        file:close()
    else
        print('Error: failed to save file:', err)
        os.exit(1)
    end
end

function TaskManager:saveCompleted(tasks)
    local filepath = getFilepath() .. '/completed.txt'

    local file, err = io.open(filepath, 'w')

    if file then
        file:write(table.concat(tasks, ','))
        file:close()
    else
        print('Error: failed to save file:', err)
        os.exit(1)
    end
end

function TaskManager:add(task)
    local tasks = TaskManager:fetch()

    table.insert(tasks, 1, task)

    TaskManager:save(tasks)

    print("Success: added task '" .. task .. "'")
end

function TaskManager:delete(index)
    if type(index) ~= 'number' then
        print('Error: ' .. index .. ' is not a valid number')
        os.exit(1)
    end

    local tasks = TaskManager:fetch()
    local tasksLength = #tasks

    if index > tasksLength then
        print('Error: index ' .. index .. ' is out of range')
        os.exit(1)
    end

    local task = tasks[index]

    table.remove(tasks, index)

    TaskManager:save(tasks)

    print("Success: removed task '" .. task .. "'")
end

function TaskManager:complete(index)
    if type(index) ~= 'number' then
        print('Error: ' .. index .. ' is not a valid number')
        os.exit(1)
    end

    local tasks = TaskManager:fetch()
    local tasksLength = #tasks

    if index > tasksLength then
        print('Error: index ' .. index .. ' is out of range')
        os.exit(1)
    end

    local task = tasks[index]

    table.remove(tasks, index)

    TaskManager:save(tasks)

    local completed = TaskManager:fetchCompleted()

    table.insert(completed, 1, task)

    TaskManager:saveCompleted(completed)

    print("Success: marked task '" .. task .. "' as complete")
end

return TaskManager