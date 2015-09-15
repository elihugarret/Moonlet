require "audioin"
local moon = require "moonlet"

audioin.Init()
while true do
  t = audioin.ExecuteFFT(1,1)
  if t[1] > 20 then print(t[1]) end
  moon.sleep(0.05)
end