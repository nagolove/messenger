print('hello. I scene from separated thread')

--require 'konstants'
require "love"
require "love_inc".require_pls_nographic()
local Pipeline = require 'pipeline'

love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/messenger/?.lua")

local event_channel = love.thread.getChannel("event_channel")

local mx, my = 0, 0
local last_render: number

local pipeline = Pipeline.new()
local thread: love.thread.Thread
local msg = require 'messenger2'

local function init()
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

    last_render = love.timer.getTime()

    --[[
    local addr_str: string
    Channel, addr_str = msg.init()
    print('addr_str', addr_str)

    msg.connect(addr_str)
    msg.push('it works!')
    --]]

    for i = 1, 5 do
        msg.new("channel_" .. tonumber(i))
    end

    local channel_name = "KANAL_331";
    local channel = msg.new(channel_name);
    for i = 9, 1, -1 do
        channel:push(i)
    end

    thread = love.thread.newThread("scenes/messenger/thread.lua")
    thread:start(channel_name)
    print('thread started')

    for _ = 9, 1, -1 do
        channel:push(0)
    end
    --]]
end

local function render()
    pipeline:openAndClose('clear')

    pipeline:open('text')
    pipeline:close()

    pipeline:openAndClose('print_fps')

    local x, y = love.mouse.getPosition()
    --print('mouse x, y', x, y)
    local rad = 50
    pipeline:open('circle_under_mouse')
    pipeline:push(y)
    pipeline:push(x)
    pipeline:push(rad)
    pipeline:close()
    --]]

    pipeline:sync()
end

local function mainloop()
    while true do
        --print('mainloop iter')
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
                    --local x: number = (e as {number})[2]
                    --local y: number = (e as {number})[3]
                    --local button: number = (e as {number})[4]
                    --local istouch: boolean = (e as {boolean})[5]
                    --local presses: number = (e as {number})[6]
                end
            end
        end
        
        local nt = love.timer.getTime()
        --local pause = 1. / 10.
        local pause = 1. / 300.
        if nt - last_render >= pause then
            last_render = nt
            render()
        end
        --]]

        --love.timer.sleep(0.0008)
        love.timer.sleep(0.0001)
    end
end

init()
mainloop()

print('goodbye. I scene from separated thread')
