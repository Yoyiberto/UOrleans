% Provided Data
K = 1:10;
S = [0 0.52 0.9 1.2 1.4 1.55 1.67 1.73 1.82 1.86];
E = ones(1, 10);

% Create regression matrix (F: S(k-1) and constant)
Y = S(2:end)';      % Output vector s(k)
X = [-S(1:end-1)' ones(9,1)];  % Input vector [-s(k-1) 1] for b0

% Least squares solution
theta = X\Y;
a = theta(1);      % Negative sign included by regression structure
b0 = theta(2);

disp(['Estimated a: ', num2str(a)]);
disp(['Estimated b0: ', num2str(b0)]);

% Simulate system using identified parameters
sys = tf([b0], [1 a], 1); % Discrete system, Ts=1s

step(sys, 10); % Plot the step response for 10 seconds
hold on;
stairs(K, S, 'r*'); % Overlay measured data
legend('Simulated','Measured');

%%
K = 1:10;
S = [0 0.52 0.9 1.2 1.4 1.55 1.67 1.73 1.82 1.86];
E = ones(1, 10); E(1)=0;

% Create regression matrix (F: S(k-1) and constant)


for i=1:8
    Y = S(i+1:i+2)';      % Output vector s(k)
    X = [-S(i:i+1)' E(i:i+1)'];  % Input vector [-s(k-1) 1] for b0
    
    % Least squares solution
    theta = X\Y;
    a(i) = theta(1);      % Negative sign included by regression structure
    b0(i) = theta(2);
end

disp(['Estimated a: ', num2str(a)]);
disp(['Estimated b0: ', num2str(b0)]);

%plotting numbers
figure(1)
title('a Plot')
plot(1:8,a);
figure(2)
title('b0Plot')
plot(1:8,b0);

theta=[a',b0'];