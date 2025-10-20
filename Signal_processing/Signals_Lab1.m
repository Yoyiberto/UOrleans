Fs = 44100;              % Sampling frequency for digital signal
duration = 5;              % Duration in seconds
f0 = 440;                  % Frequency of the pure tone

% Create the time vector and the signal
time = 0:1/Fs:duration-1/Fs; % time vector for abscissa axes
A = 1;                       % amplitude 1V
signal = A*sin(2*pi*f0*time);  % Pure tone signal

% Play the sound (optional, uncomment to hear it)
% sound(signal, Fs);

% --- Plotting in the Time Domain ---
figure(1);
% FIX: The variable was named 'time', not 't'.
plot(time, signal);
xlabel('Time (sec)');
ylabel('Amplitude');
title('Signal in Time Domain');
grid on;

% Save the audio file (optional, uncomment to save)
% audiowrite('diapason_440Hz.wav', signal, Fs);

% --- Spectrum Analysis ---
% FIX: Define N as the length of the signal before using it.
N = length(signal);

% Compute the two-sided spectrum using the Fast Fourier Transform (FFT)
S = fftshift(abs(fft(signal))) / N;

% Create the frequency vector for the x-axis
frequency = (-N/2:N/2-1)*(Fs/N);

% --- Plotting in the Frequency Domain ---
figure(2);
plot(frequency, S);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Signal Spectrum');
grid on;