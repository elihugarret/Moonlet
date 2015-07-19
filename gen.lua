--Generators
--Elihu Garrett (2015)

local proAudio = require "proAudioRt"
local Gen = {}

if not proAudio.create() then os.exit() end

function Gen.play(tono,sample, pitch, duration, volumeL, volumeR,dis)
	if type(pitch) == "number" then pitch = pitch
    else pitch = pitch:byte(1,-1) 
  end 
  local scale = 2^(pitch/tono)
	local sound = proAudio.soundLoop(sample, volumeL, volumeR, dis, scale)
  proAudio.sleep(duration)
  proAudio.soundStop(sound or 0.1)
end

--Still under development
function Gen.playChord(tono, sample, pitch, duration, volumeL, volumeR, note1, note2)
  local scale = 2^(pitch/tono)
  local sound = proAudio.soundLoop(sample,volumeL, volumeR, 0, scale)
  local sound1 = proAudio.soundLoop(sample,volumeL, volumeR, 0, scale+note1)
  local sound2 = proAudio.soundLoop(sample,volumeL, volumeR, 0, scale+note2)
  proAudio.sleep(duration)
  proAudio.soundStop(sound)
  proAudio.soundStop(sound1)
  proAudio.soundStop(sound2)
end
---------------------------------------------
 
 --Sound generators
 function Gen.vS(freq, duration, sampleRate,f,m,r)
	local data = {}
	for i = 1,duration*sampleRate do
		data[i] = math.random((i*math.cos(math.sin(f)))*(freq/math.random(m,r))/sampleRate,-19) 
	end
	return proAudio.sampleFromMemory(data, sampleRate)
end

function Gen.vX(freq, duration, sampleRate,q,w)
	local data = {}
	for i = 1,duration*sampleRate do
		data[i] = math.tan( ((i*(math.pi*math.cosh(q)))*freq/sampleRate)*math.cos(w))
	end
	return proAudio.sampleFromMemory(data, sampleRate)
end

function Gen.vR(freq, duration, sampleRate,v)
	local data = {}
	for i = 1,duration*sampleRate do
		data[i] = math.cos( ((i*math.pi)*freq/sampleRate)*math.pi*v)
	end
	return proAudio.sampleFromMemory(data, sampleRate)
 end

function  Gen.vP(freq, duration , sampleRate)
  local data = {}
  for i = 1, duration*sampleRate do
    data[i] = math.atan2(-4,6)* (i*math.pi)*(freq/(sampleRate)*math.pi)
  end
  return proAudio.sampleFromMemory(data, sampleRate)
end

function Gen.vM (freq, duration, sampleRate,x,y,z)
  local data = {}
  for i = 1, duration*sampleRate do
    data[i] = math.tan(x*(math.cosh(math.pi,y)*(i*math.pi)*(freq/(sampleRate)*z)))
  end
  return proAudio.sampleFromMemory(data, sampleRate)
 end
 
 --Special oscillator 
 --Example: osc()%10 
function Gen.osc(freq, duration, sampleRate)
  freq = freq or 440
  duration = duration or 1
  sampleRate = sampleRate or 4100
  local data = {}
  for i = 1, duration*sampleRate do
    data[i] = math.cos((math.pi*freq/sampleRate)*math.pi)
  end
  return proAudio.sampleFromMemory(data, sampleRate)
 end
 

return Gen