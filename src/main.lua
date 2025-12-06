package.path = package.path .. ";./?.lua"

local TaskManager = require("./task_manager")

local function determineCommand(command)
    if not command then
        print('Error: enter a valid command')
        print('Hint: use --h to find all valid commands')
        os.exit(1)
    end

    command = string.lower(command)

    if command == 'add' then
        local taskToAdd = arg[2]

        if not taskToAdd then
            print('Error: empty task')
            print('Hint: enter the task you want to add')
            os.exit(1)
        end

        TaskManager:add(taskToAdd)
    elseif command == 'delete' then
        local taskIndexToDelete = tonumber(arg[2])

        if not taskIndexToDelete then
            print('Error: empty index')
            print('Hint: add a valid index of the tasks:')
            print(TaskManager:fetch())
            os.exit(1)
        end

        TaskManager:delete(taskIndexToDelete)
    elseif command == 'complete' then
        local taskIndexToComplete = tonumber(arg[2])

        if not taskIndexToComplete then
            print('Error: empty index')
            print('Hint: add a valid index of the tasks:')
            print(TaskManager:fetch())
            os.exit(1)
        end

        TaskManager:complete(taskIndexToComplete)
    elseif command == '--h' then
        print([[
            Commands
            --------
            add (Adds task)
            delete (Deletes task)
            complete (Marks task as complete)
            --------
            
            Licensed under the Apache 2.0 License

            Copyright 2025 (ing) Studios and Ethan Lee
        ]])
        os.exit(1)
    else
        print('Error: enter a valid command')
        print('Hint: use --h to find all valid commands')
        os.exit(1)
    end

    print([[
        Tasks
        --------
    ]])
    print(table.concat(TaskManager:fetch(), '\n'))
    print([[
        --------
        
        Completed Tasks
        --------
    ]])
    print(table.concat(TaskManager:fetchCompleted(), '\n'))
    print('--------')
end

local function startProgram()
    local command = arg[1]
    
    determineCommand(command)
end

startProgram()