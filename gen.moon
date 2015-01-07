--Generators
--Elihu Garrett 2015

require "proAudioRt"

unless proAudio.create! then os.exit!

export play = (tono,sample,pitch,duration,volumeL,volumeR,dis) ->
 if type(pitch) == "number"
  pitch = pitch
 else pitch = pitch\byte(1,-1)
 scale = 2^(pitch/tono)
 sound = proAudio.soundLoop(sample,volumeL,volumeR,dis,scale)
 proAudio.sleep(duration)
 proAudio.soundStop(sound or 0.1)
 return
--Still under development
export playChord = (tono,sample,pitch,duration,volumeL,volumeR,note1,note2) ->
 scale = 2^(pitch/tono)
 sound = proAudio.soundLoop(sample,volumeL,volumeR,0,scale)
 sound1 = proAudio.soundLoop(sample,volumeL,volumeR,0,scale+note1)
 sound2 = proAudio.soundLoop(sample,volumeL,volumeR,0,scale+note2)
 proAudio.sleep(duration)
 proAudio.soundStop(sound)
 proAudio.soundStop(sound1)
 proAudio.soundStop(sound2)
 return

--Sound generators

export vS = (freq,duration,sampleRate,f,m,r) ->
 data = {}
 for i = 1, duration*sampleRate
  data[i] = math.random((i*math.cos(math.sin(f)))*freq/math.random(m,r)/sampleRate,-19)
 return proAudio.sampleFromMemory(data,sampleRate)

export vX = (freq,duration,sampleRate,q,w) ->
 data = {}
 for i = 1,duration*sampleRate
  data[i] = math.tan(((i*(math.pi*math.cosh(q)))*freq/sampleRate)*math.cos(w))
 return proAudio.sampleFromMemory(data,sampleRate)

export vR = (freq,duration,sampleRate,v) ->
 data = {}
 for i = 1,duration*sampleRate
  data[i] = math.cos(((i*math.pi)*freq/sampleRate)*math.pi*v)
 return proAudio.sampleFromMemory(data,sampleRate)

export vP = (freq,duration,sampleRate) ->
 data = {}
 for i = 1,duration*sampleRate
  data[i] = math.atan2(-4,6)*(i*math.pi)*(freq/(sampleRate)*math.pi)
 return proAudio.sampleFromMemory(data,sampleRate)

export vM = (freq,duration,sampleRate,x,y,z) ->
 data = {}
 for i = 1,duration*sampleRate
  data[i] = math.tan(x*(math.cosh(math.pi,y)*(i*math.pi)*(freq/(sampleRate)*z)))
 return proAudio.sampleFromMemory(data,sampleRate)

--Special oscillator (solo... oscila)
--Example: osc!%10
export osc = (freq,duration,sampleRate) ->
 freq = freq or 440
 duration = duration or 1
 sampleRate = sampleRate or 4100
 data = {}
 for i = 1, duration*sampleRate
  data[i] = math.cos((math.pi*freq/sampleRate)*math.pi)
 return proAudio.sampleFromMemory(data,sampleRate)

