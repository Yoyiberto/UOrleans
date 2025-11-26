%% DATA GENERATOR for DS_2021_2022
% This script generates synthetic data for the exam problem.
% System: 2 Inputs (VGT, EGR) -> 2 Outputs (Boost Pressure, Air Flow)
clear all; close all; clc;

% --- Simulation Parameters ---
Te = 0.005;             % Sampling time (5ms)
T_total = 10;           % Duration of experiment (seconds)
t = (0:Te:T_total)';    % Time vector
N = length(t);

% --- True System Definition (The "Engine") ---
% We define 4 continuous transfer functions:
% y1 (Psural) = G11*u1 + G12*u2
% y2 (Debit)  = G21*u1 + G22*u2

% G11: VGT -> Boost (Primary effect, positive gain, lag)
G11 = tf(4.5, [0.4 1]); 
% G12: EGR -> Boost (Disturbance, slight pressure drop when EGR opens)
G12 = tf(-1.2, [0.3 1]);
% G21: VGT -> Flow (Coupling, VGT closing restricts flow slightly or increases it)
G21 = tf(1.0, [0.5 1]); 
% G22: EGR -> Flow (Primary effect, EGR opens -> Fresh air flow drops significantly)
G22 = tf(-8.0, [0.2 1]); 

% Operating Points (Offsets)
u1_0 = 50;  % VGT %
u2_0 = 20;  % EGR %
y1_0 = 1100; % Base Boost (mbar)
y2_0 = 80;   % Base Flow (kg/h)

%% --- Generate DATA1: VGT Step (EGR Constant) ---
disp('Generating DATA1 (VGT Step)...');
u_vgt = u1_0 + 10 * (t > 2);      % Step at t=2s
u_egr = u2_0 * ones(N,1);         % Constant
noise1 = 0.5 * randn(N,1);        % Measurement noise
noise2 = 0.2 * randn(N,1);

% Simulate
y_psural_dyn = lsim(G11, u_vgt-u1_0, t) + lsim(G12, u_egr-u2_0, t);
y_debit_dyn  = lsim(G21, u_vgt-u1_0, t) + lsim(G22, u_egr-u2_0, t);

% Add offsets and noise
y_psural = y1_0 + y_psural_dyn + noise1;
y_debit  = y2_0 + y_debit_dyn + noise2;

% Save
save('DATA1.mat', 't', 'u_vgt', 'u_egr', 'y_psural', 'y_debit', 'Te');

%% --- Generate DATA2: EGR Step (VGT Constant) ---
disp('Generating DATA2 (EGR Step)...');
u_vgt = u1_0 * ones(N,1);
u_egr = u2_0 + 15 * (t > 3);      % Step at t=3s

y_psural_dyn = lsim(G11, u_vgt-u1_0, t) + lsim(G12, u_egr-u2_0, t);
y_debit_dyn  = lsim(G21, u_vgt-u1_0, t) + lsim(G22, u_egr-u2_0, t);

y_psural = y1_0 + y_psural_dyn + 0.5*randn(N,1);
y_debit  = y2_0 + y_debit_dyn + 0.2*randn(N,1);

save('DATA2.mat', 't', 'u_vgt', 'u_egr', 'y_psural', 'y_debit', 'Te');

%% --- Generate DATA3: Multi-Step (Both Active) ---
disp('Generating DATA3 (Both Active)...');
u_vgt = u1_0 + 10 * (t > 1 & t < 6);
u_egr = u2_0 + 10 * (t > 4);

y_psural_dyn = lsim(G11, u_vgt-u1_0, t) + lsim(G12, u_egr-u2_0, t);
y_debit_dyn  = lsim(G21, u_vgt-u1_0, t) + lsim(G22, u_egr-u2_0, t);

y_psural = y1_0 + y_psural_dyn + 0.5*randn(N,1);
y_debit  = y2_0 + y_debit_dyn + 0.2*randn(N,1);

save('DATA3.mat', 't', 'u_vgt', 'u_egr', 'y_psural', 'y_debit', 'Te');

%% --- Generate DATA4: PRBS / Random (Rich Excitation) ---
disp('Generating DATA4 (Random Excitation)...');
% Create random binary-like signals
u_vgt = u1_0 + 5 * sign(sin(2*pi*0.3*t) + sin(2*pi*0.7*t));
u_egr = u2_0 + 5 * sign(sin(2*pi*0.2*t + 1));

y_psural_dyn = lsim(G11, u_vgt-u1_0, t) + lsim(G12, u_egr-u2_0, t);
y_debit_dyn  = lsim(G21, u_vgt-u1_0, t) + lsim(G22, u_egr-u2_0, t);

y_psural = y1_0 + y_psural_dyn + 0.5*randn(N,1);
y_debit  = y2_0 + y_debit_dyn + 0.2*randn(N,1);

save('DATA4.mat', 't', 'u_vgt', 'u_egr', 'y_psural', 'y_debit', 'Te');

disp('Data generation complete. Files DATA1.mat to DATA4.mat created.');
