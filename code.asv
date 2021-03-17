clc; clear all; close all;

% Creating X_k
size_X = 5000;
range = [-1 1];
X_k = randi(range,size_X,1);

% IDFT
L = 64;
x_m = ifft(X_k,L); 

% Extending the 64 points

% Adding cyclic prefix
cycPrefix = x_m(49:64);
x_L_m = [x_m(49:64); x_m];

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