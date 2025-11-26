%% EXERCISE 4 – Digital control design in MATLAB
clear; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Continuous‑time plant:  G(p) = 2 / (1 + 0.1 p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = tf('p');                    % Laplace variable (MATLAB uses 's' or 'p')
G = 2/(1 + 0.1*s);              % plant

% ---- User choice: sampling time and pulsation for design ----
Te = 0.05;                      % sampling period [s], choose as needed
wr = 10;                        % rad/s (example value, adapt if given)

disp('Continuous‑time plant G(p):');
G

%% 1. Digital transfer function of the system (zero‑order hold)
Gd = c2d(G, Te, 'zoh');

disp('Digital plant G(z):');
Gd

%% 2. Bode/Black‑Nichols like plot of continuous plant
figure;
margin(G);                      % gives Bode with gain/phase margins
grid on;
title('Continuous‑time plant G(p)');

% (If you specifically want Nichols:)
% figure;
% nichols(G); grid on;
% title('Nichols chart of G(p)');

%% 3. Proportional gain from damping (resonance factor)
lambda = 0.42;                  % required closed‑loop damping factor
Q = 1/(2*lambda*sqrt(1-lambda^2));

% To use the given formula we evaluate open‑loop gain & phase at wr
[mag, phase] = bode(G, wr);     % |G(j*wr)| and phase φ in deg
Gwr = squeeze(mag);             % magnitude (scalar)
phi = deg2rad(squeeze(phase));  % phase in rad

% Formula:  Q^2 = (K*G)^2 / (1 + 2*K*G*cos(phi) + (K*G)^2)
% Let x = K*Gwr  =>  Q^2 = x^2 / (1 + 2*x*cos(phi) + x^2)
% Solve for x, then Kp = x / Gwr

syms x real
eq = Q^2 == x^2/(1 + 2*x*cos(phi) + x^2);
solx = double(solve(eq, x));    % two solutions, choose positive one
x_pos = max(solx);              % positive solution
Kp = x_pos / Gwr;               % proportional gain

fprintf('Resonance Q = %.3f,  Kp = %.3f\n', Q, Kp);

%% 4. Ti chosen as Ti = 5 / wr
Ti = 5/wr;
fprintf('Integral time Ti = %.3f s\n', Ti);

%% 5. Transfer function of the continuous PI controller
C = Kp * (1 + 1/(Ti*s));

disp('Continuous PI controller C(p):');
C

%% 6. Digital controller transfer function
% We discretize the PI controller with Tustin (bilinear) by default.
Cd = c2d(C, Te, 'tustin');

disp('Digital controller C(z):');
Cd

%% 7. Recursive (difference‑equation) form of the controller
% C(z) = (b0 + b1 z^-1 + ...)/(1 + a1 z^-1 + ...)
[numCz, denCz] = tfdata(Cd, 'v');   % numerator and denominator vectors

% Controller difference equation:
% y[k] = -a1*y[k-1] - a2*y[k-2] ... + b0*u[k] + b1*u[k-1] + ...
% where y = controller output, u = error input

disp('Digital PI controller coefficients:');
fprintf('Numerator (b): '); disp(numCz);
fprintf('Denominator (a): '); disp(denCz);

fprintf('\nDifference equation (controller output u_c[k]):\n');
for i = 2:length(denCz)
    fprintf('  - a%d * u_c[k-%d]\n', i-1, i-1);
end
for i = 1:length(numCz)
    fprintf('  + b%d * e[k-%d]\n', i-1, i-1);
end

%% 8. Closed‑loop validation in Simulink / MATLAB

% In MATLAB (no Simulink) we can quickly check step response:
T_cl = feedback(C*G, 1);    % continuous‑time closed loop
T_cl_d = feedback(Cd*Gd, 1);

figure;
step(T_cl, 'b', T_cl_d, 'r--');
legend('Continuous closed loop','Digital closed loop');
grid on;
title('Step responses (validation of controller)');

% For Simulink:
%  - Create a new model.
%  - Use blocks: Step -> Sum -> Discrete Transfer Fcn (Cd) -> Zero‑order Hold -> 
%    Transfer Fcn (G) -> Scope.
%  - Set sample time of Discrete Transfer Fcn & ZOH to Te.