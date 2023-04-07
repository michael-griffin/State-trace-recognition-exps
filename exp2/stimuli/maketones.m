clear all
Fs = 8000;      %# Samples per second
toneFreq = 500;  %# Tone frequency, in Hertz
nSeconds = .6;   %# Duration of the sound
y = sin(linspace(0, nSeconds*toneFreq*2*pi, round(nSeconds*Fs)));
sound(y, Fs); 
wavwrite(y, Fs, 8, 'tone_500Hz.wav');