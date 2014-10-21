--Elihu Garrett (2013-2014)

require("proAudioRt")--motor de audio

if not proAudio.create() then os.exit(1) end

function play(tono,sample, pitch, duration, volumeL, volumeR)
	local scale = 2^(pitch/tono)
	local sound = proAudio.soundLoop(sample, volumeL, volumeR, 0, scale)
  proAudio.sleep(duration)
  proAudio.soundStop(sound or 0.1)
end

--Still under development
function playChord(tono, sample, pitch, duration, volumeL, volumeR, note1, note2)
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
 function sS(freq, duration, sampleRate,f,m,r)
	local data = {}
	for i = 1,duration*sampleRate do
		data[i] = math.random((i*math.cos(math.sin(f)))*(freq/math.random(m,r))/sampleRate,-19) 
	end
	return proAudio.sampleFromMemory(data, sampleRate)
end

function aX(freq, duration, sampleRate,q,w)
	local data = {}
	for i = 1,duration*sampleRate do
		data[i] = math.tan( ((i*(math.pi*math.cosh(q)))*freq/sampleRate)*math.cos(w))
	end
	return proAudio.sampleFromMemory(data, sampleRate)
end

function vR(freq, duration, sampleRate,v)
	local data = {}
	for i = 1,duration*sampleRate do
		data[i] = math.cos( ((i*math.pi)*freq/sampleRate)*math.pi*v)
	end
	return proAudio.sampleFromMemory(data, sampleRate)
 end

function pS (freq, duration , sampleRate)
  local data = {}
  for i = 1, duration*sampleRate do
    data[i] = math.atan2(-4,6)* (i*math.pi)*(freq/(sampleRate)*math.pi)
  end
  return proAudio.sampleFromMemory(data, sampleRate)
end

function mR (freq, duration, sampleRate,x,y,z)
  local data = {}
  for i = 1, duration*sampleRate do
    data[i] = math.tan(x*(math.cosh(math.pi,y)*(i*math.pi)*(freq/(sampleRate)*z)))
  end
  return proAudio.sampleFromMemory(data, sampleRate)
 end
 
 --Special oscillator 
 --Ex. osc()%10 
function osc(freq, duration, sampleRate)
  freq = freq or 440
  duration = duration or 1
  sampleRate = sampleRate or 4100
  local data = {}
  for i = 1, duration*sampleRate do
    data[i] = math.cos((math.pi*freq/sampleRate)*math.pi)
  end
  return proAudio.sampleFromMemory(data, sampleRate)
 end
