% Excersice 1
delta=5;
Fs = 44100;
duration=30;
t = -duration/2: 1/Fs : duration/2-1/Fs;     % time vector for abscisse axes 
w=zeros(size(t));
for i=1:size(t,2)
    if (-delta<=t(i) && t(i)<=delta)
        w(i)=1;
    end
end
%fft(w)
plot(t,w)

N=length(t);
S_w=fftshift(abs(fft(w)))/N;    % compute the signal two side spectrum using fft (fast Fourier 
frequency=(0:N-1)*Fs/N-Fs/2;   % frequency vector for the abscisse axes 
figure; plot(frequency,S_w);
xlabel("Frequency Hz"); ylabel("Spectrum of window W(t)");  grid on 
axis([-1 1 0 0.5])
% Spectrum

% x signal
x = 3*sin(100*pi*t+pi/4);
N=length(t);
X_fft=fftshift(abs(fft(x)))/N;    % compute the signal two side spectrum using fft (fast Fourier 
frequency=(0:N-1)*Fs/N-Fs/2;   % frequency vector for the abscisse axes 
figure; plot(frequency,X_fft);
xlabel("Frequency Hz"); ylabel("Spectrum of window X_fft");  grid on 

%%
% User's original code
delta=1;
Fs = 44100;
duration=30;
t = -duration/2: 1/Fs : duration/2-1/Fs;     % time vector for abscisse axes
w=zeros(size(t));
for i=1:size(t,2)
    if (-delta<=t(i) && t(i)<=delta)
        w(i)=1;
    end
end
N=length(t);
frequency=(0:N-1)*Fs/N-Fs/2;   % frequency vector for the abscisse axes

figure('Name','w signal (square)');
plot(t,w);

% fft of w
S_w=fftshift(abs(fft(w)))/N;    % compute the signal two side spectrum using fft (fast Fourier 
figure('Name','fft of w'); plot(frequency,S_w);
xlabel("Frequency Hz"); ylabel("Spectrum of window W(t)");  grid on 
axis([-1 1 0 0.5])

% --- Continuation for Part 1 ---

% Let x(t) = 3sin(100*pi*t + pi/4).
x = 3*sin(100*pi*t + pi/4);

% Find the expression of the signal y(t) = x(t)w(t)
y = x .* w;

% Compute the Fourier Transforms (Spectra)
X_f = fftshift(abs(fft(x)))/N;
Y_f = fftshift(abs(fft(y)))/N;

% Plot on the same graph the spectra of signals x(t) and y(t).
figure('Name','spectra x(t) vs y(t)');
plot(frequency, X_f, 'b');
hold on;
plot(frequency, Y_f, 'r');
xlabel("Frequency (Hz)");
ylabel("Spectrum");
title("Spectra of x(t) and y(t)");
legend("Spectrum of x(t)", "Spectrum of y(t)");
grid on;
xlim([-100 100]); % Zoom in around the signal frequency
