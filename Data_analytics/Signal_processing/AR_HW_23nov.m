clear; clc; close all;

%% 1. Model Setup & Simulation
% Parameters
N = 1000;               % Number of samples
sigma = 1.5;            % Noise standard deviation (sigma)
sigma_sq = sigma^2;     % Noise variance (sigma^2)
p = 2;                  % Order of AR process

% True coefficients for the board model: y[n] = -sum(a_p * y[n-p]) + eps
% Let's use stable coefficients: a1 = -0.75, a2 = 0.1
% This corresponds to: y[n] = 0.75*y[n-1] - 0.1*y[n-2] + eps
a_true = [-0.75; 0.1]; 

% Generate Gaussian Noise
epsilon = sigma * randn(N, 1);

% Generate AR Process Data (Filter)
% Matlab's 'filter' uses a different sign convention: A(z)Y(z) = X(z)
% A(z) = 1 + a1*z^-1 + ... so we use [1, a_true']
y = filter(1, [1; a_true], epsilon);

% Discard first 100 samples to remove transient effects (burn-in)
y = y(101:end); 
N = length(y);

%% 2. Manual Derivation Implementation (MLE)
% The board derivation led to the Normal Equations: R * A_hat = -r
% Step 2a: Calculate Autocorrelations
% r_yy[k] = E[y[n]y[n-k]]

% Calculate sample autocorrelation for lags 0, 1, ..., p
r_yy = xcorr(y, p, 'biased'); 
% xcorr returns lags from -p to +p. Center is at index p+1 (lag 0)
center_idx = p + 1;

% Extract specific lags for R matrix and r vector
% R matrix contains lags |i-j| (Toeplitz structure)
% r vector contains lags 1, 2, ..., p

R_vals = r_yy(center_idx : center_idx + p - 1); % Lags 0 to p-1
r_vals = r_yy(center_idx + 1 : center_idx + p); % Lags 1 to p

% Construct R Matrix (Toeplitz)
R_matrix = toeplitz(R_vals);

% Construct r vector
r_vector = r_vals;

% Step 2b: Solve for A_hat
% Formula: A_hat = -inv(R) * r
a_mle_manual = -inv(R_matrix) * r_vector;

%% 3. Theoretical Validation (Fisher & CRB)
% Fisher Information J approx (N/sigma^2) * R
J = (N / sigma_sq) * R_matrix;

% Cramér-Rao Bound (CRB) = diagonal of J^-1
% CRB = (sigma^2 / N) * inv(R)
CRB_matrix = inv(J);
CRB_values = diag(CRB_matrix);

%% 4. Display Results
fprintf('--------------------------------------------------\n');
fprintf('Comparison of True vs. Estimated Coefficients\n');
fprintf('--------------------------------------------------\n');
fprintf('Parameter\tTrue\tMLE (Manual)\tDifference\tCRB (Std Dev)\n');
for i = 1:p
    fprintf('a_%d\t\t%5.2f\t%8.4f\t%8.4f\t%8.4f\n', ...
        i, a_true(i), a_mle_manual(i), abs(a_true(i) - a_mle_manual(i)), sqrt(CRB_values(i)));
end

fprintf('\nLog-Likelihood Validation:\n');
fprintf('Is the estimator close to true? %s\n', mat2str(abs(a_true - a_mle_manual) < 2*sqrt(CRB_values)));
