%% Part I: Zero Order Hold Approximation
clc; clear; close all;

% 1. Define System and Sampling Time
Te = 0.01; % Sampling period 0.01s
s = tf('s');
G_p = 2 / (1 + 0.1*s);

% Compute sampled transfer function G(z) using c2d (ZOH)
G_z = c2d(G_p, Te, 'zoh');

disp('Discretized Transfer Function G(z):');
display(G_z);

% 3 & 4. Frequency Domain Analysis
w = logspace(-1, 4, 1000); % Frequency vector

% Frequency response of G(z)
[mag_z, phase_z] = bode(G_z, w);
mag_z = squeeze(mag_z); phase_z = squeeze(phase_z);

% Frequency response of G(jw) * B(jw)
% Note: B(jw) = (1-exp(-j*w*Te)) ./ (j*w)
% We calculate the response manually for the combination
jw = 1j * w;
B_jw = (1 - exp(-jw*Te)) ./ (jw);
[mag_p, phase_p] = bode(G_p, w);
mag_p = squeeze(mag_p); phase_p = squeeze(phase_p);

% Combined response G(jw)B(jw)
% Note: B(jw) gain is roughly Te at low freq, while G(z) implies the mapping. 
% Often we compare G(z) directly to G(p) to see aliasing/warping, 
% but here we follow the instruction to plot G(p)*B(p).
total_resp = freqresp(G_p, w) .* reshape(B_jw, [1 1 length(w)]);
mag_tot = abs(squeeze(total_resp));
phase_tot = angle(squeeze(total_resp)) * 180/pi;

% Plotting Bode Comparison
figure;
subplot(2,1,1);
semilogx(w, 20*log10(mag_z), 'b', 'LineWidth', 1.5); hold on;
semilogx(w, 20*log10(mag_tot), 'r--', 'LineWidth', 1.5);
title('Bode Magnitude Comparison'); legend('G(z)', 'G(jw)B(jw)'); grid on;

subplot(2,1,2);
semilogx(w, phase_z, 'b', 'LineWidth', 1.5); hold on;
semilogx(w, phase_tot, 'r--', 'LineWidth', 1.5);
title('Bode Phase Comparison'); legend('G(z)', 'G(jw)B(jw)'); grid on;

% Plotting Nichols Comparison
figure;
plot(phase_z, 20*log10(mag_z), 'b', 'LineWidth', 1.5); hold on;
plot(phase_tot, 20*log10(mag_tot), 'r--', 'LineWidth', 1.5);
title('Nichols Chart Comparison'); legend('G(z)', 'G(jw)B(jw)'); grid on;
xlabel('Phase (deg)'); ylabel('Magnitude (dB)');

% 5. Manual Calculation (Display logic)
% G(p)/p = 2 / (p(1+0.1p)) = 20 / (p(p+10)) = 2/p - 2/(p+10)
% Z-transform: 2*z/(z-1) - 2*z/(z - exp(-10*Te))
% Multiply by (1-z^-1) = (z-1)/z to get final G(z).
% Result: 2 * [ 1 - (z-1)/(z-exp(-10*Te)) ] ... simplifies to matched pole-zero result.
pole_exact = exp(-10*Te);
num_exact = 2 * (1 - pole_exact);
disp('Manual Calculation coefficients check:');
fprintf('Pole: %.4f (Expected: %.4f)\n', pole(G_z), pole_exact);

%% Part II: Numerical Controller Definitions
Te = 0.01; 

% 2. Transfer Functions for Integrators
H_forward = tf([0 Te], [1 -1], Te);
H_backward = tf([Te 0], [1 -1], Te);
H_trapezoidal = tf([Te/2 Te/2], [1 -1], Te);

disp('Integrator Transfer Functions:');
disp('Forward:'); display(H_forward);
disp('Backward:'); display(H_backward);
disp('Trapezoidal:'); display(H_trapezoidal);

% 3. Differentiator
H_diff = tf([1 -1], [Te 0], Te);
disp('Differentiator Transfer Function:'); display(H_diff);
%% Part III: Controller Design
% 1. Choose Sampling Period
Te = 0.01; % Selected to be << time constant (0.1s)

% 2 & 4. Nichols Plot of Open Loop (G(p)*B(p) equivalent or G(z))
% Design is typically done on the discretized plant G(z)
figure;
nichols(G_z); 
hold on;
grid on;

% 5. Calculate Iso-contour Q (Resonance Peak Mp)
xi = 0.6;
Mp = 1 / (2 * xi * sqrt(1 - xi^2)); % Resonance peak linear magnitude
Mp_dB = 20*log10(Mp);

disp(['Target Resonance Peak Mp: ', num2str(Mp), ' (', num2str(Mp_dB), ' dB)']);

% Draw M-circle for this Mp on Nichols chart (Approximation for visualization)
ngrid; % Adds M-circles to the plot
% Locate the curve for 0.35dB. It is very close to 0dB.

% 6. Find Proportional Gain Kp
% We need to shift the Nichols curve vertically until it touches the M-circle.
% Using 'margin' or trial and error. 
% Since Mp is small (system is well damped), we might just need to check phase margin.
% For xi=0.6, Phase Margin ~ 60 degrees.

% Let's iterate to find Kp that gives the specific Mp in closed loop
K_range = 0.1:0.1:10;
best_Kp = 1;
min_diff = 1e6;

for k = K_range
    CL_test = feedback(k*G_z, 1);
    [mag_test, ~] = bode(CL_test);
    peak_mag = max(mag_test);
    
    if abs(peak_mag - Mp) < min_diff
        min_diff = abs(peak_mag - Mp);
        best_Kp = k;
    end
end

fprintf('Determined Proportional Gain Kp: %.2f\n', best_Kp);

% Update plot with Kp
nichols(best_Kp * G_z);
legend('Original', 'With Kp');

% 7. Resonance and Natural Frequency
CL_system = feedback(best_Kp * G_z, 1);
[mag_cl, phase_cl, w_cl] = bode(CL_system);
[peak, idx] = max(mag_cl);
wr = w_cl(idx); % Resonance frequency
wn = wr / sqrt(1 - 2*xi^2); % Relation between wr and wn

fprintf('Resonance Frequency wr: %.2f rad/s\n', wr);
fprintf('Natural Frequency wn: %.2f rad/s\n', wn);

% 8. Calculate Ti
% Formula in text is garbled: "Ti = 10 / wn" (assumed based on visual).
% Adjust the constant '10' if the PDF indicates a different number clearly.
Ti = 10 / wn; 
fprintf('Calculated Ti: %.4f s\n', Ti);

% 9. Continuous Controller TF (PI)
% C(s) = Kp * (1 + 1/(Ti*s))
Cont_Controller = best_Kp * tf([Ti 1], [Ti 0]);
disp('Continuous Controller C(s):'); display(Cont_Controller);

% 10. Digital Controller TF
% Discretize C(s) using Trapezoidal (Tustin) for better controller fidelity
Dig_Controller = c2d(Cont_Controller, Te, 'tustin');
disp('Digital Controller C(z):'); display(Dig_Controller);

% 11. Recursive Equation
% Extract numerator and denominator of Dig_Controller
[num, den] = tfdata(Dig_Controller, 'v');
% U(z)/E(z) = (b0 + b1 z^-1) / (1 + a1 z^-1)
% u(k) = -a1*u(k-1) + b0*e(k) + b1*e(k-1)
fprintf('Recursive Equation:\n');
fprintf('u(k) = %.4f * u(k-1) + %.4f * e(k) + %.4f * e(k-1)\n', ...
    -den(2), num(1), num(2));

% 12. Validation
% Plot Step Response
figure;
step(feedback(Dig_Controller * G_z, 1));
title('Closed Loop Step Response with Digital PI');
grid on;

%% Corrected Comparison of G(z) and G(jw)*B(jw)
clc; clear; close all;

% 1. System Definition
Te = 0.01;             % Sampling time
s = tf('s');
G_p = 2 / (1 + 0.1*s); % Continuous Plant

% 2. Discrete Function
G_z = c2d(G_p, Te, 'zoh');

% 3. Define Frequency Range (Up to Nyquist only)
Nyquist_freq = pi / Te; 
w = logspace(-1, log10(Nyquist_freq), 1000); % Log scale up to ~314 rad/s

% 4. Calculate Responses
% -- Discrete Response G(z) --
[mag_z, phase_z] = bode(G_z, w);
mag_z = squeeze(mag_z); 
phase_z = squeeze(phase_z);

% -- Continuous Response G(jw) * B(jw) --
jw = 1j * w;
% B(jw) formula: (1 - exp(-sTe)) / s
B_jw = (1 - exp(-jw*Te)) ./ (jw);

% IMPORTANT: Normalize B(jw) by (1/Te) so gains match G(z)
B_jw_normalized = B_jw * (1/Te); 

% Get G(p) frequency response
resp_G_p = freqresp(G_p, w);
resp_G_p = squeeze(resp_G_p);

% Combine: Total = G(p) * B_normalized
resp_total = resp_G_p .* B_jw_normalized.'; % (.' ensures dimensions match)

mag_tot = abs(resp_total);
phase_tot = angle(resp_total) * 180/pi;

%% Plot 1: Bode Comparison
figure('Name', 'Bode Comparison Corrected');

% Magnitude
subplot(2,1,1);
semilogx(w, 20*log10(mag_z), 'b', 'LineWidth', 1.5); hold on;
semilogx(w, 20*log10(mag_tot), 'r--', 'LineWidth', 1.5);
grid on;
title('Bode Magnitude Comparison');
xlabel('Frequency (rad/s)'); ylabel('Magnitude (dB)');
legend('G(z)', 'G(j\omega)B(j\omega)/T_e');
xlim([0.1, Nyquist_freq]); % Limit x-axis

% Phase
subplot(2,1,2);
semilogx(w, phase_z, 'b', 'LineWidth', 1.5); hold on;
semilogx(w, phase_tot, 'r--', 'LineWidth', 1.5);
grid on;
title('Bode Phase Comparison');
xlabel('Frequency (rad/s)'); ylabel('Phase (deg)');
legend('G(z)', 'G(j\omega)B(j\omega)/T_e');
xlim([0.1, Nyquist_freq]);

%% Plot 2: Nichols Comparison
figure('Name', 'Nichols Comparison Corrected');
plot(phase_z, 20*log10(mag_z), 'b', 'LineWidth', 1.5); hold on;
plot(phase_tot, 20*log10(mag_tot), 'r--', 'LineWidth', 1.5);
grid on;
title('Nichols Chart Comparison');
xlabel('Phase (deg)'); ylabel('Magnitude (dB)');
legend('G(z)', 'G(j\omega)B(j\omega)/T_e', 'Location', 'SouthWest');
