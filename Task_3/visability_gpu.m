
% основная функция
function visability_gpu()

%% ВЛОЖЕННАЯ ФУНКЦИЯ 

    % вложенная функция 
    function  is_visible = loop_kernel(ix_x, ix_y)
        x = gX(ix_y, ix_x);
        z = gZ(ix_y, ix_x);
        is_visible = 1;
        
        % перебор отсчетов находящихся на линии между точкой наблюдения и 
        % анализируемым отсчетом поверхности
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

%% ВХОДНЫЕ ДАННЫЕ 
% введем глобальные переменные 
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

% точка наблюдения
x0 = 10*1;
y0 = 1*1;
z0 = 5;

% поверхность
[X,Y,Z] = peaks(10);

% шаг и пределы изменения по оси ОХ
dx = X(1,2) - X(1,1);
x_min = min(min(X));
x_max = max(max(X));
 
% шаг и пределы изменения по оси ОY
dy = Y(2,1) - Y(1,1);
y_min = min(min(Y));
y_max = max(max(Y));
 
% размер поверхности в отсчетах
data_size = size(Z);
   
%% ПЕРЕНЕСЕМ ДАННЫЕ НА GPU
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

% в случае вычиленния на CPU - просто присвоим им исходные значения
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

%% ХОД ВЫЧИСЛЕНИЯ

% генерация массиово для функции arrayfun
ix_x = 1:data_size(2);
ix_x = repmat(ix_x, [data_size(1),1]);
ix_y =ix_x.';

% ПЕРЕНЕСЕМ ДАННЫЕ НА GPU
gix_x = gpuArray(ix_x);
gix_y = gpuArray(ix_y);

% % в случае вычисления на CPU - просто присвоим значения
% gix_x = (ix_x);
% gix_y = (ix_y);

% маска видимых фацетов
g_mask = arrayfun(@loop_kernel, gix_x, gix_y);

% вернеам значения из GPU 
mask = gather(g_mask);

% в случае вычисления на CPU - просто присвоим значение 
% mask = g_mask;

%% ПОСТРОЕН ГРАФИКОВ 
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
