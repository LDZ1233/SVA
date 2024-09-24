clc;
clear;
close all;

% 加载数据
data = load('CascadeTarget.mat');
sizeImage = data.original_data / 255 / 4; % 假设数据变量为 sample

l = real(sizeImage); % 实部
Q = imag(sizeImage); % 虚部
g = l + 1i * Q; % 复数图像

figure;
imshow(abs(g));
title('原图');

I_pool = l;
Q_pool = Q;

I_pool_t = l';
Q_pool_t = Q';

% 步骤2: 计算实部的权值（列）
w_um_l = I_pool ./ (abs(circshift(I_pool, [0, -1])) + abs(circshift(I_pool, [0, 1])));
w_um_l(isnan(w_um_l)) = 0; % 处理除以零的情况

% 步骤2: 计算实部的权值（行）
w_um_l_row = I_pool ./ (abs(circshift(I_pool, [-1, 0])) + abs(circshift(I_pool, [1, 0])));
w_um_l_row(isnan(w_um_l_row)) = 0; % 处理除以零的情况

% 步骤2: 计算虚部的权值（列）
w_um_Q = Q_pool ./ (abs(circshift(Q_pool, [0, -1])) + abs(circshift(Q_pool, [0, 1])));
w_um_Q(isnan(w_um_Q)) = 0; % 处理除以零的情况

% 步骤2: 计算虚部的权值（行）
w_um_Q_row = Q_pool ./ (abs(circshift(Q_pool, [-1, 0])) + abs(circshift(Q_pool, [1, 0])));
w_um_Q_row(isnan(w_um_Q_row)) = 0; % 处理除以零的情况

% 根据权重调整实部（列）
I_m = zeros(size(l));
for m = 2:size(l, 2)-1
    idx = w_um_l(:, m) > 0.5;
    I_m(idx, m) = l(idx, m) - 0.5 * (abs(l(idx, m-1)) + abs(l(idx, m+1)));
    
    idx = w_um_l(:, m) <= -0.5;
    I_m(idx, m) = l(idx, m) + 0.5 * (abs(l(idx, m-1)) + abs(l(idx, m+1)));
    
    idx = abs(w_um_l(:, m)) <= 0.5;
    I_m(idx, m) = 0.2 * l(idx, m);
end

figure;
imshow(I_m*2);
title('i_m图');

% 根据权重调整实部（行）
I_m_row = zeros(size(l));
for n = 2:size(l, 1)-1
    idx = w_um_l_row(n, :) > 0.5;
    I_m_row(n, idx) = l(n, idx) - 0.5 * (abs(l(n-1, idx)) + abs(l(n+1, idx)));
    
    idx = w_um_l_row(n, :) <= -0.5;
    I_m_row(n, idx) = l(n, idx) + 0.5 * (abs(l(n-1, idx)) + abs(l(n+1, idx)));
    
    idx = abs(w_um_l_row(n, :)) <= 0.5;
    I_m_row(n, idx) = 0.2 * l(n, idx);
end

figure;
imshow(I_m_row*2);
title('i_m_row图');

% 根据权重调整虚部（列）
Q_m = zeros(size(Q));
for m = 2:size(Q, 2)-1
    idx = w_um_Q(:, m) > 0.5;
    Q_m(idx, m) = Q(idx, m) - 0.5 * (abs(Q(idx, m-1)) + abs(Q(idx, m+1)));
    
    idx = w_um_Q(:, m) <= -0.5;
    Q_m(idx, m) = Q(idx, m) + 0.5 * (abs(Q(idx, m-1)) + abs(Q(idx, m+1)));
    
    idx = abs(w_um_Q(:, m)) <= 0.5;
    Q_m(idx, m) = 0.2 * Q(idx, m);
end

figure;
imshow(Q_m*2);
title('Q_m图');

% 根据权重调整虚部（行）
Q_m_row = zeros(size(Q));
for n = 2:size(Q, 1)-1
    idx = w_um_Q_row(n, :) > 0.5;
    Q_m_row(n, idx) = Q(n, idx) - 0.5 * (abs(Q(n-1, idx)) + abs(Q(n+1, idx)));
    
    idx = w_um_Q_row(n, :) <= -0.5;
    Q_m_row(n, idx) = Q(n, idx) + 0.5 * (abs(Q(n-1, idx)) + abs(Q(n+1, idx)));
    
    idx = abs(w_um_Q_row(n, :)) <= 0.5;
    Q_m_row(n, idx) = 0.2 * Q(n, idx);
end

figure;
imshow(Q_m_row*2);
title('Q_m_row图');

% 生成行处理矩阵和列处理矩阵，然后求平均
I_m_final = (I_m + I_m_row) / 2;
Q_m_final = (Q_m + Q_m_row) / 2;

% 最终输出图像
g_m = I_m_final + 1i * Q_m_final;

figure;
imshow(abs(g_m));
title('最终图');
