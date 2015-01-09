--Moonlet
--Lua/MoonScript experimental modules for audio livecoding
--Written by Elihu Garret, Mexico,2015

require "gen"
require "allen"

math.randomseed(os.clock!)
export random = math.random --example a[random(#a)]
export sleep = proAudio.sleep

--locals
wrap = coroutine.wrap
yield = coroutine.yield
soundPlay = proAudio.soundPlay
fromFile = proAudio.sampleFromFile
insert = table.insert

--Load your samples

dir = "../Samples/"
kic = fromFile(dir.."kick.ogg")
sna = fromFile(dir.."snare.ogg")
ope = fromFile(dir.."openhat.ogg")
hat = fromFile(dir.."hat.ogg")
rob = fromFile(dir.."robot.ogg")
vel = fromFile(dir.."velcro.ogg")
iro = fromFile(dir.."iron.ogg")
exh = fromFile(dir.."exhale.ogg")
air = fromFile(dir.."air.ogg")
ice = fromFile(dir.."ice.ogg")
kit = fromFile(dir.."kitkick.ogg")
met = fromFile(dir.."metal.ogg")
tin = fromFile(dir.."tin.ogg")
tam = fromFile(dir.."tam.ogg")
mar = fromFile(dir.."mar.ogg")
cab = fromFile(dir.."cab.ogg")
req = fromFile(dir.."req.ogg")
pan = fromFile(dir.."pan.ogg")
woo = fromFile(dir.."woo.ogg")
snap = fromFile(dir.."sna.ogg")

bank =
 x: kic
 o: sna
 ['*']: hat
 ['-']: ope
 ['&']: rob
 ['#']: vel
 ['+']: iro
 ['$']: exh
 ['@']: air
 ['%']: ice
 ['~']: kit
 ['°']: met
 [';']: tin
 A: tam
 B: mar
 C: cab
 D: req
 E: pan
 F: woo
 G: snap
 [' ']: (dur) -> play(1,vR(1,1,1,1),1,dur,0,0)

--isTable
isTable = (t) -> type t == "table"

--each
each = (list,f,...) ->
 unless isTable list then return
 for index,value in pairs list
  f index,value,...
 return

--Relative tempo
export t = (bpm) ->
 x = 30/bpm
 x

--Like SC .clear
export clear = (time) ->
 destroy = proAudio.destroy
 sleep time
 destroy!
 os.exit!
 return

--Rotate a string.
export rotate = (s,n) ->
 local p
 if n>0
  p="("..string.rep("%S+",n,"%s+")..")".."(.-)$"
 else
  n=-n
  p="^(.-)%s+".."("..string.rep("%S+",n,"%s+").."%s*)$"
 
 return (s:gsub(p,"%2 %1"))

--Choose function (similar to .choose method in SuperCollider)
--Remember string(rand(#),9)
export choose = (...) ->
 local var = {...}
 return var[math.random(#var)]

-- .ogg player  [proAudioRt cant handle high quality .wav files]
export sample = (tipo) ->
 tipo.disparity = tipo.disparity or 0
 tipo.pitch = tipo.pitch or 0.5
 direc = "../Samples/Sounds/"
 samplef = fromFile(direc..tipo.file..".ogg")
 return soundPlay samplef,tipo.L,tipo.R,tipo.disparity,tipo.pitch
 

--Like choose() for "valid" characters
export choose2 = () ->
 samples = {'A','B','C','D','E','F','G','#','$','%','&','+','~','°','@',';'}
 choose = random #samples
 samples[choose]

--Shuffle
export shuffle = (list) ->
 shuffled = {}
 each(list,(index,value) ->
  randPos = math.floor(random!*index)+1
  shuffled[index] = shuffled[randPos]
  shuffled[randPos] = value
  return)
 shuffled

--Range
export range = (...) ->
 arg = {...}
 local start,stop,step
 switch #arg
  when 0
   return {}
  when 1
   stop,start,step = arg[1],0,1
  when 2
   start,stop,step = arg[1],arg[2],1
  when 3
   start,stop,step = arg[1],arg[2],arg[3]
 if (step and step == 0)
  return{}
 ranged = {}
 steps = math.max(math.floor((stop-start)/step),0)
 for i = 1, steps
  ranged[#ranged+1] = start+step*i
 if #ranged>0
  insert ranged,1,start
 ranged

--String to array of chars method
export sound = {}
string.sound = (var) =>
 tabla = {}
 for char in @gmatch '.'
  insert tabla,char
 var == 'r' and shuffle(tabla) or #tabla>0 and tabla or nil

--Sequencer
export rpattern = (patrones,tono,dino,temp,vol1,vol2,dis,pit) ->
 pit = pit or 0.5
 dis = dis or 0
 for i, v in ipairs patrones
  switch type bank[v]
   when "function"
    bank[v](temp)
   when "nil"
    play(tono,dino,v,temp,vol1/10,vol2/10,dis)
   else
    soundPlay(bank[v],vol1,vol2,dis,pit)
 return
--
export seq = {}
--Sequiencer + coroutines
seq.c = (var) ->
 var.scale = var.scale or 24
 var.scale2 = var.scale2 or 24
 var.gen = var.gen or vR(1,1,100,1,1)
 var.gen2 = var.gen2 or vR(1,1,100,1,1)
 var.speed = var.speed or 120
 var.speed2 = var.speed2 or var.speed 
 var.L = var.L or 0.2
 var.L2 = var.L2 or var.L
 var.R = var.R or 0.2
 var.R2 = var.R2 or var.R
 par = wrap((patrones,tono,dino,temp,vol1,vol2,dis,pit) ->
  while true
   rpattern(patrones,tono,dino,temp,vol1,vol2,dis,pit)
   yield!)
 arp =wrap((patrones,tono,dino,temp,vol1,vol2,dis,pit) ->
  while true
   rpattern(patrones,tono,dino,temp,vol1,vol2,dis,pit)
   yield!)
 local x
 if #var.pattern >= #var.pattern2
  x = #var.pattern
 else
  x = #var.pattern2
 for i = 1,x
  par(var.pattern,var.scale,var.gen,t(var.speed),var.L,var.R,var.disparity,var.pitch)
  arp(var.pattern2,var.scale2,var.gen2,t(var.speed2),var.L2,var.L2,var.disparity2,var.pitch2)
 return

--Non-linear sequencing
seq.d = (arg) ->
--[[lenght, every, variationPattern,shift1,dinoVar,tempo,volL,volR,loop--]]
 arg.scale2 = arg.scale2 or 24
 arg.scale = arg.scale or 24
 arg.shift = arg.shift or 0
 arg.shift2 = arg.shift2 or 0
 arg.gen = arg.gen or vR(1,1,100,1,1) 
 arg.gen2 = arg.gen2 or vR(1,1,100,1,1) 
 arg.speed = arg.speed or 120 --tempo
 arg.speed2 = arg.speed2 or arg.speed
 arg.R = arg.R or 0.2
 arg.L = arg.L or 0.2
 arg.lenght = arg.lenght or 1
 arg.every = arg.every or 1

 for q = 0, arg.lenght
  for i = 0, arg.every
   if i == arg.every
    rpattern(arg.pattern2,arg.scale2+q*(arg.shift2),arg.gen2,t(arg.speed2),arg.R,arg.L,arg.disparity2,arg.pitch2) 
   elseif i < arg.every
    rpattern(arg.pattern,arg.scale+q*(arg.shift),arg.gen,t(arg.speed),arg.R,arg.L,arg.disparity,arg.pitch)
 return

