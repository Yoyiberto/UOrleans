clear all
close all
clc
%% Définition du procédé
p=tf('s')
G=1/(p*(0.1*p+1)*(p+1))
figure;
nichols(G)
hold all;
ngrid

figure;
nyquist(G)
hold all;
grid on
%% Définition de la non-linéarité
% Dans un premier temps on fait varier le gain de la N.L. afin de voir
% qu'il existe une valeur de gain pour laquelle j'arrive à mettre ma sortie
% en oscillation, une valeur pour laquelle ma sortie est stable et une
% troisième pour laquelle elle est instable

%Question: Faire varier k afin de faire apparaitre ces trois possibilités
%(k=1,10 et 20)
% Question 2: pouvait-on prévoir ce comportement?

M=16;
xM=1;
k=M/xM;
x1=[0:100];

for i=1:length(x1)
    if x1(i)<=xM
        N1(i)=M/xM;
    else
        N1(i)=(2*M/(xM*pi))*(asin(xM./x1(i))+(xM./x1(i))*sqrt(1-(xM./x1(i))^2));
    end
    i=i+1
end

figure;plot(x1,N1,'o-')
xlabel ('x1')
ylabel('N1')
figure;plot(real(-1./N1),imag(-1./N1),'ro-')
hold all
nyquist(G)
hold all
%%nyquist(G*0.7,'k')
% Conclusion
% Il semble que l'on puisse prédire le comportement oscillant d'une boucle
% de régulation en comparant les lieux de transferts des fonctions de
% transfert B.O. et -1/N(x1,w)
%==> Si il y a intersection il y aura oscillation
% Peut-on prévoir amplitude et peirode des oscillations?
%% Calcul de gain et de phase du NL
Gain_NL=20*log10(1./N1);
figure;
plot(-180.*[ones(length(Gain_NL),1)],Gain_NL,'go','linewidth',3)
[mag,phase]=bode(G)
hold all
mag_db(1:length(mag))=20*log10(mag(1,1,1:length(mag)));
phase_degre(1:length(phase))=phase(1,1,1:length(phase));
plot(phase_degre,mag_db)
ngrid
%% On a donc finalement un système de la forme k.L
figure;
nichols(G*(M/xM))
hold all;
ngrid
% conclusion: sans la N.L. notre système serait instable
%% Revenant à l'essai avec k=20
% Y a-t-il un moyen pour rendre notre système non-oscillant?
Gain_NL=20*log10(1./N1);
figure;
plot(-180.*[ones(length(Gain_NL),1)],Gain_NL,'go','linewidth',3)
[mag,phase]=bode(G)
hold all
mag_db(1:length(mag))=20*log10(mag(1,1,1:length(mag)));
phase_degre(1:length(phase))=phase(1,1,1:length(phase));
plot(phase_degre,mag_db)
ngrid
%==> oui en changeant le gain du système
hold all
[mag,phase]=bode(G/2.2387)
hold all
mag_db(1:length(mag))=20*log10(mag(1,1,1:length(mag)));
phase_degre(1:length(phase))=phase(1,1,1:length(phase));
plot(phase_degre,mag_db)
ngrid
