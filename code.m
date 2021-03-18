clc; clear all; close all;

% Creating X_k
size_X = 5000;
range = [-1 1];
X_k = randi(range,size_X,1);

% IDFT
x_m = ifft(X_k); %Turns data points into impulses 


% Adding cyclic prefix
cycPrefix = x_m(49:64);
x_L_m = [x_m(49:64); x_m];


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

% Transmit data
y_m = nonflat_channel(x_L_m);

% IDFT
Y_k = fft(y_m,L); 

stem(Y_k)
%%

hold on
stem(X_k)
stem(Y_k)
hold off