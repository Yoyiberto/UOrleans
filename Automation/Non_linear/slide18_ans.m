%% Définition du procédé
p=tf('s')
G=1/(p*(0.1*p+1)*(p+1))
figure;
nichols(G)
hold all;
ngrid

figure;
nyquist(G)

% Question 2: pouvait-on prévoir ce comporten
M=16; %assumption of vals ,eg 16
xM=1; %assumption of vals
k=M/xM;%non linear gain
x1=[0:100];

for k=1:length(x1)
    if x1(k)<=xM
        N1(k)=M/xM;
    else
        N1(k)=(2*M/(xM*pi))*(asin(xM./x1(k))+xM./x1(k).*sqrt(1-(xM./x1(k)).^2));
    end
end
figure;plot(x1,N1,'o-')
xlabel('x1')
ylabel('N1')
figure;plot(real(-1./N1),imag(-1./N1),'ro-')
hold all
nyquist(G)
hold all
%nyquist(G*0.7,'k')
% Conclusion
% Il semble que l'on puisse prédire le compor