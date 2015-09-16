local a = ([[
  x c4 d3 d3 x p g4 g3
  h a#2 x d4 x p d2 c4
  x c3 c4 x p d2 a#4
  h c3 x f3 a#3 x p g4 c3
  ]]):n()

local b = ([[
  - 32 32 16 - - 16 16
  - 16 - 16 - - 16 16
  - 16 16 - - 16 16
  - 16 - 32 32 - - 16 16
  ]]):r(4)

local d = {'a3','c4','e4'}

for _, v in ipairs(a) do
  moon.chord(d, _, 3, 13,70)
  moon.m_seq{
  --pitch = moont.choose(0.2,0.1),
  --disparity = moont.choose(.4,.2),
  seq = v,
  dur = b[_],
  R = 1,
  L = 1,
  port = 0,
  vel = 70
  }
end 
