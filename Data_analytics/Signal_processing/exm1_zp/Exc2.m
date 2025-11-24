%Signal generation 
Fs = 44100;              
duration = 5;             
f0 = 440;                      
% Sampling frequency for digital signal 
% Duration in seconds 
% Frequency of the pure tone  
time = 0: 1/Fs : duration-1/Fs;     % time vector for abscisse axes 
A=1;  % amplitude 1V 
signal = A*sin(2*pi*f0*time);   

%% Random noise- normal distribution
N=220500;
sigma=3;
NoiseG =sigma * randn(1,N);
figure(2)
plot(linspace(1, N, N),NoiseG)
figure(3)
histogram(NoiseG)
%noisySignal=signal+NoiseG; 
%ratio=10 log_10(A^2/sigma^2)
%NoiseU=sigma * rand(1,N)  

noisySignal=signal+NoiseG; 
figure(4)
histogram(noisySignal)
ratio=10*log10(A^2/sigma^2);
fprintf('the ratio is %f', ratio)