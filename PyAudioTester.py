from scipy.io.wavfile import write
from numpy import linspace,sin,pi,int16,concatenate
from random import randint

def note(freq, len, amp=1, rate=44100):
	t = linspace(0,len,len*rate)
	data = sin(2*pi*freq*t)*amp
	return data.astype(int16) # two byte integers

# print type(note(440, 1, amp=10000))

tones = [] 

# tones.append(note(440.000,1,amp=10000))
# tones.append(note(493.883,1,amp=10000))
# tones.append(note(523.251,1,amp=10000))
# tones.append(note(587.330,1,amp=10000))
# tones.append(note(659.255,1,amp=10000))
# tones.append(note(698.456,1,amp=10000))
# tones.append(note(783.991,1,amp=10000))
# tones.append(note(880.000,1,amp=10000))

for i in range(50):
	tones.append(note(randint(12, 30)*50, 0.5, amp=10000))

# print tones

write('440hzAtone.wav',44100,concatenate(tones,axis=1)) # writing the sound to a file