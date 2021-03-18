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


% Adding cyclic prefix
d = 64;
n_data = size_X / d;

Len_pulse_data = length(x_m_pulse) + length(x_m_pulse)/4;

x_L_m = [x_m_pulse(3073:4096); x_m_pulse];
for R = 2:n_data
    cycPrefix = x_m_pulse(3136+(R-1)*4096:4096+(R-1)*4096);
    end_unit = d*L*1*(R-1) + 16*L*(R-1);
    x_L_m = [x_L_m(1: end_unit); x_L_m(end_unit + (R-1)*4096 : end_unit + (R-1)*4096) ; x_L_m(end_unit + 5120:end)];
end

% a = [1,2,4,5];
%    b = [a(1:2) 3 a(3:end)]


% Transmit data
y_m = nonflat_channel(x_m_pulse);




% IDFT
Y_k = fft(y_m,L); 
figure;
stem(Y_k);
%%

hold on
stem(X_k)
stem(Y_k)
hold off