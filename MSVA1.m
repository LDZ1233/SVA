clc;
clear;
close all;

% 加载数据
data = load('CascadeTarget.mat');
sizeImage = data.original_data / 255 / 4; % 假设数据变量为 sample
l = real(sizeImage); % 实部
Q = imag(sizeImage); % 虚部

% 显示原图
figure;
imshow(abs(l + 1i * Q));
title('原图');

% 定义计算权值函数
function w = calculate_weights(matrix, shift1, shift2)
    w = matrix ./ (abs(circshift(matrix, [shift1, 0])) + abs(circshift(matrix, [shift2, 0])));
    w(isnan(w)) = 0; % 处理除以零的情况
end

% 计算行和列权值
w_I_col = calculate_weights(l, 0, 1);
w_I_row = calculate_weights(l, -1, 1);
w_Q_col = calculate_weights(Q, 0, 1);
w_Q_row = calculate_weights(Q, -1, 1);

% 定义权重调整函数
function adjusted_matrix = adjust_matrix(matrix, weights)
    adjusted_matrix = zeros(size(matrix));
    for m = 2:size(matrix, 2)-1
        idx_pos = weights(:, m) > 0.5;
        adjusted_matrix(idx_pos, m) = matrix(idx_pos, m) - 0.5 * (abs(matrix(idx_pos, m-1)) + abs(matrix(idx_pos, m+1)));
        
        idx_neg = weights(:, m) <= -0.5;
        adjusted_matrix(idx_neg, m) = matrix(idx_neg, m) + 0.5 * (abs(matrix(idx_neg, m-1)) + abs(matrix(idx_neg, m+1)));
        
        idx_mid = abs(weights(:, m)) <= 0.5;
        adjusted_matrix(idx_mid, m) = 0.2 * matrix(idx_mid, m);
    end
end

% 调整实部和虚部的行和列
I_m_col = adjust_matrix(l, w_I_col);
I_m_row = adjust_matrix(l', w_I_row')';
Q_m_col = adjust_matrix(Q, w_Q_col);
Q_m_row = adjust_matrix(Q', w_Q_row')';

% 显示调整后的图像
figure;
imshow(I_m_col*2);
title('I_m_col图');
figure;
imshow(I_m_row*2);
title('I_m_row图');
figure;
imshow(Q_m_col*2);
title('Q_m_col图');
figure;
imshow(Q_m_row*2);
title('Q_m_row图');

% 生成最终图像并显示
I_m_final = (I_m_col + I_m_row) / 2;
Q_m_final = (Q_m_col + Q_m_row) / 2;
g_m = I_m_final + 1i * Q_m_final;

figure;
imshow(abs(g_m));
title('最终图');
