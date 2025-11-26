clear all;
clc;

p=tf('s');
G=2/(0.1*p+1);
figure;
bode(G)


%%
w_max=100; %w_max from bode plot(-20dB fmax)
f_max=w_max/2*pi;
fe_shannon=2*f_max;
Te_shannon=1/fe_shannon;
%On pose Te==40ms ===>fmax
fe=1/(40e-3);
fmax=fe/2;
wmax=fmax*2*pi;
%%
Te=40e-3;
Gc=c2d(G,Te,method="zoh");
figure(2)
bode(G)
hold all
bode(Gc)
Te=3e-3;
Gc=c2d(G,Te,method="zoh");
hold all
bode(Gc)
legend('Continous','Discrete 40ms','Discrete 3ms')

%%
%lambda=0.42;
%phi=-250:1:-150
%Q=
Kp=20;
figure;
nichols(G); 
hold all;
nichols(Gc)
nichols(Kp*Gc)
grid on;
title('Nichols chart of G(p)');
%%
phi=-250:1:-150;
%Q^2+2*G*
