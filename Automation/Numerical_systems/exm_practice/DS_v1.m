%% DS 2021-2022 - Engineering of Complex Systems
%https://www.perplexity.ai/search/matlab-code-for-tp1-clear-all-ufR__P2ZTX.ETX7TNPBKCQ

% Solution script based on TP1 techniques
clear all; close all; clc;

%% ========================================================================
%  EXERCISE 1: Identification and Control of Multivariable System
% ========================================================================
disp('--- Exercise 1 ---')

% 1. Least Squares Identification for 4 datasets (DATA1 to DATA4)
% System: 2 Inputs (u_vgt, u_egr), 2 Outputs (y_psural, y_debit)
% Note: Since we don't have the .mat files, we assume standard structure:
% y(k) + a1*y(k-1) + ... = b1*u(k-1) + ...
% We will write a generic function for this (see bottom of script).

% Simulation parameters (from text)
Te = 0.005; % Sampling period 5ms

% Placeholder for loop over datasets
datasets = {'DATA1', 'DATA2', 'DATA3', 'DATA4'};

for i = 1:length(datasets)
    fprintf('Processing %s...\n', datasets{i});
    
     % Load the generated data
    load(datasets{i}); 
    
    % Remove the mean (Operating Point) for identification
    % The transfer function relates variations (delta), not absolute values.
    u_vgt_var = u_vgt - mean(u_vgt(1:10));
    u_egr_var = u_egr - mean(u_egr(1:10));
    y_psural_var = y_psural - mean(y_psural(1:10));
    y_debit_var = y_debit - mean(y_debit(1:10));
    
    % Identify G11 (VGT -> Psural) using DATA1 or DATA3
    % (If the input didn't move, the identification will be singular, 
    % so we check for variance)
    if var(u_vgt_var) > 0.1
        [num11, den11] = my_least_squares(u_vgt_var, y_psural_var, 1);
        G11_z = tf(num11, den11, Te);
        G11_p = d2c(G11_z, 'tustin');
        disp('Identified G11:'); G11_p
    end

    % Identify G22 (EGR -> Debit) using DATA2 or DATA3
    if var(u_egr_var) > 0.1
        [num22, den22] = my_least_squares(u_egr_var, y_debit_var, 1);
        G22_z = tf(num22, den22, Te);
        G22_p = d2c(G22_z, 'tustin');
        disp('Identified G22:'); G22_p
    end
    % Identification of Transfer Functions (Least Squares)
    % We identify 4 TFs: G11, G12, G21, G22
    % Structure: First order assumed for simplicity (or 2nd based on plots)
    % y(k) = -a1*y(k-1) + b1*u(k-1)
    
    % Example for G_psural_vgt (Output 1, Input 1)
    [num11, den11] = my_least_squares(u_vgt, y_psural, 1); % Order 1
    G11_z = tf(num11, den11, Te);
    G11_p = d2c(G11_z, 'tustin'); % Continuous equivalent
    
    % Example for G_debit_egr (Output 2, Input 2)
    [num22, den22] = my_least_squares(u_egr, y_debit, 1);
    G22_z = tf(num22, den22, Te);
    G22_p = d2c(G22_z, 'tustin');
    
    % Display results for this dataset
    disp(['Identified G11(p) for ', datasets{i}, ':']);
    G11_p
end

% 2. Controller Design (Pole Placement)
% We choose the identified models from the last iteration (or specific one)
% Loop 1: y_debit_AIR -> u_egr (G22)
% Specs: Overshoot 5%, Trep = 0.256s

disp('--- Controller Design: Debit Air Loop ---')
epsilon = 0.05;         % 5% overshoot
tr_des = 0.256;         % Desired response time
xi = sqrt(log(epsilon)^2 / (pi^2 + log(epsilon)^2)); % Damping ~0.69
wn = 3 / (tr_des * xi); % Natural frequency approximation (tr ~ 3/(xi*wn))

% Desired Characteristic Polynomial: s^2 + 2*xi*wn*s + wn^2
desired_poly = [1, 2*xi*wn, wn^2];
disp('Desired Polynomial Coeffs:'); disp(desired_poly);

% If G22(p) = K / (1 + tau*p) -> Plant: b/(s+a)
% PI Controller: C(s) = Kp * (1 + 1/(Ti*s)) = Kp(Ti*s + 1)/(Ti*s)
% Closed Loop char eq: s(s+a) + Kp*b/Ti * (Ti*s + 1) = 0
% s^2 + (a + Kp*b)*s + (Kp*b/Ti) = 0
% Identification (Pole Placement):
% 2*xi*wn = a + Kp*b   => Solve for Kp
% wn^2 = Kp*b/Ti       => Solve for Ti

[num_sys, den_sys] = tfdata(G22_p, 'v');
b_sys = num_sys(end);   % Gain/Numerator term
a_sys = den_sys(end-1)/den_sys(end-1); % Normalized s term coeff usually 1
pole_sys = den_sys(end); % The 'a' in s+a

Kp_debit = (2*xi*wn - pole_sys) / b_sys;
Ti_debit = (Kp_debit * b_sys) / wn^2;
C_debit = Kp_debit * tf([Ti_debit 1], [Ti_debit 0]);

fprintf('Regulator Air: Kp = %.4f, Ti = %.4f\n', Kp_debit, Ti_debit);


% Loop 2: y_psural -> u_vgt (G11)
% Specs: Overshoot 5%, Trep = 0.1328s
disp('--- Controller Design: Psural Loop ---')
tr_des2 = 0.1328;
wn2 = 3 / (tr_des2 * xi);

[num_sys1, den_sys1] = tfdata(G11_p, 'v');
b_sys1 = num_sys1(end);
pole_sys1 = den_sys1(end);

Kp_psural = (2*xi*wn2 - pole_sys1) / b_sys1;
Ti_psural = (Kp_psural * b_sys1) / wn2^2;
C_psural = Kp_psural * tf([Ti_psural 1], [Ti_psural 0]);

fprintf('Regulator Psural: Kp = %.4f, Ti = %.4f\n', Kp_psural, Ti_psural);

% 3. Discrete Form of Regulators
C_debit_z = c2d(C_debit, Te, 'tustin');
C_psural_z = c2d(C_psural, Te, 'tustin');

disp('Discrete Controller (Air):'); C_debit_z
disp('Discrete Controller (Psural):'); C_psural_z

% 4. Recurrence Equations
% C(z) = U(z)/E(z) = (b0 + b1 z^-1) / (1 - z^-1)
% u(k) = u(k-1) + b0*e(k) + b1*e(k-1)
disp('Recurrence Equation Format: u(k) = u(k-1) + b0*e(k) + b1*e(k-1)');
[numC, denC] = tfdata(C_debit_z, 'v');
fprintf('For Air Loop: u(k) = %.4f*u(k-1) + %.4f*e(k) + %.4f*e(k-1)\n', ...
    -denC(2), numC(1), numC(2));


%% ========================================================================
%  EXERCISE 2: Digital Control with Nichols
% ========================================================================
disp(' '); disp('--- Exercise 2 ---');

% 1. Recurrence Equation of the System
% G(z) given in text (assumed form based on common exercises)
% Let's assume a generic 1st order G(z) = b1*z^-1 / (1 + a1*z^-1)
% The question asks for the equation from the symbolic form.
% y(k) = -a1*y(k-1) + b1*u(k-1)

% 2. Least Squares Identification with Te = 40ms
Te2 = 40e-3;
% load('Ex2_data.mat'); % Placeholder
% u_step = 10 * ones(N,1); 
% y_meas = ...;
% [num_id, den_id] = my_least_squares(u_step, y_meas, 1);

% Assume identification gives the following Continuous System (from text):
% G(p) = K / (1 + tau*p)
% Text implies G(p) = 20 / (1 + 0.1p) or similar. 
% Based on "G=2/(1+0.1p)" in TP1 and "20" in the garbled text:
G_p = tf(20, [0.1 1]); 
disp('Assumed Plant G(p) from identification:'); G_p

% Specs: Error=0, Damping=0.7, Trep < Open Loop
lambda = 0.7; % Damping

% 1. Nichols Plot of Open Loop
figure;
nichols(G_p);
hold on;
title('Nichols Plot: G(p)');
ngrid;

% 2. Calculate Controller Gain (Resonance Factor Q)
% The text asks to deduce gain Kp (Q factor logic).
% Tangency condition to M-circle (Iso-modulus).
% M = 1 / (2*lambda * sqrt(1 - lambda^2)); % Resonance peak formula
% However, for damping 0.7, there is effectively no resonance peak (>0dB).
% M_db = 20*log10(M);

% Alternative approach from TP1 code: Calculate contour
% We look for the gain Kp that shifts the curve to be tangent to the contour defined by damping.
% For lambda = 0.7, phase margin is approx 65-70 degrees.

% Discretize with Zero Order Hold (BOZ)
G_z_boz = c2d(G_p, Te2, 'zoh');

% Plot Nichols of G(z) or G(p)*B(p)
figure;
nichols(G_z_boz);
hold on;
ngrid;
title('Nichols: Discretized System (G + BOZ)');

% 3. Calculate Ti
% Text says: Ti = 1 / (omega_r) or derived from compensation.
% A common rule (Ziegler-Nichols or similar) or cancelling the pole.
% Pole is at -1/0.1 = -10. 
% Let's cancel the dominant pole: Ti = 0.1s.
Ti_calc = 0.1; 
disp(['Chosen Ti (Pole Compensation): ', num2str(Ti_calc)]);

% 4. Continuous Controller Transfer Function
% PI: C(p) = Kp * (1 + 1/(Ti*p))
% We need Kp. From Nichols, adjust Kp to meet damping/margin.
% Let's assume we found Kp = 0.5 (placeholder for visual inspection value)
Kp_calc = 0.5; % This would be found "By trial and error" on the plot
C_cont = Kp_calc * tf([Ti_calc 1], [Ti_calc 0]);
disp('Continuous Regulator:'); C_cont

% 5. Discrete Controller Transfer Function
C_disc = c2d(C_cont, Te2, 'tustin');
disp('Discrete Regulator:'); C_disc

% 6. Recurrence Equation
[numCD, denCD] = tfdata(C_disc, 'v');
fprintf('Controller Recurrence: u(k) = u(k-1) + %.4f*e(k) + %.4f*e(k-1)\n', ...
    numCD(1), numCD(2));

% 7. Validation (Step Response)
sys_cl = feedback(C_disc * G_z_boz, 1);
figure;
step(sys_cl);
title('Closed Loop Step Response (Discrete)');

%% ========================================================================
%  HELPER FUNCTION: Least Squares (First Order)
% ========================================================================
function [num, den] = my_least_squares(u, y, order)
    % Identifies y(k) + a1*y(k-1) = b1*u(k-1) (for order 1)
    % Inputs: u (input vector), y (output vector), order (1)
    
    N = length(y);
    
    % Construct Regressor Matrix Phi and Output Vector Y
    % Equation: y(k) = -a1*y(k-1) + b1*u(k-1)
    % Theta = [-a1; b1]
    
    Y_vec = y(2:end); % y(k) from 2 to N
    
    % Phi matrix: [ -y(k-1)  u(k-1) ]
    Phi = [-y(1:end-1), u(1:end-1)];
    
    % Least Squares Solution: Theta = inv(Phi'*Phi) * Phi' * Y
    Theta = (Phi' * Phi) \ (Phi' * Y_vec);
    
    a1 = Theta(1);
    b1 = Theta(2);
    
    % Discrete Transfer Function: G(z) = b1 / (z + a1)
    % Note: Matlab tf uses z^-1 powers in denominator [1 a1]
    num = [0 b1]; 
    den = [1 a1];
end
