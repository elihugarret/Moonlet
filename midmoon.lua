--Midi module
--Still on development

moont = require "moonlet"
midi = require "luamidi"


local midmoon = {}

local noteOn, noteOff = midi.noteOn, midi.noteOff
local tone = 1 --change this to 0.5 if you're on linux

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

function midmoon.midi_chord(m)
  m.port = m.port or 0
  m.ch = m.ch or 1
  m.vel = m.vel or 70
  m.dur = m.dur or 0
  if m.chord == "maj" then 
    noteOn(m.port,m.note,m.vel,m.ch)  
    noteOn(m.port,m.note+4,m.vel,m.ch)
    noteOn(m.port,m.note+7,m.vel,m.ch)
    moont.sleep(m.dur)
    noteOff(m.port,m.note,m.vel,m.ch)
    noteOff(m.port,m.note+4,m.vel,m.ch)
    noteOff(m.port,m.note+7,m.vel,m.ch)
  elseif m.chord == "min" then
    noteOn(m.port,m.note,m.vel,m.ch)  
    noteOn(m.port,m.note+3,m.vel,m.ch)
    noteOn(m.port,m.note+7,m.vel,m.ch)
    moont.sleep(m.dur)
    noteOff(m.port,m.note,m.vel,m.ch)
    noteOff(m.port,m.note+3,m.vel,m.ch)
    noteOff(m.port,m.note+7,m.vel,m.ch)
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


function midmoon.sek(foo)
  --list - a table
  --velNote - velocity of midi note
  --velChord - velocity of midi chord
  --channelNote - channel of midi note
  --channelChord - channel of midi chord
  --typeChord - major or minor chord
  foo.portNote = foo.portNote or 1
  foo.durNote = foo.durNote or 0.5
  foo.durChord = foo.durChord or 0.5
  foo.portChord = foo.portChord or 1
  foo.L = foo.L or 0.5
  foo.R = foo.R or foo.L
  foo.disparity = foo.disparity or 0
  foo.pitch = foo.pitch or tone
  
  for c,v in ipairs(foo.list) do
    if type(v) == "string" and tonumber(v) ~= nil then
      midmoon.play_midi(foo.portNote,v,foo.velNote,foo.channelNote,foo.durNote)
    elseif type(v) == "number" then
      midmoon.midi_chord{
        port = foo.portChord,
        chord = foo.typeChord,
        note = v,
        dur = foo.durChord,
        channel = foo.channelChord,
        vel = foo.velChord
      }
    else
      soundPlay(bank[v],foo.L,foo.R,foo.disparity,foo.pitch)
    end
  end
end

function midmoon.LSek(foo)
  --list - a table
  --velNote - velocity of midi note
  --velChord - velocity of midi chord
  --channelNote - channel of midi note
  --channelChord - channel of midi chord
  --typeChord - major or minor chord
  foo.portNote = foo.portNote or 1
  foo.durNote = foo.durNote or 0.5
  foo.durChord = foo.durChord or 0.5
  foo.portChord = foo.portChord or 1
  foo.L = foo.L or 0.5
  foo.R = foo.R or foo.L
  foo.disparity = foo.disparity or 0
  foo.pitch = foo.pitch or tone
  
  do
    if type(foo.seq) == "string" and tonumber(foo.seq) ~= nil then
       midmoon.midi_chord{
        port = foo.portChord,
        chord = foo.typeChord,
        note = foo.seq,
        dur = foo.durChord,
        channel = foo.channelChord,
        vel = foo.velChord
      }
    elseif type(foo.seq) == "number" then
      midmoon.play_midi(foo.portNote,foo.seq,foo.velNote,foo.channelNote,foo.durNote)
    else
      soundPlay(bank[foo.seq],foo.L,foo.R,foo.disparity,foo.pitch)
    end
  end
end
return midmoon
