local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string


print('hi from thread')

local colorize = require('ansicolors2').ansicolors
local msg = require('messenger2')

local vars = { ... }
local channel_name = vars[1]
local channel_state = vars[2]
local test_case = vars[3]

assert(type(channel_name) == "string")
assert(type(channel_state) == "userdata")
assert(type(test_case) == 'string')

print('thread: channel_name', channel_name)
print('thread: channel_state', channel_state)
print('thread: test_case', test_case)

local Tests = {}



local tests = {}

function tests.full_pop()
   msg.init_messenger(channel_state)
   local chan = msg.new(channel_name)

   local v
   repeat
      local ok, errmsg = pcall(function()
         v = msg.pop(chan)
         print(colorize('%{red}thread: value = ' .. tostring(v)))
      end)
      if not ok then
         print('thread: errmsg', errmsg)
      end
   until not v
   msg.free(chan)
end

function tests.demand_by_count()
   print('tests.demand_by_count')
   msg.init_messenger(channel_state)
   local chan = msg.new(channel_name)


   local count = msg.pop(chan)
   local message = 'I should demand for %d values.'
   print(colorize("%{yellow}" .. string.format(message, count)))

   local v
   local i = 1
   repeat
      local ok, errmsg = pcall(function()
         if count == i then
            v = nil
         else
            v = msg.demand(chan)
            i = i + 1
            print(colorize('%{red}thread: value = ' .. tostring(v)))
         end
      end)
      if not ok then
         print('thread: errmsg', errmsg)
      end
   until not v
   msg.free(chan)
end

function tests.push_only_numbers()
   msg.init_messenger(channel_state)
   local chan = msg.new(channel_name)

   local v
   repeat
      local ok, errmsg = pcall(function()
         v = msg.pop(chan)
         print(colorize('%{red}thread: value = ' .. tostring(v)))
      end)
      if not ok then
         print('thread: errmsg', errmsg)
      end
   until not v
   msg.free(chan)
end

local ok, errmsg = pcall(function()
   tests[test_case]()
end)
if not ok then
   error('Something wrong in test case call: ' .. errmsg)
end
