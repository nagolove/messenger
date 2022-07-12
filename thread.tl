-- vim: set colorcolumn=85
-- vim: fdm=marker

print('hi from thread')

local colorize = require 'ansicolors2'.ansicolors
local msg = require 'messenger2'

local vars = {...}
local channel_name = vars[1]
local channel_state = vars[2] as msg.State
local test_case = vars[3] as string

assert(type(channel_name) == "string")
assert(type(channel_state) == "userdata")
assert(type(test_case) == 'string')

print('thread: channel_name', channel_name)
print('thread: channel_state', channel_state)
print('thread: test_case', test_case)

local enum Tests
    'full_pop'
end

local tests = {}

function tests.full_pop()
    msg.init_messenger(channel_state)
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
end

function tests.demand_by_count()
    print('tests.demand_by_count')
    msg.init_messenger(channel_state)
    local chan = msg.new(channel_name)

    local qwerty = love.thread.getChannel('qwerty')
    local t: any
    repeat
        t = qwerty:pop()
        print('t', t)
    until not t

    print(colorize('%{magenta}----------------------------------'))
    msg.print(chan)
    msg.print_strings(chan)
    msg.print_numbers(chan)
    print(colorize('%{magenta}----------------------------------'))

    --local count = 
    --msg.pop(chan)
    local count = msg.pop(chan)
    local message = 'I should demand for %d values.'
    print(colorize("%{yellow}" .. string.format(message, count)))

    local v: any
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
        end) as (boolean, string)
        if not ok then
            print('thread: errmsg', errmsg)
        end
    until not v
    msg.free(chan)
end

function tests.push_only_numbers()
    msg.init_messenger(channel_state)
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
end

local ok, errmsg = pcall(function()
    tests[test_case as Tests]()
end) as (boolean, string)
if not ok then
    error('Something wrong in test case call: ' .. errmsg)
end

