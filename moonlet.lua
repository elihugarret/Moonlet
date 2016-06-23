--Moonlet
--Experimental module for audio livecoding
--Written by Elihu Garret, Mexico 2015

local Gen = require "gen"
local allen = require "allen"
local midi = require "luamidi"
local moses = require "moses"
local ffi = require "ffi"
local moont = {}

math.randomseed(os.clock())

moont.openout = midi.openout
moont.send_message = midi.sendMessage
moont.base0 = midi.base0
moont.base1 = midi.base1
local soundPlay = proAudio.soundPlay
local fromFile = proAudio.sampleFromFile
local remove = table.remove
local insert = table.insert
local tonumber = tonumber
local max = math.max
local min = math.min
local floor = math.floor
local unpack = unpack
local xp = xpcall
local tono = 1 --change to 0.5 if you are on linux
local noteOn, noteOff = midi.noteOn, midi.noteOff
local dir = "../Samples/808/"
local kic = fromFile(dir.."kick.ogg")
local sna = fromFile(dir.."snare.ogg") 
local ope = fromFile(dir.."openhat.ogg")
local hat = fromFile(dir.."hat.ogg")
local rob = fromFile(dir.."robot.ogg") 
local vel = fromFile(dir.."velcro.ogg")
local iro = fromFile(dir.."iron.ogg")
local exh = fromFile(dir.."exhale.ogg")
local air = fromFile(dir.."air.ogg")
local ice = fromFile(dir.."ice.ogg")
local kit = fromFile(dir.."kitkick.ogg")
local met = fromFile(dir.."metal.ogg")
local tin = fromFile(dir.."tin.ogg")
local tam = fromFile(dir.."tam.ogg")
local mar = fromFile(dir.."mar.ogg")
local cab = fromFile(dir.."cab.ogg")
local req = fromFile(dir.."req.ogg")
local pan = fromFile(dir.."pan.ogg")
local woo = fromFile(dir.."woo.ogg")
local snap = fromFile(dir.."sna.ogg")

local bank = {
  x = kic,
  o = sna,
  h = hat,
  p = ope,
  m = rob,
  v = vel,
  c = iro,
  l = exh,
  a = air,
  i = ice,
  k = kit,
  t = met,   
  b = tin,
  A = tam,
  B = mar,
  C = cab,
  D = req,
  E = pan,
  F = woo,
  G = snap,
  _ = function (dur) moont.sleep(dur) end,
}
------[[Gen.play(1,Gen.vR(1,1,1,1),1,dur,0,0)--]]

ffi.cdef[[
void Sleep(int ms);
int poll(struct pollfd *fds, unsigned long nfds, int timeout);
]]

if ffi.os == "Windows" then
  function moont.sleep(s)
    ffi.C.Sleep(s*1000)
  end
else
  function moont.sleep(s)
    ffi.C.poll(nil, 0, s*1000)
  end
end

function moont.bpm(b)
  return (60/b) / 2
end

function string:n()
  local tabla = {}
  local it = 1
  for y in self:gmatch'%g+' do
    tabla[it] = y
    it = it + 1
  end
  return tabla
end

function string:r(b)
  b = b or 1
  local t = {}
  local i = 1
  for c in self:gmatch'%g+' do
    if not tonumber(c) then t[i] = 0 
      else  t[i] = b/c    
    end
    i = i + 1
  end
  return t
end

local function isTable(t)
  return type(t) == 'table'
end

local function each(list, f, ...)
  if not isTable(list) then return end
  for index,value in pairs(list) do
    f(index,value,...)
  end
end

function moont.init(file)
	while true do
		local luna = xp(function () return require(file) end,
      function () print("error"); moont.sleep(1) end)
		package.loaded.luna = nil
	end
end

function moont.normalize(rango_i, rango_f, t)
  local tr = {}
  local x_max = max(moses.max(t))
  local x_min = min(moses.min(t))
  for i = 1, #t do
    tr[i] = floor(rango_i + ((t[i] - x_min) * (rango_f - rango_i) / (x_max - x_min)))
  end
  return tr 
end

function moont.spec_norm(t1, t2)
  local tq = {}
  local l = #t1
  local n = moont.normalize(1,l,t2)
  for c, v in ipairs(n) do
    tq[c] = t1[v]
  end
  return tq
end

function string:notes(t)
  local tw = {}
  local i = 1
  for v in self:gmatch '.' do
    if v ~= ' ' then 
    tw[i] = v:byte()
    i = i + 1
    end
  end
  return moont.spec_norm(t, tw)
end
--y[moont.w(_, #y)]
function moont.w(counter, lenght)
  local var = counter % lenght
  if var == 0 then return lenght
    else return var 
  end
end

function moont.rev(tab)
  local a = {}
  for i = #tab,1,-1 do
    insert(a,tab[i])
  end
  return a
end

function moont.shift(tab,pl)
  pl = pl or 1
  local x
  if pl >= 1 then x = 1 else x = -1 end
  for i = 1,pl,x do
    insert(tab,1,tab[#tab])
    remove(tab,#tab)
  end
  return tab
end

function moont.clear(time)
  local destroy = proAudio.destroy
  sleep(time)
  destroy()
  os.exit()
end

function moont.Q(q)
  q.s = q.s or 32
  q.o = q.o or {}
  t = {}
  if #q.w ~= #q.p then return print "no coincide tamaño de tablas" end
  local x = 0
  for i = 1, q.s do
    x = x + 1
    if not q.w[x] then x = 1 end
    if math.random() <= q.w[x] then t[i] = q.p[x] else t[i] = q.o[x] or '_' end
  end
  return t
end

local function non_repeat(t)
  local hash = {}
  local res = {}
  for _,v in ipairs(t) do
    if (not hash[v]) then
      res[#res+1] = v 
      hash[v] = true
    end
  end
  return res
end

local function put(stbl,btbl)
  local t = {}
  for i = 1, #stbl do
    t[i] = btbl[stbl[i]]
  end
  return t
end

local function get_weights(z,y,r)
  r = r or 0
  local t ={}
  local v
  for i = 1, #y do
    v = (moses.count(z,y[i]) / #z) + r 
    t[i] = v 
  end
  return t
end
function moont.A(a)  
  local z = chars(a.T)
  local y = non_repeat(z)
  local x = bytes(a.T)
  local v = put(y,x)
  local u = get_weights(z,y,a.D)
  local norm = moont.spec_norm(a.P,v)
  return moont.Q{p = norm, w = u, o = a.O, s = a.S}
end

-- .ogg player  [proAudioRt can't handle high quality .wav files]
function moont.sample(tipo)
  tipo.disparity = tipo.disparity or 0
  tipo.pitch = tipo.pitch or tono 
  local direc = "../Samples/Sounds/"
  local sample = fromFile(direc..tipo.file..".ogg")
  sonido = soundPlay(sample,tipo.L,tipo.R,tipo.disparity,tipo.pitch)
end

function moont.choose(...)
  local var = {...}
  return var[math.random(#var)]
end

function moont.i_sort(array)
  local len = #array
  local j, k
  local m = {}
  for j = 2, len do
    local key = array[j]
    local i = j-1
    while i > 0 and array[i] > key do
      array[i+1] = array[i]
      i = i-1
    end
    array[i+1] = key
    k = {unpack(array)}
    insert(m,k)
  end
  return m
end

function moont.shuffle(list)
   local shuffled = {}
  each(list,function(index,value)
    local randPos = math.floor(math.random()*index)+1
    shuffled[index] = shuffled[randPos]
    shuffled[randPos] = value
    end)
  return shuffled
end


function moont.rgen(s,...)
  local t = {}
  for i = 1, s do
    t[i] = moont.choose(...)
  end
  return t
end

local function note_off(puerto,nota,canal)
  moont.send_message(puerto,128,nota,0,canal)
end


function moont.range(...)
  local arg = {...}
  local start,stop,step
  if #arg==0 then return {}
  elseif #arg==1 then stop,start,step = arg[1],0,1
  elseif #arg==2 then start,stop,step = arg[1],arg[2],1
  elseif #arg == 3 then start,stop,step = arg[1],arg[2],arg[3]
  end
  if (step and step==0) then return {} end
  local ranged = {}
  local steps = math.max(math.floor((stop-start)/step),0)
  for i=1,steps do ranged[#ranged+1] = start+step*i end
  if #ranged>0 then insert(ranged,1,start) end
  return ranged
end

function moont.l_seq(v)
  v.pitch = v.pitch or tono
  v.disparity = v.disparity or 0
  v.dur = v.dur or 1/4
  v.scale = v.scale or 24
  v.gen = v.gen or Gen.vR(1,1,100,1,1)
  v.L = v.L or 0.5
  v.R = v.R or v.L
  do
    if type(moont.bank[v.seq]) == "function" then moont.bank[v.seq](v.dur)
      elseif type(moont.bank[v.seq]) == "nil" then Gen.play(v.scale,v.gen,v.seq,v.dur,v.L/10,v.R/10,v.disparity)
      else moont.soundPlay(moont.bank[v.seq],v.Ls,v.Rs,v.disparity,v.pitch)
    end
  end
end

function moont.midi_notes()
  local a = "c c# d d# e f f# g g# a a# b"
  local t = {}
  local c = 0
  for i = -1, 8 do
    for _ in a:gmatch'%g+' do
      t[_..i] = c
      c = c + 1
    end
  end
  return t
end

local notes = moont.midi_notes()

function moont.to_midi(t)
  for i = 1, #t do
    t[i] = notes[t[i]]
  end
  return t
end

function moont.chord(t, c, i, f, v, p, ch)
  v = v or 77
  p = p or 0
  ch = ch or 0
  if c == i then
    for _, q in ipairs(t) do
      noteOn(p, notes[q] or q, v, ch)
    end
  elseif c == f then
    for _, q in ipairs(t) do
      note_off(p, notes[q] or q,ch)
    end
  end
end

function moont.play_midi(port,note,vel,ch,dur)
  port = port or 1
  ch = ch or 1
  vel = vel or 70
  dur = dur or 0
  do
    noteOn(port,note,vel,ch)  
    moont.sleep(dur)
    noteOff(port,note,vel,ch)
  end
end

function moont.m_seq(foo)
  foo.port = foo.port or 1
  foo.dur = foo.dur or 0.5
  foo.L = foo.L or 0.5
  foo.R = foo.R or foo.L
  foo.disparity = foo.disparity or 0
  foo.pitch = foo.pitch or tone
  do
    if type(bank[foo.seq]) == "function" then bank[foo.seq](foo.dur)
    elseif type(foo.seq) == "number" then
      moont.play_midi(foo.port,foo.seq,foo.vel,foo.channel,foo.dur)
    elseif #foo.seq > 1 then moont.play_midi(foo.port,notes[foo.seq],foo.vel,foo.channel,foo.dur)
    else
      soundPlay(bank[foo.seq],foo.L,foo.R,foo.disparity,foo.pitch)
    end
  end
end

local f = function () end

function moont.n_seq(n)
  
  local nota1 = notes[n.note1] or n.note1
  local nota2 = notes[n.note2] or n.note2
  
  n.L1 = n.L1 or 1
  n.R1 = n.R1 or 1
  n.disparity1 = n.disparity1 or 0
  n.pitch = n.pitch or 1
  
  n.L2 = n.L2 or n.L1
  n.R2 = n.R2 or n.R1
  n.disparity2 = n.disparity2 or n.disparity1
  n.pitch2 = n.pitch2 or pitch1
  
  n.port1 = n.port1 or 0
  n.vel1 = n.vel1 or 70
  n.vel2 = n.vel2 or 70
  n.ch1 = n.ch1 or 0
  
  n.port2 = n.port2 or n.port1
  n.ch2 = n.ch2 or n.ch1
  
  xp(function () 
      soundPlay(bank[n.beat1],n.L1,n.R1,n.disparity1,n.pitch1)
    end,f)
  xp(function () 
      soundPlay(bank[n.beat2],n.L2,n.R2,n.disparity2,n.pitch2)
    end,f)
  xp(function () noteOn(n.port1,nota1,n.vel1,n.ch1) end,f)
  xp(function () noteOn(n.port2,nota2,n.vel2,n.ch2) end,f)
  
  moont.sleep(n.dur)
  
  xp(function () note_off(n.port1,nota1,n.ch1) end,f)
  xp(function () note_off(n.port2,nota2,n.ch2) end,f)
  
end

return moont
