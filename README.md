rmarshal
========

dump and load marshal data via lua, and equal to ruby marshal

## Requirements

luajit

## Demo

dump in Ruby

```ruby
h = {
   _csrf_token: "l6xLJ5cJN59jgx7H5y9BO6jsjyZ9dr0kMpmcMr7H+p4=",
   db_id: 5,
   return_to: "/",
   session_id: "90ea8d4b7a331fa8a8a49b2a26beefde",
   user_id: 4
 }
s = Marshal.dump(h) #=> "\x04\b{\nI\"\x0Ereturn_to\x06:\x06EF\"\x06/I\"\x0Fsession_id\x06;\x00FI\"%90ea8d4b7a331fa8a8a49b2a26beefde\x06;\x00TI\"\x10_csrf_token\x06;\x00FI\"1l6xLJ5cJN59jgx7H5y9BO6jsjyZ9dr0kMpmcMr7H+p4=\x06;\x00FI\"\fuser_id\x06;\x00Fi\tI\"\ndb_id\x06;\x00Fi\n7"
```

load in Lua

```lua
local inspect = require("inspect")
local rmarshal = require("rmarshal")
local t = rmarshal:load(s)
print(inspect(t))
-- =>
-- {
--   _csrf_token = "l6xLJ5cJN59jgx7H5y9BO6jsjyZ9dr0kMpmcMr7H+p4=",
--   db_id = 5,
--   return_to = "/",
--   session_id = "90ea8d4b7a331fa8a8a49b2a26beefde",
--   user_id = 4
-- }
```

That's ALL, JUST DO IT!!!

