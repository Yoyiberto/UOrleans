clear;clc;
A=1;
f0=50;
Fs=1000;
t=0:1/Fs:100/f0;
phi=2*pi*(rand(1)-0.5);
x=A*cos(2*pi*f0*t+phi);
tau0=0.0023;
y=A*cos(2*pi*f0*(t-tau0)+phi);
%% Adding noise
sigma=1;
x=x+sigma*randn(size(x));
y=y+sigma*randn(size(y));
%%
figure(1)
plot(x)
figure(2)
plot(y)
%% correlation
gamma_xx=xcorr(x)/length(t);
gamma_yy=xcorr(y)/length(t);
gamma_xy=xcorr(x,y)/length(t);
tau=(-length(t)+1:(length(t)-1))/Fs;
figure
plot(tau,gamma_xx)
hold on
plot(tau,gamma_xy)

%% bias
diff=gamma_xx-gamma_xy;
diff_mean=mode(diff);
%% max