local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; local pcall = _tl_compat and _tl_compat.pcall or pcall; local table = _tl_compat and _tl_compat.table or table


print('hello. I scene from separated thread')
require("love")
require("love_inc").require_pls_nographic()
love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/messenger/?.lua")

local Pipeline = require('pipeline')
local pipeline = Pipeline.new()
local event_channel = love.thread.getChannel("event_channel")
local colorize = require('ansicolors2').ansicolors
local mx, my = 0, 0
local last_render
local inspect = require('inspect')
local thread

local msg = require('messenger2')

local Test = {}



local tests = {}

table.insert(tests, {
   desc = [[Создание канала. 
Только числовые данные.
Получение данных со стороны создающего канал потока.]],
   func = function()


      local state = msg.init_messenger()
      print('state', state)

      local channel_name = "KANAL";
      local channel = msg.new(channel_name);

      for i = 9, 1, -1 do
         msg.push(channel, i)
      end

      msg.channel_print_strings(channel)
      msg.channel_print_numbers(channel)

      local value
      repeat
         value = msg.pop(channel)
         print('popped value', value)
      until not value

   end,
})

table.insert(tests, {
   desc = [[Создание канала. 
Только строковые данные.
Получение данных со стороны создающего канал потока.]],
   func = function()


      local state = msg.init_messenger()
      print('state', state)

      local channel_name = "KANAL";
      local channel = msg.new(channel_name);

      for i = 9, 1, -1 do
         local mess = randomFilenameStr(math.random(1, 5));
         msg.push(channel, "hello_" .. mess .. "_" .. tostring(i))
      end

      msg.channel_print_strings(channel)
      msg.channel_print_numbers(channel)

      local value
      repeat
         value = msg.pop(channel)
         print('popped value', value)
      until not value

   end,
})

table.insert(tests, {
   desc = [[Создание канала. 
Только строковые данные.
Получение данных со стороны создающего канал потока.
Заталкивание строки больше разрешенной длины.]],
   func = function()


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

      msg.channel_print_strings(channel)
      msg.channel_print_numbers(channel)

      local value
      repeat
         value = msg.pop(channel)
         print('popped value', value)
      until not value

   end,
})

table.insert(tests, {
   desc = [[Создание каналов. 
Только числовые данные.
Получение данных со стороны другого потока.]],
   func = function()


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

      msg.channel_print_numbers(channel)
      print('-----------------------------------')
      love.timer.sleep(0.1)
      msg.channel_print_numbers(channel)
      print('-----------------------------------')


   end,
})

table.insert(tests, {
   desc = [[Создание каналов. 
Только числовые данные.
Получение данных со стороны другого потока.]],
   func = function()


      local state = msg.init_messenger()
      print('state', state)

      local channel_name = "KANAL_331";
      local channel = msg.new(channel_name);

      print('msg', inspect(msg))





















   end,
})

table.insert(tests, {
   desc = [[Создание каналов. 
Только строковые данные. 
Получение данных со стороны потока.]],
   func = function()


      local state = msg.init_messenger()
      print('state', state)

      local channel_name = "KANAL_331";
      local channel = msg.new(channel_name);

      for i = 9, 1, -1 do
         msg.push(channel, i)
      end

      thread = love.thread.newThread("scenes/messenger/thread.lua")
      thread:start(channel_name, state, 'test4')
      print('thread started')

      for _ = 9, 1, -1 do
         msg.push(channel, 0)
      end

   end,
})

local function callt(index)
   print('Вызов:', colorize("%{yellow}" .. tests[index].desc))
   tests[index].func()
end

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



   pipeline:pushCode('clear', [[
    while true do
        love.graphics.clear{0.5, 0.5, 0.5}
        coroutine.yield()
    end
    ]])


   last_render = love.timer.getTime()

   print('Доступные тесты:')

   for _, T in ipairs(tests) do
      print(colorize("%{blue}" .. T.desc))
      print("-----------------------------------------")
   end

   local ok, errmsg = pcall(function()







      callt(5)

   end)
   if not ok then
      error("Test failed with: " .. errmsg)
   end
end

local function render()
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
end

local function mainloop()
   while true do

      local events = event_channel:pop()
      if events then
         for _, e in ipairs(events) do
            local evtype = (e)[1]
            if evtype == "mousemoved" then
               mx = math.floor((e)[2])
               my = math.floor((e)[3])
            elseif evtype == "keypressed" then
               local key = (e)[2]
               local scancode = (e)[3]
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
end

init()
mainloop()

print('goodbye. I scene from separated thread')
