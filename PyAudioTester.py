from scipy.io.wavfile import write
from numpy import linspace,sin,pi,int16,concatenate
from random import randint

def note(freq, len, amp=1, rate=44100):
	t = linspace(0,len,len*rate)
	data = sin(2*pi*freq*t)*amp
	return data.astype(int16) # two byte integers

bits = 16
low, high = 900, 1600
diff = (high - low) / (bits - 1)
duration = 0.25
TEXT = 4
URL = 7
PIC = 10
amp = 10000

def send_data(data, name, typee):
	tones = [] 
	tones.append(note(low, duration * 4, amp))
	tones.append(note(high, duration * 4, amp))
	tones.append(note(low, duration, amp))
	tones.append(note(low + typee * diff, duration, amp))
	for i in data:
		tones.append(note(low + i * diff, duration, amp))
	write(name + ".wav", 44100,concatenate(tones,axis=1)) # writing the sound to a file

def send_text(string, name):
	str_length = len(string)
	data = [str_length & 0xF, (str_length & 0xF0) >> 4]
	for ch in string:
		data += [ord(ch) & 0xF, (ord(ch) & 0xF0) >> 4]
	print data
	# check_adjacent(data)
	send_data(data, name, TEXT)

def send_url(string, name):
	str_length = len(string)
	data = []
	for ch in string:
		data += [int(ch, 16)]
	print data
	# check_adjacent(data)
	send_data(data, name, URL)


def send_pic(string, name):
	str_length = len(string)
	data = []
	for ch in string:
		data += [int(ch, 16)]
	print data
	# check_adjacent(data)
	send_data(data, name, PIC)

def check_adjacent(lst):
	cache = lst[0];
	for i in lst[1:]:
		if i == cache:
			raise ValueError("Adjacent bits not allowed in beta.")
		else:
			cache = i


# tones.append(note(440.000,1,amp=10000))
# tones.append(note(493.883,1,amp=10000))
# tones.append(note(523.251,1,amp=10000))
# tones.append(note(587.330,1,amp=10000))
# tones.append(note(659.255,1,amp=10000))
# tones.append(note(698.456,1,amp=10000))
# tones.append(note(783.991,1,amp=10000))
# tones.append(note(880.000,1,amp=10000))

# for i in range(16):
# 	write(str(i) + ".wav", 44100, note(low + i * diff, duration, amp))

# print tones

# send_data([8, 3 ,2, 3 ,1 ,0, 8, 9, 2, 0, 9, 8], "all", text)
# send_data([i for i in range(0, 16)]+[8, 3 ,2, 8, 3, 1, 8, 8, 8, 8, 0, 8, 8, 8, 9, 2, 0, 9, 8, 8, 8], "all", text)
send_pic("279c231", "doge")


