-- you must run by luajit
-- if you use lua bin, maybe meet  'bit' module cant filnd error

package.path = package.path .. ";/data/lua/rmarshal/lib/?.lua"

local inspect = require "inspect"
local rmarshal = require "rmarshal"

local dump_data = "\x04\b{\nI\"\x0Ereturn_to\x06:\x06EF\"\x06/I\"\x0Fsession_id\x06;\x00FI\"%90ea8d4b7a331fa8a8a49b2a26beefde\x06;\x00TI\"\x10_csrf_token\x06;\x00FI\"1l6xLJ5cJN59jgx7H5y9BO6jsjyZ9dr0kMpmcMr7H+p4=\x06;\x00FI\"\fuser_id\x06;\x00Fi\tI\"\ndb_id\x06;\x00Fi\n7"

local t = rmarshal:load(dump_data)

-- print(inspect(t))

-- t =>
-- {
--   _csrf_token = "l6xLJ5cJN59jgx7H5y9BO6jsjyZ9dr0kMpmcMr7H+p4=",
--   db_id = 5,
--   return_to = "/",
--   session_id = "90ea8d4b7a331fa8a8a49b2a26beefde",
--   user_id = 4
-- }

if t["db_id"] ~= 5 then
  error("marshal data load error")
end

if t["user_id"] ~= 4 then
  error("marshal data load error")
end
