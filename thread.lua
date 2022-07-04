local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; local pcall = _tl_compat and _tl_compat.pcall or pcall; print('hi from thread')

local colorize = require('ansicolors2').ansicolors
local msg = require('messenger2')

local vars = { ... }
local channel_name = vars[1]
local channel_state = vars[2]























assert(type(channel_name) == "string")
assert(type(channel_state) == "userdata")

print('thread: channel_name', channel_name)
print('thread: channel_state', channel_state)

msg.init(channel_state)
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
