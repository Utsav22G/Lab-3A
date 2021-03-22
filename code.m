clc; clear all; close all;

% Creating X_k
size_X = 6400;
range = [-1 1];
X_k = randi(range,size_X,1);

% IDFT
x_m = ifft(X_k); %Turns data points into impulses 

% Extending the 64 points
L = 64; %Length of Pulse

pulse = ones(L, 1); %Creates pulse with L of 64 bits

% spread out the values in "bits" by Symbol_period
% first create a vector to store the values
x_0 = zeros(L*length(x_m),1);

% assign every Symbol_period-th sample to equal a value from bits
x_0(1:L:end) = x_m;

% now convolve the single generic pulse with the spread-out bits
x_m_pulse = conv(pulse, x_0);
x_m_pulse= x_m_pulse(1:409600);

figure;
stem(x_m_pulse)
ylabel('amplitude')

%% 

% Adding cyclic prefix
d = 64;
n_data = size_X / d;

Len_pulse_data = length(x_m_pulse) + length(x_m_pulse)/4;

%Index 1st cyclic prefix
A = x_m_pulse(3073: 4096);
x_m_load(1:1024) = A;
x_m_load(1025:5120) = x_m_pulse(1: 4096);

for R = 2:1:100
    cycPrefix = x_m_pulse(4096*(R-1)+ 64*48+1: 4096*(R));
    x_m_load(80*64*(R-1)+1 : 5120*(R-1) + 1024) = cycPrefix;
    Post_chunk =  x_m_pulse(4096*(R-1)+1: 4096*(R));
    x_m_load(5120*(R-1) + 1024+1 : 5120*(R-1) + 1024 +4096) = Post_chunk;

end

stem(x_m_load)
hold on
title('Data with Cyclic Prefixes')
hold off
x_m_load = transpose(x_m_load);
% Transmit data through nonflat channel
y_m = nonflat_channel(x_m_load);




% FFT - Fast FOurier Transform of Received Data
Y_k = fft(y_m, L); 
figure;
stem(Y_k);
hold on
title('Received Data')
hold off
%%
stem(x_m)
hold on
stem(Y_k)
hold off