print('hi from thread')

local vars = {...}
local channel_name = vars[1]

assert(type(channel_name) == "string")
print('channel_name', channel_name)

local msg = require 'messenger2'
local chan = msg.new(channel_name) -- А где идентификатор, имя канала?

local v: any
repeat
    v = chan:pop()
    print('value', v)
until not v
