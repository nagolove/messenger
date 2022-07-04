print('hi from thread')

local colorize = require 'ansicolors2'.ansicolors
local msg = require 'messenger2'

local vars = {...}
local channel_name = vars[1]
local channel_state = vars[2] as msg.State

--[[
assert(type(channel_name) == "string")
assert(type(channel_state) == "userdata")

print('thread: channel_name', channel_name)
print('thread: channel_state', channel_state)

msg.init(channel_state)
local chan = msg.new(channel_name)

local v: any
repeat
    local ok, errmsg = pcall(function()
        v = chan:pop()
        print('thread: value', v)
    end) as (boolean, string)
    if not ok then
        print('thread: errmsg', errmsg)
    end
until not v
--]]

assert(type(channel_name) == "string")
assert(type(channel_state) == "userdata")

print('thread: channel_name', channel_name)
print('thread: channel_state', channel_state)

msg.init(channel_state)
local chan = msg.new(channel_name)

local v: any
repeat
    local ok, errmsg = pcall(function()
        v = msg.pop(chan)
        print(colorize('%{red}thread: value = ' .. tostring(v)))
    end) as (boolean, string)
    if not ok then
        print('thread: errmsg', errmsg)
    end
until not v

msg.free(chan)
