% Extract time, input (u), and output (y) from the logged data
simout=Ne;
t = simout.time;
u = simout.signals(1).values; 
y = simout.signals(2).values;

% Create the iddata object
% 'Ts' is the sample time of your simulation. If it's variable, 
% you may need to resample it to a fixed step.
Ts = t(2) - t(1); % Calculate sample time
data = iddata(y, u, Ts);

%%
d=0.53; %percentage
lambda=-log(d)/sqrt(pi^2+log(d)^2) %lamda correct formula