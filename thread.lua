print('hi from thread')

local vars = { ... }
local msg_addr = vars[1]


print('thread msg_addr', msg_addr)

local msg = require('messenger2')
local chan = msg.new()

local v
repeat
   v = chan:pop()
   print('value', v)
until not v
