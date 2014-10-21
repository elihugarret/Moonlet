--Holotype (Helix Version)

--Written by Elihu Garret 2013-2014
--Sequencers, pseudo-samplers and a lot of stuff.
require "microCode"
require "microTables"
require "allen-helix"
math.randomseed(os.clock())
rand = math.random

-- Tempo
function t(bpm)
  x=30/bpm
  return x
end

--Pan
function p(L,R)
    proAudio.volume(L,R)
end
--------------------------------------------------------------
--Wait function
function w(sec)
  proAudio.sleep(sec)
end

--Clear
function cl(time)
w(time)
proAudio.destroy()
os.exit()
end
----------------------------------------------------------------------------

--Load yor samples!!!!!
local dir = ""---- Your path!
local kic = proAudio.sampleFromFile(dir.."kick.ogg")
local sna = proAudio.sampleFromFile(dir.."snare.ogg") 
local ope = proAudio.sampleFromFile(dir.."openhat.ogg")
local hat = proAudio.sampleFromFile(dir.."hat.ogg")
local rob = proAudio.sampleFromFile(dir.."robot.ogg") 
local vel = proAudio.sampleFromFile(dir.."velcro.ogg")
local iro = proAudio.sampleFromFile(dir.."iron.ogg")
local exh = proAudio.sampleFromFile(dir.."exhale.ogg")
local air = proAudio.sampleFromFile(dir.."air.ogg")
local ice = proAudio.sampleFromFile(dir.."ice.ogg")
local kit = proAudio.sampleFromFile(dir.."kitkick.ogg")
local met = proAudio.sampleFromFile(dir.."metal.ogg")
local tin = proAudio.sampleFromFile(dir.."tin.ogg")
local tam = proAudio.sampleFromFile(dir.."tam.ogg")
local mar = proAudio.sampleFromFile(dir.."mar.ogg")
local cab = proAudio.sampleFromFile(dir.."cab.ogg")
local req = proAudio.sampleFromFile(dir.."req.ogg")
local pan = proAudio.sampleFromFile(dir.."pan.ogg")
local woo = proAudio.sampleFromFile(dir.."woo.ogg")
local snap = proAudio.sampleFromFile(dir.."sna.ogg")
-----------------------------------------------------------------------

--Drum machine 
function rpattern(patrones,i,tono,dino,dur,vol1,vol2,dis,pit)
    pit = pit or 0.5
 for w, beat in ipairs(patrones[i]) do
       if beat == 'x' then  proAudio.soundPlay(kic,vol1,vol2,dis,pit)
   elseif beat == 'o' then proAudio.soundPlay(sna,vol1,vol2,dis,pit)  
   elseif beat == '*' then proAudio.soundPlay(hat,vol1,vol2,dis,pit)
   elseif beat == '-' then proAudio.soundPlay(ope,vol1,vol2,dis,pit)
   elseif beat == '&' then proAudio.soundPlay(rob,vol1,vol2,dis,pit)
   elseif beat == '#' then proAudio.soundPlay(vel,vol1,vol2,dis,pit)
   elseif beat == '+' then proAudio.soundPlay(iro,vol1,vol2,dis,pit)
   elseif beat == '$' then proAudio.soundPlay(exh,vol1,vol2,dis,pit)
   elseif beat == '@' then proAudio.soundPlay(air,vol1,vol2,dis,pit)
   elseif beat == '%' then proAudio.soundPlay(ice,vol1,vol2,dis,pit)
   elseif beat == '~' then proAudio.soundPlay(kit,vol1,vol2,dis,pit)
   elseif beat == '°' then proAudio.soundPlay(met,vol1,vol2,dis,pit)
   elseif beat == ';' then proAudio.soundPlay(tin,vol1,vol2,dis,pit)
   elseif beat == 'A' then proAudio.soundPlay(tam,vol1,vol2,dis,pit)
   elseif beat == 'B' then proAudio.soundPlay(mar,vol1,vol2,dis,pit)
   elseif beat == 'C' then proAudio.soundPlay(cab,vol1,vol2,dis,pit)
   elseif beat == 'D' then proAudio.soundPlay(req,vol1,vol2,dis,pit)
   elseif beat == 'E' then proAudio.soundPlay(pan,vol1,vol2,dis,pit)
   elseif beat == 'F' then proAudio.soundPlay(woo,vol1,vol2,dis,pit)
   elseif beat == 'G' then proAudio.soundPlay(snap,vol1,vol2,dis,pit)
   elseif beat == ' ' then play(1,vR(1,1,1,1),1,dur,0,0)
   else play(tono,dino,beat:byte(1,-1),dur,vol1/10,vol2/10)
   end 
 end
end

----------------------------------------------------------------------------
r = {}
-----------------------------------------------------------------
-- Linear sequencing
function r:q(patrones,tono,dino,dur,vol1,vol2,dis,pit)
  dis = dis or 0
  pit = pit or 0.5
 rpattern(patrones,1,tono,dino,dur,vol1,vol2,dis,pit)
 end

---------------------------------------------------------------------------
-- A pure sampler
function r:p(tipo)
tipo.dis = tipo.dis or 0
tipo.pitch = tipo.pitch or 0.5 
local x
if tipo.t == 'w' then x = ".wav"
elseif tipo.t == 'o' then x = ".ogg"
end
local sample = proAudio.sampleFromFile(dir..tipo.s..x)
proAudio.soundPlay(sample,tipo.L,tipo.R,tipo.dis,tipo.pitch)
end
----------------------------------------------------------------------------
-- Loop
function loop(z,volL,volR,dis,pitch)
 dis = dis or 0
 pitch = pitch or 0.5
 sound = proAudio.sampleFromFile(dir..z..".ogg")
 sonido = proAudio.soundLoop(sound, volL, volR, dis, pitch) 
 end
----------------------------------------------------------------------------
--Non-linear sequencing
function def(arg)
--[[lenght, every, variationPattern,shift1,dinoVar,tempo,volL,volR,loop--]]
arg.c = arg.c or 24 --scale2
arg.s = arg.s or 24 --scale1
arg.h = arg.h or 0 --shift1
arg.i = arg.i or 0 -- shift2
arg.u = arg.u or vR(1,1,100,1,1) --ugen
arg.g = arg.g or vR(1,1,100,1,1) --ugenVar
arg.T = arg.T or 120 --tempo
arg.R = arg.R or 0.2
arg.L = arg.L or 0.2
arg.pitP = arg.pitP or 0.5
arg.pitV = arg.pitV or 0.5

for q = 0, arg.l do
    for i = 0, arg.e do
  if i == arg.e then r:q({arg.P},arg.c+q*(arg.h),
                                    arg.g,t(arg.T),arg.R,arg.L,arg.disP,arg.pitP) 
     elseif i < arg.e then r:q({arg.V},arg.s+q*(arg.i),
                                arg.u,t(arg.T),arg.R,arg.L,arg.disV,arg.pitV)
      end
    end
  end
end
--------------------------------------------------------------------
--Non-linear sampler
function defP(u)
  u.L = u.L or 0.2
  u.R = u.R or 0.2
  u.W = u.W or 0.5 --wait1
  u.A = u.A or 0.5 --wait2
  u.h = u.h or 0 --shift1
  u.i = u.i or 0 --shift2
  u.I = u.I or 0.5 --pitch1
  u.C = u.C or 0.5 --pitch2
  u.D = u.D or 0 --disparity
  u.S = u.S or 0 --disparity2
  
  for o = 0, u.l do
      for m = 0, u.e do
            if m == u.e then r:p(u.y--[[formato]],u.N--[[nombre]],u.L,u.R,u.D,u.I+(o*u.h/10))
        w(u.W)
      elseif m < u.e then r:p(u.y,u.N,u.L,u.R,u.S,u.C+(o*u.i/10))
       w(u.A)
      end
       end
     end
  end
----------------------------------------------------------------------------

--a[rand(#a))] usage example
function chos()
 local samples = {'A','B','C','D','E','F','G','#','$','%','&','+','~','°','@',';'}
 local choose = math.random(#samples)
 return samples[choose] 
end
----------------------------------------------------------------------------
--Random String Generator/Concatenator by Elihu Garret 2014
 function RSG(str,pattern,s, l)
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
----------------------------------------
