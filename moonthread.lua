moon = require "moonlet"
local llthreads = require "llthreads"

local out1 = moon.openout(0)
out1:sendMessage(193,0,0)

local thread_code = [[
  moonlet = require "moonlet"
  while true do
    local luna = require "lunaThread"
     hey()
    package.loaded.lunaThread = nil
  end
]]

local thread = llthreads.new(thread_code)

function joiner()
  while true do
    local luna = require "lunaThread"
      hi()
    package.loaded.lunaThread = nil
  end
end

thread:start()
thread:join(joiner())