% Đọc dữ liệu từ file hex
fileID = fopen('sine.hex', 'r');
hexData = fscanf(fileID, '%x');
fclose(fileID);

% Chuyển đổi từ hex sang số nguyên có dấu 24-bit
N = length(hexData);  % Số lượng mẫu
signal = zeros(1, N);  % Khởi tạo tín hiệu

for i = 1:N
    % Lấy giá trị 24-bit
    value = hexData(i);
    
    % Nếu giá trị 24-bit là số âm, chuyển đổi thành số âm có dấu
    if bitand(value, hex2dec('800000')) ~= 0
        value = value - hex2dec('1000000');
    end
    
    % Lưu giá trị vào mảng tín hiệu
    signal(i) = value;
end

% Chuẩn hóa tín hiệu để nằm trong khoảng [-1, 1] (nếu cần)
signal = signal / (2^23);

% Thông số của tín hiệu
fs = 1000;           % Tần số mẫu (Hz)

% Hiển thị tín hiệu trước khi lọc
t = (0:N-1)/fs;      % Trục thời gian
figure;
subplot(2,1,1);
plot(t, signal);
title('Tín hiệu trước khi lọc');
xlabel('Thời gian (s)');
ylabel('Biên độ');

% Thiết kế bộ lọc FIR thông thấp
fc = 10;            % Tần số cắt (Hz)
order = 100;         % Bậc của bộ lọc, cao hơn để cải thiện đáp ứng tần số
b = fir1(order, fc/(fs/2), 'low');

% Áp dụng bộ lọc vào tín hiệu
filtered_signal = filter(b, 1, signal);

% Hiển thị tín hiệu sau khi lọc
subplot(2,1,2);
plot(t, filtered_signal);
title('Tín hiệu sau khi lọc thông thấp');
xlabel('Thời gian (s)');
ylabel('Biên độ');

% Phân tích Fourier trước khi lọc
figure;
signal_fft = fft(signal);
frequencies = (0:N-1)*(fs/N);  % Trục tần số
subplot(2,1,1);
plot(frequencies(1:N/2), abs(signal_fft(1:N/2))/N);
xlim([0 fs/2]);  % Chỉ hiển thị tần số dương
title('Phổ Fourier trước khi lọc');
xlabel('Tần số (Hz)');
ylabel('Biên độ');

% Phân tích Fourier sau khi lọc
filtered_signal_fft = fft(filtered_signal);
subplot(2,1,2);
plot(frequencies(1:N/2), abs(filtered_signal_fft(1:N/2))/N);
xlim([0 fs/2]);  % Chỉ hiển thị tần số dương
title('Phổ Fourier sau khi lọc');
xlabel('Tần số (Hz)');
ylabel('Biên độ');
