--Moonlet
--Lua/MoonScript experimental modules for audio livecoding
--Written by Elihu Garret, Mexico 2015

Gen = require "gen"
local allen = require "allen"
local moont = {}
--globals
math.randomseed(os.clock())
random = math.random --a[random(#a)] usage example
wrap = coroutine.wrap
yield = coroutine.yield
soundPlay = proAudio.soundPlay
--
local clock = os.clock
function moont.sleep(n) 
  local t0 = clock()
  while clock() - t0 <= n do end
end
--
--locals
local fromFile = proAudio.sampleFromFile
local remove = table.remove
local insert = table.insert
local concat = table.concat
local tono = 1 --change to 0.5 if you are on linux
--Load your samples
local dir = "../Samples/"
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
bank = {
  x = kic,
  o = sna,
  ['*'] = hat,
  ['-'] = ope,
  ['&'] = rob,
  ['#'] = vel,
  ['+'] = iro,
  ['$'] = exh,
  ['@'] = air,
  ['%'] = ice,
  ['~'] = kit,
  ['!'] = met,
  [';'] = tin,
  A = tam,
  B = mar,
  C = cab,
  D = req,
  E = pan,
  F = woo,
  G = snap,
  [' '] = function (dur) Gen.play(1,Gen.vR(1,1,1,1),1,dur,0,0) end,
}
----
-- isTable
local function isTable(t)
  return type(t) == 'table'
end
----
-- Each
local function each(list, f, ...)
  if not isTable(list) then return end
  for index,value in pairs(list) do
    f(index,value,...)
  end
end
----Init function
function moont.init(file)
	while true do
		local luna = require(file)
		package.loaded.luna = nil
	end
end
----
--Relative tempo
function moont.t(bpm)
  local x=30/bpm
  return x
end
----
function moont.lpairs(...)
  local t = {...}
  local tmp = {...}
  if #tmp==0 then
    return function() end, nil, nil
  end
  local function mult_ipairs_it(t, i)
    i = i+1
    for j=1,#t do
      local val = t[j][i]
      if val == nil then return val end
      tmp[j] = val
    end
    return i, unpack(tmp)
  end
  return mult_ipairs_it, t, 0
end
----
--Reverse a table
function moont.rev(tab)
  local a = {}
  for i = #tab,1,-1 do
    insert(a,tab[i])
  end
  return a
end
----
--Shift a table
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
----
--Like SC .clear
function moont.clear(time)
  local destroy = proAudio.destroy
  sleep(time)
  destroy()
  os.exit()
end
----
-- .ogg player  [proAudioRt can't handle high quality .wav files]
function moont.sample(tipo)
  tipo.disparity = tipo.disparity or 0
  tipo.pitch = tipo.pitch or tono 
  local direc = "../Samples/Sounds/"
  local sample = fromFile(direc..tipo.file..".ogg")
  sonido = soundPlay(sample,tipo.L,tipo.R,tipo.disparity,tipo.pitch)
end
----
--Rotate a string.
function moont.rotate(s,n)
    local p
    if n>0 then
        p="("..string.rep("%S+",n,"%s+")..")".."(.-)$"
    else
        n=-n
        p="^(.-)%s+".."("..string.rep("%S+",n,"%s+").."%s*)$"
    end
    return (s:gsub(p,"%2 %1"))
end

--Choose function (similar to .choose method in SuperCollider)
--Remember string(rand(#),9)
function moont.choose(...)
  local var = {...}
  return var[math.random(#var)]
end

--Like choose() for "valid" characters
function moont.choose2()
  local samples = {'A','B','C','D','E','F','G','#','$','%','&','+','~','°','@',';'}
  local choose = random(#samples)
  return samples[choose] 
end
----
-- Shuffle
function moont.shuffle(list)
   local shuffled = {}
  each(list,function(index,value)
              local randPos = math.floor(math.random()*index)+1
              shuffled[index] = shuffled[randPos]
              shuffled[randPos] = value
              end)
  return shuffled
end
----
-- Range
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
----
--String to array of chars method

function string:sound(var) 
  local tabla = {}
  for char in self:gmatch('.') do insert(tabla,char) end
  return var == 'r' and moont.shuffle(tabla) or #tabla>0 and tabla or nil
end
----

function string:glue(r)
  local step = concat(self:sound(r),' ')..' '
  return step:sound()
end
----
function string:_(arg)
  local q = {}
  local w = self:gsub('|',''):sound(arg)
  for c,v in ipairs(w) do
    if tonumber(v) ~= nil and tonumber(w[c+1]) ~= nil then
      v = v..w[c+1]
      insert(q,v)
      remove(w,c+1)
      else insert(q,v)
    end
  end
  return q
end
----
--Pseudorandom string generator
 function moont.RSG(str,pattern,s, l)
          tble = str:gsub(' ',pattern)
       local char = tble/rand(#tble)
              pass = {}
        local size = math.random(s,l) 
        for z = 1,size do
              local   case = math.random(1,2) 
               local a = math.random(1,#char) 
                if case == 1 then
                        x=string.lower(char[a]) 
                elseif case == 2 then
                        x=chos()  
                end
        table.insert(pass, x) 
        end
        return(table.concat(pass,' ')) 
end
----
--Sequencer
function moont.rpattern(patrones,tono,dino,temp,vol1,vol2,dis,pit)
  pit = pit or tono
  dis = dis or 0
  for i, v in ipairs(patrones) do
    if type(bank[v]) == "function" then bank[v](temp)
      elseif type(bank[v]) == "nil" then Gen.play(tono,dino,v,temp,vol1/10,vol2/10,dis)
      else soundPlay(bank[v],vol1,vol2,dis,pit)
    end
  end
end

--Sequencer + coroutines
function moont.sec(var)
  local x
  var.scale = var.scale or 24
  var.scale2 = var.scale2 or 24
  var.gen = var.gen or Gen.vR(1,1,100,1,1)
  var.gen2 = var.gen2 or Gen.vR(1,1,100,1,1)
  var.speed = var.speed or 120
  var.speed2 = var.speed2 or var.speed 
  var.L = var.L or 0.2
  var.L2 = var.L2 or var.L
  var.R = var.R or 0.2
  var.R2 = var.R2 or var.R
  
  local par = wrap(function (patrones,tono,dino,temp,vol1,vol2,dis,pit)
    while true do
      pit = pit or tono
      dis = dis or 0
      for i, v in ipairs(patrones) do
        if type(bank[v]) == "function" then bank[v](temp)
        elseif type(bank[v]) == "nil" then Gen.play(tono,dino,v,temp,vol1/10,vol2/10,dis)
        else soundPlay(bank[v],vol1,vol2,dis,pit)
        end
      yield()
      end   
    end
  end
)
  local arp = wrap(function (patrones,tono,dino,temp,vol1,vol2,dis,pit)
    while true do
      pit = pit or tono
      dis = dis or 0
      for i, v in ipairs(patrones) do
        if type(bank[v]) == "function" then bank[v](temp)
        elseif type(bank[v]) == "nil" then Gen.play(tono,dino,v,temp,vol1/10,vol2/10,dis)
        else soundPlay(bank[v],vol1,vol2,dis,pit)
        end
        yield()
      end   
    end
  end
)
  if #var.pattern >= #var.pattern2 then x = #var.pattern else x = #var.pattern2 end
  for i = 1,x do
    par(var.pattern,var.scale,var.gen,moont.t(var.speed),var.L,var.R,var.disparity,var.pitch)
    arp(var.pattern2,var.scale2,var.gen2,moont.t(var.speed2),var.L2,var.L2,var.disparity2,var.pitch2)
  end
end

--Non-linear sequencing
function moont.seq(arg)
--[[lenght, every, variationPattern,shift1,dinoVar,tempo,volL,volR,loop--]]
  arg.scale2 = arg.scale2 or 24
  arg.scale = arg.scale or 24
  arg.shift = arg.shift or 0
  arg.shift2 = arg.shift2 or 0
  arg.gen = arg.gen or Gen.vR(1,1,100,1,1) 
  arg.gen2 = arg.gen2 or Gen.vR(1,1,100,1,1) 
  arg.speed = arg.speed or 120 --tempo
  arg.speed2 = arg.speed2 or arg.speed
  arg.R = arg.R or 0.2
  arg.L = arg.L or 0.2
  arg.lenght = arg.lenght or 1
  arg.every = arg.every or 1

  for q = 0, arg.lenght do
    for i = 0, arg.every do
      if i == arg.every then moont.rpattern(arg.pattern2,arg.scale2+q*(arg.shift2),
                                  arg.gen2,moont.t(arg.speed2),arg.R,arg.L,arg.disparity2,arg.pitch2) 
      elseif i < arg.every then moont.rpattern(arg.pattern,arg.scale+q*(arg.shift),
                                  arg.gen,moont.t(arg.speed),arg.R,arg.L,arg.disparity,arg.pitch)
      end
    end
  end
end

function moont.LSeq(v)
  v.pitch = v.pitch or tono
  v.disparity = v.disparity or 0
  v.dur = v.dur or 1/4
  v.scale = v.scale or 24
  v.gen = v.gen or Gen.vR(1,1,100,1,1)
  v.L = v.L or 0.5
  v.R = v.R or v.L
  do
    if type(bank[v.seq]) == "function" then bank[v.seq](v.dur)
      elseif type(bank[v.seq]) == "nil" then Gen.play(v.scale,v.gen,v.seq,v.dur,v.L/10,v.R/10,v.disparity)
      else soundPlay(bank[v.seq],v.L,v.R,v.disparity,v.pitch)
    end
  end
end

return moont
