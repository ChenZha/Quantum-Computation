function [E1,E2] = drawparallelogram(O1,O2,length,path,degree)
%以O1 O2为初始点，length为长度，画平行四边形，输出，另一侧坐标E1 E2(纵坐标形式)
%% 参量缺省 默认drawparallelogram((0,0),(0,1),1,'parallelogram.txt',0)
    if nargin < 5
        degree = 0;
    end
    if nargin < 4
        path = 'parallelogram.txt';
    end
    if nargin < 3
        length = 1;
    end
    if nargin < 2
        O1 = [0;0];
        O2 = [0;1];
    end
%% 输出
    E1 = [O1(1)+length*cosd(degree);O1(2)+length*sind(degree)];
    E2 = [O2(1)+length*cosd(degree);O2(2)+length*sind(degree)];
    filewrite([O1,E1,E2,O2],path,[0;0]);
end
