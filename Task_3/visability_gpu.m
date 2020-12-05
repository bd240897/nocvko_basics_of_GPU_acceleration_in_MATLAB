
% �������� �������
function visability_gpu()

%% ��������� ������� 

    % ��������� ������� 
    function  is_visible = loop_kernel(ix_x, ix_y)
        x = gX(ix_y, ix_x);
        z = gZ(ix_y, ix_x);
        is_visible = 1;
        
        % ������� �������� ����������� �� ����� ����� ������ ���������� � 
        % ������������� �������� �����������
        for ix_r = 1:1000
            x = x + gdx*sign(gx0 - gX(ix_y, ix_x));
            
            %(x - x0)/(xi - x0) = (y - y0)/(yi - y0)
            y = (gY(ix_y, ix_x) - gy0)/(gX(ix_y, ix_x) - gx0)*(x - gx0) + gy0;
            
%            ty(ix_r) = y;
%            tx(ix_r) = x;
            
            ix_x_search = round((x - gx_min)/gdx) + 1;
            ix_y_search = round((y - gy_min)/gdy) + 1;
            
            if ((ix_x_search <= gdata_size(2)) && (ix_x_search > 1)...
                && (ix_y_search <= gdata_size(1)) && (ix_y_search > 1))
                
                if (z < gZ(ix_y_search, ix_x_search))
                %if (z < z_int)
                    is_visible = 0;
                    break
                end
            end
        end
        
    end 

%% ������� ������ 
% ������ ���������� ���������� 
global gX;
global gY;
global gZ;

global gx0;
global gy0;

global gdx;
global gdy;

global gx_min;
global gy_min;
global gdata_size;

% ����� ����������
x0 = 10*1;
y0 = 1*1;
z0 = 5;

% �����������
[X,Y,Z] = peaks(10);

% ��� � ������� ��������� �� ��� ��
dx = X(1,2) - X(1,1);
x_min = min(min(X));
x_max = max(max(X));
 
% ��� � ������� ��������� �� ��� �Y
dy = Y(2,1) - Y(1,1);
y_min = min(min(Y));
y_max = max(max(Y));
 
% ������ ����������� � ��������
data_size = size(Z);
   
%% ��������� ������ �� GPU
gX = gpuArray(X);
gY = gpuArray(Y);
gZ = gpuArray(Z);
gdx = gpuArray(dx);
gdy = gpuArray(dy);
gx_min = gpuArray(x_min);
gy_min = gpuArray(y_min);
gx0 = gpuArray(x0);
gy0 = gpuArray(y0);
gz0 = gpuArray(z0);
gdata_size = gpuArray(data_size);

% � ������ ���������� �� CPU - ������ �������� �� �������� ��������
% gX = (X);
% gY = (Y);
% gZ = (Z);
% gdx = (dx);
% gdy = (dy);
% gx_min = (x_min);
% gy_min = (y_min);
% gx0 = (x0);
% gy0 = (y0);
% gz0 = (z0);
% gdata_size = (data_size);

%% ��� ����������

% ��������� �������� ��� ������� arrayfun
ix_x = 1:data_size(2);
ix_x = repmat(ix_x, [data_size(1),1]);
ix_y =ix_x.';

% ��������� ������ �� GPU
gix_x = gpuArray(ix_x);
gix_y = gpuArray(ix_y);

% % � ������ ���������� �� CPU - ������ �������� ��������
% gix_x = (ix_x);
% gix_y = (ix_y);

% ����� ������� �������
g_mask = arrayfun(@loop_kernel, gix_x, gix_y);

% ������� �������� �� GPU 
mask = gather(g_mask);

% � ������ ���������� �� CPU - ������ �������� �������� 
% mask = g_mask;

%% �������� �������� 
figure;
subplot(1,2,1)
hold on;
surf(X,Y,Z, 'EdgeColor','none');
 
plot3(x0, y0, z0, 'xr')
hold off;

subplot(1,2,2)
hold on;
surf(X,Y,Z.*mask,'EdgeColor','none');
 
plot3(x0, y0, z0, 'xr')
hold off;

end
