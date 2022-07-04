local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; print('hi from thread')

local vars = { ... }
local channel_name = vars[1]

assert(type(channel_name) == "string")
print('channel_name', channel_name)

local msg = require('messenger2')
local chan = msg.new(channel_name)

local v
repeat
   v = chan:pop()
   print('value', v)
until not v
