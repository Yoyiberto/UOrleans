%from Bureau d'étude 1 Fichier
clear all
close all
clc
Te=0.01
p=tf('s');
z=tf([1 0],[1],Te);
%% Question 1
G=2/(1+0.1*p);
Gz=c2d(G,Te)
figure;
bode(G)
hold all;
bode(Gz)
title('Comparison between G(z) and G(p)')
legend('G(p)','G(z)')
%% Question 2 et 3
w=logspace(-4,4,100);
B=(1-exp(-j*Te*w))./(j*w);
magB=abs(B);
magB_db=20*log10(magB);
phaseB=phase(B)*180/pi;
figure;
subplot(211)
semilogx(w,magB_db);
title('Plot of B(jw)')
subplot(212)
semilogx(w,phaseB)
hold all
semilogx(w,(-180*Te*w)/(pi))%semilogx(w,(-180*Te*w)/(2*pi))
%% Question 4
figure
w=logspace(-4,4,100);
[mag,phase]=bode(G,w)
[magZ,phaseZ]=bode(Gz,w)
hold all
mag_db(1:length(mag))=20*log10(mag(1,1,1:length(mag)));
phase_degree(1:length(phase))=phase(1,1,1:length(phase));
mag_dbz(1:length(magZ))=20*log10(magZ(1,1,1:length(magZ)));
phase_degrez(1:length(phaseZ))=phaseZ(1,1,1:length(phaseZ));
plot(phase_degree-(180*w*Te)/(2*pi),mag_db)
hold all
plot(phase_degrez,mag_dbz)
ngrid
title('Comparison between B(jw)*G(jw) and G(z)')
legend('B(jw)*G(jw)','G(z)')
figure;
subplot(211)
semilogx(w,mag_db)
hold all
semilogx(w,mag_dbz)
title('Comparison between B(jw)*G(jw) and G(z)')
legend('B(jw)*G(jw)','G(z)')
subplot(212)
semilogx(w,phase_degree-180*w*Te/(2*pi))
hold all
semilogx(w,phase_degrez)
grid on
%% Calcul de la transformee du systeme avec bloqueur d'ordre ze
a=1/0.1;
num=2*(1-exp(-a*Te))
zden=exp(-a*Te)
Gz_calc=num/(z-zden)
figure;
nichols(w,G)
hold all;
nichols(w,Gz_calc)
Hz=c2d(G,Te)
% Fz=((z-1)/z)*Hz
hold all
nichols(w,Hz)
ngrid
legend('continu','discret','c2d')
xlim([-360 0])