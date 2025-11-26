b=3;
%%
b1=3;
num=[b1^2];
den=[1, 2*b1, b1^2];
TF_1=tf(num,den);
figure(1)
bode(TF_1)
hold on
b2=30;
TF_2=tf([b2^2],[1, 2*b2, b2^2]);
%figure(2)
bode(TF_2)
