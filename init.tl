-- vim: set colorcolumn=85
-- vim: fdm=marker

print('hello. I scene from separated thread')
require "love"
require "love_inc".require_pls_nographic()
love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/messenger/?.lua")

local Pipeline = require 'pipeline'
local pipeline = Pipeline.new()
local event_channel = love.thread.getChannel("event_channel")
local colorize = require 'ansicolors2'.ansicolors
local mx, my = 0, 0
local last_render: number
local inspect = require 'inspect'
local thread: love.thread.Thread
-- Потоко-безопасная очередь
local msg = require 'messenger2'

local record Test
    func: function()
    desc: string
end
local tests: {Test} = {}

-- 1
table.insert(tests, {
    desc = [[Создание канала. 
Только числовые данные.
Получение данных со стороны создающего канал потока.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL";
        local channel = msg.new(channel_name);

        for i = 9, 1, -1 do
            msg.push(channel, i)
            print("pushed", i)
        end

        msg.print(channel)

        local value: any
        repeat
            value = msg.pop(channel)
            print('popped value', value)
        until not value
        -- }}}
    end
})

-- 2
table.insert(tests, {
    desc = [[Создание канала. 
Только строковые данные.
Получение данных со стороны создающего канал потока.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL";
        local channel = msg.new(channel_name);

        for i = 9, 1, -1 do
            local mess = randomFilenameStr(math.random(1, 5));
            msg.push(channel, "hello_" .. mess .. "_" .. tostring(i))
        end

        msg.print(channel)

        local value: any
        repeat
            value = msg.pop(channel)
            print('popped value', value)
        until not value
        -- }}}
    end
})

-- 3
table.insert(tests, {
    desc = [[Создание канала. 
Только строковые данные.
Получение данных со стороны создающего канал потока.
Заталкивание строки больше разрешенной длины.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL";
        local channel = msg.new(channel_name);

        for i = 9, 1, -1 do
            local mess = randomFilenameStr(math.random(1, 5));
            msg.push(channel, "hello_" .. mess .. "_" .. tostring(i))
        end

        local mess = randomFilenameStr(math.random(64, 128));
        msg.push(channel, "hello_" .. mess)

        msg.print(channel)

        local value: any
        repeat
            value = msg.pop(channel)
            print('popped value', value)
        until not value
        -- }}}
    end
})

-- 4
table.insert(tests, {
    desc = [[Создание каналов. 
Только числовые данные.
Получение данных со стороны другого потока.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);
        for i = 9, 1, -1 do
            msg.push(channel, i)
        end

        thread = love.thread.newThread("scenes/messenger/thread.lua")
        thread:start(channel_name, state, 'full_pop')
        print('thread started')

        for _ = 9, 1, -1 do
            msg.push(channel, 0)
        end

        msg.print(channel)
        print('-----------------------------------')
        love.timer.sleep(0.1)
        msg.print(channel)
        print('-----------------------------------')

        -- }}}
    end
})

-- 5
table.insert(tests, {
    desc = [[Создание каналов. 
Числовые и строковые данные. 
Превышение лимита заполнения очереди.
]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);

        for i = 1, msg.QUEUE_SIZE * 2 do
            if math.random() > 0.5 then
                msg.push(channel, i)
            else
                msg.push(channel, "str_" .. tostring(i))
            end
        end

        thread = love.thread.newThread("scenes/messenger/thread.lua")
        thread:start(channel_name, state, 'full_pop')
        print('thread started')

        -- }}}
    end
})

-- 6
table.insert(tests, {
    desc = [[Создание каналов. 
Смешанные данные - числа и строки. 
Получение значений со стороны создающего потока.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);

        for i = 1, 1000 do
            local value: any
            if math.random() > 0.5 then
                value = tonumber(i)
            else
                value = "str" .. tostring(i)
            end
            msg.push(channel, value)
            print('pushed', value)
        end

        local value: any
        repeat
            value = msg.pop(channel)
            print('popped value', value)
        until not value
        -- }}}
    end
})

-- 7
table.insert(tests, {
    desc = [[Создание каналов. 
Смешанные данные - числа и строки. Вставка и удаление в разном порядке.
Получение значений со стороны создающего потока.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);

        for i = 1, 1000 do
            local num = math.random(1, 10)
            for j = 1, num do
                local value: any
                if math.random() > 0.5 then
                    value = tonumber(i)
                else
                    value = "str" .. tostring(i)
                end
                msg.push(channel, value)
                print('pushed', value)
            end
            for j = 1, num do
                print(msg.pop(channel))
            end
        end

        print('----------------------------------')
        msg.print(channel)
        print('----------------------------------')
        -- }}}
    end
})

-- 8
table.insert(tests, {
    desc = [[Создание каналов. 
Смешанные данные - числа и строки. Вставка и удаление в разном порядке.
Получение значений со стороны создающего потока.]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);

        for i = 1, 1000 do
            local num = math.random(1, 10)
            for j = 1, num do
                local value: any
                if math.random() > 0.5 then
                    value = tonumber(i)
                else
                    value = "str" .. tostring(i)
                end
                msg.push(channel, value)
                print('pushed', value)
            end
            for j = 1, num do
                print(msg.pop(channel))
            end
        end

        print(colorize('%{blue}Тут должен быть пустой вывод, очереди пусты:'))
        print(colorize('%{blue}----------------------------------'))
        msg.print(channel)
        print(colorize('%{blue}----------------------------------'))
        -- }}}
    end
})

-- 9
table.insert(tests, {
    desc = [[Создание каналов. 
Смешанные данные - числа и строки. 
Получение значений со стороны создающего потока.
Методы clear(), get_count()
]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);

        local function fill()
            for i = 1, 10 do
                local value: any
                if math.random() > 0.5 then
                    value = tonumber(i)
                else
                    value = "str" .. tostring(i)
                end
                msg.push(channel, value)
                print('pushed', value)
            end
        end

        fill()

        print(colorize('%{blue}----------------------------------'))
        msg.print(channel)
        print(colorize('%{blue}----------------------------------'))

        print("msg.get_count(channel)", msg.get_count(channel))
        print('msg.clear(channel)')
        msg.clear(channel)
        print("msg.get_count(channel)", msg.get_count(channel))

        fill()

        print("msg.get_count(channel)", msg.get_count(channel))
        print('msg.clear(channel)')
        msg.clear(channel)
        print("msg.get_count(channel)", msg.get_count(channel))

        print(colorize('%{blue}Тут должен быть пустой вывод, очереди пусты:'))
        print(colorize('%{blue}----------------------------------'))
        msg.print(channel)
        print(colorize('%{blue}----------------------------------'))
        -- }}}
    end
})

-- 10
table.insert(tests, {
    desc = [[Создание каналов. 
Смешанные данные - числа и строки. 
Получение значений со стороны другого потока через метод channel:demand()
]],
    func = function()
        -- {{{

        local state = msg.init_messenger()
        print('state', state)

        local channel_name = "KANAL_331";
        local channel = msg.new(channel_name);

        local count = 10

        local function fill()
            for i = 1, count do
                local value: any
                if math.random() > 0.5 then
                    value = tonumber(i)
                else
                    value = "str" .. tostring(i)
                end
                msg.push(channel, value)
                print('pushed', value)
            end
        end

        msg.push(channel, count * 2);
        fill()

        thread = love.thread.newThread("scenes/messenger/thread.lua")
        thread:start(channel_name, state, 'demand_by_count')
        print('thread started')

        local qwerty = love.thread.getChannel('qwerty')
        qwerty:push(1)
        qwerty:push(2)
        qwerty:push(3)
        qwerty:push(4)

        fill()

        local i = 0
        repeat
            i = i + 1
            if thread:getError() then
                local errmsg = thread:getError()
                print('thread:getError()', colorize("%{red}" .. errmsg))
                break
            end
            --print('i', i)
            --if i > 5000 then
                --break
            --end
        until not thread:isRunning()

        print(colorize('%{blue}----------------------------------'))
        msg.print(channel)
        print(colorize('%{blue}----------------------------------'))
        -- }}}
    end
})

local function callt(index: integer)
    print('Вызов:', colorize("%{yellow}" .. tests[index].desc))
    tests[index].func()
end

local function init()
    -- {{{ render stuff
    pipeline:pushCode('print_fps', [[
    local getFPS = love.timer.getFPS
    while true do
        local msg = string.format('fps %d', getFPS())
        love.graphics.setColor{0, 0, 0, 1}
        love.graphics.print(msg, 0, 0)
        coroutine.yield()
    end
    ]])

    pipeline:pushCode('text', [[
    while true do
        local w, h = love.graphics.getDimensions()
        local x, y = math.random() * w, math.random() * h
        love.graphics.setColor{0, 0, 0}
        love.graphics.print("TestTest", x, y)

        coroutine.yield()
    end
    ]])

    pipeline:pushCode('circle_under_mouse', [[
    while true do
        local y = graphic_command_channel:demand()
        local x = graphic_command_channel:demand()
        local rad = graphic_command_channel:demand()
        love.graphics.setColor{0, 0, 1}
        love.graphics.circle('fill', x, y, rad)

        coroutine.yield()
    end
    ]])

    -- Допустимо-ли переопределение функций? Или добавить специальный флаг?
    -- Нормально-ли использовать константы?
    pipeline:pushCode('clear', [[
    while true do
        love.graphics.clear{0.5, 0.5, 0.5}
        coroutine.yield()
    end
    ]])
    -- }}}

    last_render = love.timer.getTime()

    print('Доступные тесты:')

    for _, T in ipairs(tests) do
        print(colorize("%{blue}" .. T.desc))
        print("-----------------------------------------")
    end

    local ok, errmsg = pcall(function()

        callt(1)

        --callt(2)
        --callt(3)
        --callt(4)
        --callt(5)
        --callt(6)
        --callt(7)
        --callt(8)
        --callt(9)
        --callt(10)

    end) as (boolean, string)
    if not ok then
        error("Test failed with: " .. errmsg)
    end
end

local function render()
    -- {{{
    pipeline:openAndClose('clear')

    pipeline:open('text')
    pipeline:close()

    pipeline:openAndClose('print_fps')

    local x, y = love.mouse.getPosition()
    local rad = 50
    pipeline:open('circle_under_mouse')
    pipeline:push(y)
    pipeline:push(x)
    pipeline:push(rad)
    pipeline:close()

    pipeline:sync()
    -- }}}
end

local function mainloop()
    -- {{{
    while true do
        local events = event_channel:pop() as {any}
        if events then
            for _, e in ipairs(events) do
                local evtype: string = (e as {string})[1]
                if evtype == "mousemoved" then
                    mx = math.floor((e as {number})[2])
                    my = math.floor((e as {number})[3])
                elseif evtype == "keypressed" then
                    local key = (e as {string})[2]
                    local scancode = (e as {string})[3]
                    print('keypressed', key, scancode)
                    if scancode == "escape" then
                        love.event.quit()
                    end
                elseif evtype == "mousepressed" then
                end
            end
        end
        
        local nt = love.timer.getTime()
        local pause = 1. / 300.
        if nt - last_render >= pause then
            last_render = nt
            render()
        end

        love.timer.sleep(0.0001)
    end
    -- }}}
end

init()
mainloop()

print('goodbye. I scene from separated thread')
