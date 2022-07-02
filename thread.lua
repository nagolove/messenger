print('hi from thread')

local vars = { ... }
local msg_addr = vars[1]


print('thread msg_addr', msg_addr)

local msg = require('messenger')
msg.connect(msg_addr)
if not msg.connect(msg_addr) then

   print('Something wrong with "msg.connect()"')
end

print('connected.')
