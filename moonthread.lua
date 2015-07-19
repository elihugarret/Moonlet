moonlet = require "moonlet"

local llthreads = require "llthreads"

local thread_code = [[
  moonlet = require "moonlet"
  while true do
    local luna = require "luna"
     hey()
    package.loaded.luna = nil
  end
]]

local thread = llthreads.new(thread_code)

function joiner()
  while true do
    local luna = require "luna"
      hi()
    package.loaded.luna = nil
  end
end

thread:start()
thread:join(joiner())