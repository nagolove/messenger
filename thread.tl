-- vim: set colorcolumn=85
-- vim: fdm=marker

print('hi from thread')

local colorize = require 'ansicolors2'.ansicolors
local msg = require 'messenger2'

local vars = {...}
local channel_name = vars[1]
local channel_state = vars[2] as msg.State
local test_case = vars[3] as string

--[[
-- {{{
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
-- }}}
--]]

assert(type(channel_name) == "string")
assert(type(channel_state) == "userdata")
assert(type(test_case) == 'string')

print('thread: channel_name', channel_name)
print('thread: channel_state', channel_state)

local enum Tests
    'test1'
    'test2'
end

local tests = {}

function tests.test1()
    msg.init_messenger(channel_state)
    local chan = msg.new(channel_name)

    local v: any
    repeat
        local ok, errmsg = pcall(function()
            v = msg.pop(chan)

            --msg.push(chan, "hi from thread")

            print(colorize('%{red}thread: value = ' .. tostring(v)))
        end) as (boolean, string)
        if not ok then
            print('thread: errmsg', errmsg)
        end
    until not v
    msg.free(chan)
end

function tests.test2()
end

local ok, errmsg = pcall(function()
    tests[test_case as Tests]()
end) as (boolean, string)
if not ok then
    error('Something wrong in test case call: ' .. errmsg)
end

