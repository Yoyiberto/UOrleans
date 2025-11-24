%% Lab session: Nonstationary audio-like signal
clear; close all; clc;

%% Parameters (given)
A  = 1; B  = 2; a  = 2; b  = 0.9; c  = 1.0; f0 = 1000;%Hz

%% 1) Sampling condition (choose a standard audio sampling rate)
Fs_list = [16000, 22050, 44100];  % standard audio rates to try
Fs     = 44100;                   % pick one for the main processing
Ts     = 1/Fs;

% Instantaneous frequency of the first term: fi(t) = f0*(2*a*t + b)
% Its maximum over [0, Tdur] occurs at t = Tdur (since 2*a*t + b is increasing)
Tdur  = 2.0; % seconds (adjust if desired)
fi_max = f0 * (2*a*Tdur + b);     % Hz
f_cos  = f0;                      % second cosine has constant f0

% Nyquist requirement: Fs >= 2 * max(fi_max, f_cos)
Fs_min = 2 * max(fi_max, f_cos);

fprintf('Max instantaneous frequency = %.1f Hz\n', fi_max);
fprintf('Nyquist minimum Fs needed   = %.1f Hz\n', Fs_min);
for Fs_try = Fs_list
    ok = Fs_try >= Fs_min;
    fprintf('Fs = %-6d Hz -> %s\n', Fs_try, tern(ok,'OK','ALIASING RISK'));
end
if Fs < Fs_min
    warning('Chosen Fs=%.0f Hz is below Nyquist (%.0f Hz). Increase Fs.', Fs, Fs_min);
end

%% Time vector
t = 0:Ts:Tdur-Ts;
N = numel(t);

%% Define the signal x(t)
x = (A/pi) * sin( 2*pi*f0*(a*t.^2 + b*t + c) ) + (B/(3*pi)) * cos(2*pi*f0*t);

%% 2) Spectrum (magnitude and phase)
% Use zero-padded FFT for finer frequency grid
Nfft = 2^nextpow2(4*N);
X = fft(x, Nfft);
f = (0:Nfft-1)*(Fs/Nfft);

% One-sided spectrum
k = 1:floor(Nfft/2)+1;
f1 = f(k);
X1 = X(k)/N;  % amplitude normalization (so cos of amp C yields ~C/2 lines)

% Plot signal and spectrum
figure('Name','Signal and Spectrum','Color','w');
subplot(2,1,1);
plot(t, x, 'k'); grid on;
xlabel('Time (s)'); ylabel('x(t)');
title('Time-domain signal');

subplot(2,1,2);
plot(f1/1e3, 20*log10(abs(X1)+eps), 'b'); grid on;
xlim([0 20]); % 0-20 kHz view
xlabel('Frequency (kHz)'); ylabel('|X(f)| (dB)');
title('One-sided magnitude spectrum');

% Verify expected spectral features:
% - A chirp-like band from ~f0*b to ~f0*(2*a*Tdur+b)
fprintf('\nExpected chirp sweep: %.1f Hz to %.1f Hz\n', f0*b, fi_max);
fprintf('Constant tone at %.1f Hz (cos term)\n\n', f_cos);

%% 3) Add zero-mean Gaussian noise and study impact
SNR_dB = 10;  % desired SNR in dB (change to test)
x_power = bandpower(x, Fs, [0 Fs/2]);
noise_power = x_power / (10^(SNR_dB/10));
w = sqrt(noise_power) * randn(size(x));
x_noisy = x + w;

% Spectrum of noisy signal
Xn  = fft(x_noisy, Nfft);
Xn1 = Xn(k)/N;

figure('Name','Noisy signal vs clean','Color','w');
subplot(3,1,1);
plot(t, x_noisy, 'r'); grid on;
xlabel('Time (s)'); ylabel('x_{noisy}(t)');
title(sprintf('Noisy signal (SNR = %g dB)', SNR_dB));

subplot(3,1,2);
plot(f1/1e3, 20*log10(abs(X1)+eps), 'b', 'LineWidth',1); hold on;
plot(f1/1e3, 20*log10(abs(Xn1)+eps), 'r'); grid on;
xlim([0 20]);
xlabel('Frequency (kHz)'); ylabel('|X(f)| (dB)');
legend('Clean','Noisy'); title('Spectrum: clean vs noisy');

subplot(3,1,3);
pwelch(x_noisy, hamming(2048), 1024, 4096, Fs, 'onesided');
title('Welch PSD of noisy signal');

%% 4) Mean value
mean_x = mean(x);
mean_x_noisy = mean(x_noisy);
fprintf('Mean(x)        = %.6f\n', mean_x);
fprintf('Mean(x_{noisy})= %.6f (should remain near zero with zero-mean noise)\n', mean_x_noisy);

%% 5) Autocorrelation with and without noise
% Use unbiased xcorr and normalize to Rxx(0)=1 for comparison
[Rx,  lags]  = xcorr(x, 'unbiased');
[Rxn, ~]     = xcorr(x_noisy, 'unbiased');
lags_t = lags / Fs;

Rx  = Rx  / max(Rx);
Rxn = Rxn / max(Rxn);

figure('Name','Autocorrelation','Color','w');
plot(lags_t, Rx, 'b', 'LineWidth',1.2); hold on; grid on;
plot(lags_t, Rxn, 'r'); 
xlabel('Lag (s)'); ylabel('R_{xx}(\tau) (normalized)');
legend('Clean','Noisy');
title('Autocorrelation: with and without noise');

% What changes occur if A = 0? Demonstration
A0 = 0;
x_A0 = (A0/pi) * sin( 2*pi*f0*(a*t.^2 + b*t + c) ) + (B/(3*pi)) * cos(2*pi*f0*t);
[Rx_A0, lA0] = xcorr(x_A0, 'unbiased'); Rx_A0 = Rx_A0/max(Rx_A0);
figure('Name','Autocorr with A=0','Color','w');
plot(lA0/Fs, Rx_A0, 'm'); grid on;
xlabel('Lag (s)'); ylabel('R(\tau)'); title('Autocorrelation when A = 0');
% Explanation in comments:
% With A=0 only the stationary cosine at f0 remains, so Rxx becomes purely
% periodic with period 1/f0, unlike the chirp which spreads energy in time.

%% 6) Further exploration

% 6a) Spectrogram (time-frequency representation)
win = hamming(512);
nover = 384;
nfft_tf = 2048;
figure('Name','Spectrogram','Color','w');
spectrogram(x, win, nover, nfft_tf, Fs, 'yaxis');
title('Spectrogram of x(t)');
colormap turbo; colorbar;

% 6b) EMD (requires Signal Processing Toolbox R2019b+)
try
    imf = emd(x);
    figure('Name','EMD','Color','w');
    nIMF = size(imf,2);
    for k2=1:min(nIMF,5)
        subplot(min(nIMF,5)+1,1,k2);
        plot(t, imf(:,k2)); grid on; ylabel(sprintf('IMF %d',k2));
    end
    subplot(min(nIMF,5)+1,1,min(nIMF,5)+1);
    plot(t, x - sum(imf,2)', 'k'); grid on; ylabel('Residue'); xlabel('Time (s)');
    sgtitle('Empirical Mode Decomposition');
catch
    disp('EMD not available in this MATLAB install.');
end
%%
% 6c) VMD (requires VMD function/package if present)
% If you have VMD on path (e.g., vmd.m from the VMD toolbox), you can try:

try
    alpha = 2000; tau = 0; K = 3; DC = 0; init = 1; tol = 1e-7;
    [u, ~, ~] = VMD(x, alpha, tau, K, DC, init, tol);
    figure('Name','VMD','Color','w');
    for k3=1:K
        subplot(K,1,k3); plot(t, u(k3,:)); grid on; ylabel(sprintf('Mode %d',k3));
    end
    xlabel('Time (s)'); sgtitle('Variational Mode Decomposition');
catch
    disp('VMD function not found. Add VMD to MATLAB path to run this section.');
end


%% Helper: inline ternary function
function out = tern(cond, a, b)
if cond, out = a; else, out = b; end
end