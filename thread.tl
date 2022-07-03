print('hi from thread')

local vars = {...}
local msg_addr = vars[1]

--assert(type(msg_addr) == "string")
print('thread msg_addr', msg_addr)

local msg = require 'messenger2'
local chan = msg.new() -- А где идентификатор, имя канала?

local v: any
repeat
    v = chan:pop()
    print('value', v)
until not v
