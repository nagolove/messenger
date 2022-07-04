local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local math = _tl_compat and _tl_compat.math or math; print('hello. I scene from separated thread')


require("love")
require("love_inc").require_pls_nographic()
local Pipeline = require('pipeline')

love.filesystem.setRequirePath("?.lua;?/init.lua;scenes/messenger/?.lua")

local event_channel = love.thread.getChannel("event_channel")

local mx, my = 0, 0
local last_render

local pipeline = Pipeline.new()
local thread
local msg = require('messenger2')

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

   local state = msg.init()
   print('state', state)

   for i = 1, 5 do
      msg.new("channel_" .. tonumber(i))
   end

   local channel_name = "KANAL_331";
   local channel = msg.new(channel_name);
   for i = 9, 1, -1 do
      msg.push(channel, i)
   end

   thread = love.thread.newThread("scenes/messenger/thread.lua")
   thread:start(channel_name, state)
   print('thread started')

   for _ = 9, 1, -1 do
      msg.push(channel, 0)
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
