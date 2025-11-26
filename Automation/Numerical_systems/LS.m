%Least Squared method
% Measured step response samples (k = 1..10) at Ts = 1 s
s = [0, 0.52, 0.90, 1.20, 1.40, 1.55, 1.67, 1.73, 1.82, 1.86]';  % column

% Build regression for s(k+1) = -a*s(k) + b0
y = s(2:end);              % s(k+1)
Phi = [-s(1:end-1), ones(length(s)-1,1)];  % [-s(k), 1]

% Least-squares estimate [a; b0]
theta = Phi \ y;
a_hat  = theta(1);
b0_hat = theta(2);

fprintf('Estimated parameters:\n   a  = %.6f\n   b0 = %.6f\n', a_hat, b0_hat);

% Optional: form the discrete transfer function and check fit
Ts = 1;
Gz = tf(b0_hat, [1 a_hat], Ts);  % b0 / (z + a)
t = (0:length(s)-1)'*Ts;
[y_sim,~] = step(Gz, t(end)); y_sim = y_sim

%%
