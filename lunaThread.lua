function hey()
  local q = ("k _ _ m _ _ "):n()
  for _, v in ipairs(q) do
    moonlet.l_seq{
      seq = v,
      dur = 4/8,
      Ls = 0.2,
      Rs = 0.3,
      pitch = 0.1
    }
  end
end

function hi()
local a = ("c3 d#3 g3 _ c3 g5 g4 "):n()
local b = ("- - 8 8 16 16 16"):r(4)

  for _, v in ipairs(a) do
    midim.m_seq{
      seq = v,
      durNote = b[_],
      portNote = 0,
      velNote = 77
    }
  end
end