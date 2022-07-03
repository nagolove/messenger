print('hi from thread')

local vars = {...}
local msg_addr = vars[1]

--assert(type(msg_addr) == "string")
print('thread msg_addr', msg_addr)

local msg = require 'messenger'

msg.connect(msg_addr)

if not msg.connect(msg_addr) then
    --error('Something wrong with "msg.connect()"')
    print('Something wrong with "msg.connect()"')
end

print('connected.')

--while not msg.empty() do
    local value = msg.pop()
    print('value', value)
--end
