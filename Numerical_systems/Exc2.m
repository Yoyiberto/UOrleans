K = 1:5;
S = [0,0.2, 0.55, 0.77, 0.74];
E = [1,0.8, 0.45, 0.23, 0.26];
%%
F=[S(1),0,E(1),0;
S(2),S(1),E(2),E(1);
S(3),S(2),E(3),E(2);
S(4),S(3),E(4),E(3)];
theta=S(2:5)/F
%% Least square

% Validate lengths
if numel(S) ~= numel(E)
    error('S and E must have the same length.');
end
N = numel(S);

% We use 2-point windows: for i = 1 to N-2, we fit over samples i and i+1
max_iter = N - 2;

a   = zeros(1, max_iter);
b0  = zeros(1, max_iter);

for i = 1:max_iter
    % Output vector: s(k) for k = i+1, i+2  -> two rows
    Y = S(i+1:i+2).';  % column vector (2x1)

    % Design matrix:
    % First column: -s(k-1) = -S(i:i+1)
    % Second column: e(k-1) = E(i:i+1)
    X = [-S(i:i+1).',  E(i:i+1).'];  % (2x2)

    % Least squares solution for [a; b0]
    theta = X \ Y;

    a(i)  = theta(1);
    b0(i) = theta(2);
end

disp(['Estimated a:  ', num2str(a)]);
disp(['Estimated b0: ', num2str(b0)]);

% Plot results
figure(1);
plot(1:max_iter, a, 'o-', 'LineWidth', 1.5);
grid on;
xlabel('Window index');
ylabel('a');
title('Estimated a over sliding windows');

figure(2);
plot(1:max_iter, b0, 's-', 'LineWidth', 1.5);
grid on;
xlabel('Window index');
ylabel('b0');
title('Estimated b0 over sliding windows');

% Combined parameter matrix (each row: [a_i, b0_i])
theta = [a.', b0.'];