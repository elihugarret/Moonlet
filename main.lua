--[Uncomment this for midi
moon = require "moonlet"
local out1 = moon.openout(0)
out1:sendMessage(193,4,0) --96 is cool
moon.init "luna"
--]]