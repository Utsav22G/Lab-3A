clc; clear all; close all;

% Create signal in the frequency domain
chunk = 64;                     %   size of one data packet in bits
packets = 100;                  %   number of data packets
num_bits = chunk*packets;       %   total number of data bits
X_k = randi([0,1], 1, num_bits);

% replace all zeros with -1
X_k(X_k == 0) = -1;

% Create training data
num_train = 640;
X_train = ones(1, num_train);

% Combine training data and signal
message = [X_train, X_k];

%%  Move data to time domain

% Perform inverse Fourier transform
ifft_message = ifft(message);

%%  Perform cyclic convolution
% also on training data

% Cyclic prefix insertion
pulse_width = 64;
message_length = max(size(ifft_message));
ifft_msg_prefix = zeros(1, (5*message_length/4));

for i = 1:((message_length)/pulse_width)
    prefix = ifft_message((64*i-15):64*i);
    ifft_msg_prefix(1+(i-1)*80:(i-1)*80+16) = prefix;
    ifft_msg_prefix(1+(i-1)*80+16:i*80) = ifft_message((i-1)*64+1:i*64);
end

% Perform circular convolution
pulse = ones(1, pulse_width);
conv_message = conv(ifft_msg_prefix, pulse_width);
tx_message = conv_message(1:(num_bits*(5/4)+num_train))'; % Truncate the trailing zeros added by the convolution
% Data truncated to: num. of data bits + 16 prefix bits per data packet + num. of training
% bits = 6400 + 16 * 100 + 640 = 8640

%%  Simulate the channel

% Transmit data through nonflat channel function
rx_message = nonflat_channel((tx_message));

% Visualize data transmitted
figure(1)
subplot(2,1,1)
stem(tx_message)
xlabel('i-th Signal')
ylabel('Magnitude')
title('Transmitted Signal')

% Visualize data received
subplot(2,1,2)
stem(rx_message)
xlabel('i-th Signal')
ylabel('Magnitude')
title('Unfiltered Received Signal')

%%  Rx data alignment

tx_len = length(tx_message);
rx_len = length(rx_message);

% Determine the received data
[cross_corr,lags] = xcorr(rx_message,tx_message); 
[~, idx] = max(abs(cross_corr));
peak = lags(idx);

% Slice data according to lags and tx_data length
sliced_rx = rx_message(peak:tx_len);

figure
stem(sliced_rx)

%%  Move to frequency domain

fft_rx = fft(sliced_rx, num_bits);

figure(2)
stem(real(fft_rx));
hold on
title('Received Data - FFT')
hold off

%%  Channel Estimation

% Locate training data before and after channel simulation
tx_train = message(1:num_train);
rx_train = fft_rx(1:num_train);

% Perform element-wise division on every bit
channel_response = zeros(1, num_train);

sum = zeros(1, num_train);
% fix indexing
iter = 2;
while iter <= num_train
    sum(1, iter) = (channel_response(1, (iter-1)) + rx_train(iter,1)) ./ tx_train(1, iter);
    iter = iter + 1;
end

channel_estimate = sum(1,num_train)/num_train;

%%  Recover transmitted data

tx_est = fft_rx(num_train+1:end) / channel_estimate;

figure(3)
stem(tx_est);
hold on
title('Recovered Tx signal')
hold off







