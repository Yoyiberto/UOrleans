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
semilogx(w,(phaseB))
hold all
semilogx(w,(-180*Te*w)/(pi))


%% Question 4
figure
w=logspace(-4,4,100);
[mag,phase]=bode(G,w)
[magZ,phaseZ]=bode(Gz,w)

hold all
mag_db(1:length(mag))=20*log10(mag(1,1,1:length(mag)));
phase_degre(1:length(phase))=phase(1,1,1:length(phase));

mag_dbz(1:length(magZ))=20*log10(magZ(1,1,1:length(magZ)));
phase_degrez(1:length(phaseZ))=phaseZ(1,1,1:length(phaseZ));


plot(phase_degre-(180*w*Te)/(pi),mag_db)
hold all
plot(phase_degrez,mag_dbz)
hold all
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
semilogx(w,phase_degre-180*w*Te/(2*pi))
hold all
semilogx(w,phase_degrez)
grid on
%% Calcul de la transformée du système avec bloqueur d'ordre zero
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

%%
clear all
close all
clc

p=tf('s')
G=2/(0.1*p+1)
figure;
bode(G)
wmax=1000
fmax=wmax/(2*pi)
%Theo Shannon
fe=2*fmax
Te=1/fe; % Periode a 3ms
% On pose Te=10ms ==>fmax
% Ici on peut choisir la fréquence que l'on souhaite mais attention a
% satisfaire le compromis! On se place dans une contexte volontairement
% limite
fe=1/(10e-3)
fmax=fe/2
wmax=fmax*2*pi
%%
Te=40e-3;
Gd=c2d(G,Te)
figure; 
bode(G)
hold all
bode(Gd)
Te=3e-3;
Gd2=c2d(G,Te)
hold all
bode(Gd2)
legend('Cont','Discret 40ms','Discret 3ms')
%%
Te=10e-3;
figure;nichols(Gd)
ngrid
hold all

%% Fonction de transfert+BOZ
w=linspace(0.001,1000,1000)
[magd,phased]=bode(Gd,w);
[mag,phase]=bode(G,w);
figure
hold all
magd_db(1:length(magd))=20*log10(magd(1,1,1:length(magd)));
phased_degre(1:length(phased))=phased(1,1,1:length(phased));
mag_db(1:length(mag))=20*log10(mag(1,1,1:length(mag)));
phase_degre(1:length(phase))=phase(1,1,1:length(phase));
hold all
plot(phase_degre-180*(Te*w/(pi*2)),mag_db)
hold all
plot(phased_degre,magd_db)
ngrid
legend('G+BOZ','Gc')
%% On trace le contour Q
% Pour le calculer on part d'une fonction de transfert générale G=G*e(jphi)
% calcul de la boucle fermée puis du gain de cette derniere
% egalité de M^2=G^2/(1+2*G*cos(phi)+G^2)
% L'iso contour est la valeur de G pour laquelle on obtient M=cst
lambda=0.6;
M=(1/((2*lambda)*sqrt(1-(lambda*lambda))))

phi=[-229.667:0.001:-130.331];
-1+M^2;
2*cosd(phi)*M^2;
M^2;
for i=1:length(phi)
A(:,i)=((roots([-1+M^2 2*cosd(phi(i))*M^2 M^2])));
end
imag(A);
x=20*log10(A);

hold all
plot(phi,x(1,:),'r')
hold all
plot(phi,x(2,:),'r')
hold all
plot(phase_degre-180*(Te*w/(pi*2)),mag_db)
hold all
hold all
plot(phased_degre,magd_db+3.125)
% legend('G+BOZ','Gc','Contour','Contour','(G+BOZ)*Kp','Gc*Kp')
hold all
nichols(Gd*10^(3.125/20),w)
legend('G+BOZ','Gc','Contour','Contour','(G+BOZ)*Kp','Gc*Kp','Gc*Kp nichols')
%On voit ici la répercution de l'approximation (environ 2dB sur le gain)

%%
Kp=10^(3.125/20)
figure;bode((Gd*Kp)/(1+(Gd*Kp)))