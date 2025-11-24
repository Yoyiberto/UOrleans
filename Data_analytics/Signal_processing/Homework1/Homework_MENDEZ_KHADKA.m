close all; clear ; clc;
% Sampling
%A  = 2; B  = 2; a  = 1.5; b  = 0.9; c  = 1.0; f0 = 2000;%Hz
A  = 1; B  = 2; a  = 2.5; b  = 0.9; c  = 1.0; f0 = 2000;%Hz
%A  = 1; B  = 2; a  = 2; b  = 0.9; c  = 1.0; f0 = 1000;%Hz

%A  = 1; B  = 2; a  = 2; b  = 0.9; c  = 1.0; f0 = 1000;%Hz
Fs     = 44100; % standard freq that works well here
Ts     = 1/Fs;
Tdur  = 2.0; % arbitrary in seconds
t = 0:Ts:Tdur-Ts;
N=length(t);

x = (A/pi) * sin( 2*pi*f0*(a*t.^2 + b*t + c) ) + (B/(3*pi)) * cos(2*pi*f0*t);

% Spectrum
S_w=fftshift(abs(fft(x)))/N;    % signal two side spectrum using fft
frequency=(0:N-1)*Fs/N-Fs/2;   % frequency vector for the abscisse axes 
figure, plot(frequency,S_w);
xlabel("Frequency Hz"); ylabel("Spectrum of window W(t)");  grid on 
%axis([-1 1 0 0.5])

%% Adding noise
sigma=1;
x_noisy=x+sigma*randn(size(x));
figure;
plot(t,x_noisy)
%%
S_x_noisy=fftshift(abs(fft(x_noisy)))/N;    % signal two side spectrum using fft 
frequency=(0:N-1)*Fs/N-Fs/2;   % frequency vector for the abscisse axes 
figure; plot(frequency,S_x_noisy);
xlabel("Frequency Hz"); ylabel("Spectrum of window W(t)");  grid on 
%% mean value (check)
mean_x = mean(x);
mean_x_noisy = mean(x_noisy);
fprintf('Mean(x)        = %.6f\n', mean_x);
fprintf('Mean(x_{noisy})= %.6f (should remain near zero with zero-mean noise)\n', mean_x_noisy);

%% autocorrelation
gamma_xx=xcorr(x)/length(t);
gamma_yy=xcorr(x_noisy)/length(t);
tau=(-length(t)+1:(length(t)-1))/Fs;
figure('Name','Autocorrelation between x and x_noisy');
plot(tau,gamma_xx)
hold on
plot(tau,gamma_yy)
axis([-0.0005 0.0005, -0.1 1.5])
hold off

%If A=0
x_0 = (0/pi) * sin( 2*pi*f0*(a*t.^2 + b*t + c) ) + (B/(3*pi)) * cos(2*pi*f0*t);
x_0_noisy=x_0+sigma*randn(size(x_0));
gamma_xx_0=xcorr(x_0)/length(t);
gamma_yy_0=xcorr(x_0_noisy)/length(t);
tau=(-length(t)+1:(length(t)-1))/Fs;
figure('Name','Autocorrelation considering A=0');
plot(tau,gamma_xx_0)
hold on
plot(tau,gamma_yy_0)
axis([-0.0005 0.0005, -0.1 1.5])
hold off
%% further
%figure('Name','Spectrogram','Color','w');
%spectrogram(x, win, nover, nfft_tf, Fs, 'yaxis');
%title('Spectrogram of x(t)');
win    = 1024;          % window length
nover  = win/2;         % overlap
nfft_t = 2048;          % FFT points

figure('Name','Spectrogram of x(t)');
spectrogram(x, win, nover, nfft_t, Fs, 'yaxis'); % time vs frequency
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram of x(t)');
colorbar;

emd(x)
vmd(x, 'NumIMF', 5)