--Midi module
--Still on development

moont = require "moonlet"
midi = require "luamidi"


local midmoon = {}

local noteOn, noteOff = midi.noteOn, midi.noteOff
local tone = 0.5 --change this to 1 if you're on linux

function midmoon.play_midi(port,note,vel,ch,dur)
  port = port or 0
  ch = ch or 1
  vel = vel or 70
  dur = dur or 0
  do
    noteOn(port,note,vel,ch)  
    moont.sleep(dur)
    noteOff(port,note,vel,ch)
  end
end

function midmoon.mpattern(patrones,temp,vol1,vol2,dis,pit,ch,vel,dur)
  pit = pit or tone
  dis = dis or 0
  for i, v in ipairs(patrones) do
    if type(bank[v]) == "function" then bank[v](temp)
      elseif type(bank[v]) == "nil" then midmoon.play_midi(1,v,vel,ch,dur)
      else soundPlay(bank[v],vol1,vol2,dis,pit)
    end  
  end
end

function midmoon.seq_midi(arg)
--[[lenght, every, variationPattern,shift1,dinoVar,tempo,volL,volR,loop--]]
  arg.speed = arg.speed or 120 --tempo
  arg.speed2 = arg.speed2 or arg.speed
  arg.R = arg.R or 0.2
  arg.L = arg.L or 0.2
  arg.lenght = arg.lenght or 1
  arg.every = arg.every or 1

  for q = 0, arg.lenght do
    for i = 0, arg.every do
      if i == arg.every then midmoon.mpattern(arg.pattern2,moont.t(arg.speed2),arg.R,arg.L,arg.disparity2,arg.pitch2,arg.channel,arg.vel2,arg.dur)
      elseif i < arg.every then midmoon.mpattern(arg.pattern,moont.t(arg.speed),arg.R,arg.L,arg.disparity,arg.pitch,arg.channel,arg.vel,arg.dur2)
      end
    end
  end
end

function midmoon.sec_midi(var)
  local x
  var.speed = var.speed or 120
  var.speed2 = var.speed2 or var.speed 
  var.L = var.L or 0.2
  var.L2 = var.L2 or var.L
  var.R = var.R or 0.2
  var.R2 = var.R2 or var.R
  
  local par = wrap(function (patrones,temp,vol1,vol2,dis,pit,ch,vel,dur)
    while true do
      pit = pit or tone
      dis = dis or 0
      for i, v in ipairs(patrones) do
        if type(bank[v]) == "function" then bank[v](temp)
          elseif type(bank[v]) == "nil" then midmoon.play_midi(1,v,vel,ch,dur)
          else soundPlay(bank[v],vol1,vol2,dis,pit)
        end
        yield()
      end    
    end
  end
)
  local arp = wrap(function (patrones,temp,vol1,vol2,dis,pit,ch,vel,dur)
    while true do
      pit = pit or tone
      dis = dis or 0
      for i, v in ipairs(patrones) do
        if type(bank[v]) == "function" then bank[v](temp)
          elseif type(bank[v]) == "nil" then midmoon.play_midi(1,v,vel,ch,dur)
          else soundPlay(bank[v],vol1,vol2,dis,pit)
        end
        yield()
      end    
    end
  end
)
  if #var.pattern >= #var.pattern2 then x = #var.pattern else x = #var.pattern2 end
  for i = 1,x do
    par(var.pattern,moont.t(var.speed),var.R,var.L,var.disparity,var.pitch,var.channel,var.vel,arg.dur)
    arp(var.pattern2,moont.t(var.speed2),var.R2,var.L2,var.disparity2,var.pitch2,var.channel,var.vel2,arg.dur)
  end
end

return midmoon
