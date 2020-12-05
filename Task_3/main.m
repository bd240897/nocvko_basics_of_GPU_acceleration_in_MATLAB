%% Задание 3
%% 
% Измерение времени на CPU

tic;
visability_cpu();
time_CPU = toc;

message = strcat('Время работы на СPU: ', num2str(time_CPU), ' cекунд');
disp(message)

%% 
% Измерение времени на GPU

tic;
visability_gpu();
time_GPU = toc;

message = strcat('Время работы на GPU: ', num2str(time_GPU), ' cекунд');
disp(message)