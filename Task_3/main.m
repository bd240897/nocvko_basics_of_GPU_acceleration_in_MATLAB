%% ������� 3
%% 
% ��������� ������� �� CPU

tic;
visability_cpu();
time_CPU = toc;

message = strcat('����� ������ �� �PU: ', num2str(time_CPU), ' c�����');
disp(message)

%% 
% ��������� ������� �� GPU

tic;
visability_gpu();
time_GPU = toc;

message = strcat('����� ������ �� GPU: ', num2str(time_GPU), ' c�����');
disp(message)