duration=100;%s
Fs=100;
f0=1;
time = 0: 1/Fs : duration-1/Fs;     % time vector for abscisse axes 
A=1;  % amplitude 1V 
signal = A*square(2*pi*f0*time);   

%sq_wave=square(t,50)*0.5+0.5;
figure(1)
plot(time,signal);
axis([0 10 -1.5 1.5])

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

%% Fourier kinda manual
S_=0;
for k=1:100:2
    S_=S_+(A/k)*sin(2*pi*f0*time);
    axis([0 10 -1.5 1.5])
end
figure(3)
plot(time, S_)
%% Fourier
syms t n
T = 1/f0;  % period
omega0 = 2*pi*f0;  % fundamental frequency

% Define the symbolic square wave (odd function)
% Square wave from -T/2 to T/2
f(t) = piecewise(-T/2 <= t < 0, -A, 0 <= t < T/2, A);

% Compute Fourier coefficients
a0 = (1/T) * int(f(t), t, -T/2, T/2);  % DC component
an = (2/T) * int(f(t)*cos(n*omega0*t), t, -T/2, T/2);  % cosine coefficients
bn = (2/T) * int(f(t)*sin(n*omega0*t), t, -T/2, T/2);  % sine coefficients

% Simplify
a0 = simplify(a0)
an = simplify(an)
bn = simplify(bn)

% Build partial sum (first N terms)
N = 10;  % number of harmonics
fourier_series = a0/2;
for k = 1:N
    ak = subs(an, n, k);
    bk = subs(bn, n, k);
    fourier_series = fourier_series + ak*cos(k*omega0*t) + bk*sin(k*omega0*t);
end

% Plot comparison
t_vals = linspace(0, 2*T, 1000);
original = A*square(2*pi*f0*t_vals);
approx = double(subs(fourier_series, t, t_vals));

figure(3)
plot(t_vals, original, 'b', t_vals, approx, 'r--', 'LineWidth', 1.5);
legend('Original', 'Fourier Series');

%%
G=abs(sin(2*pi*f0*time));
figure(4)
plot(time,G)
axis([0 10 -1.5 1.5])