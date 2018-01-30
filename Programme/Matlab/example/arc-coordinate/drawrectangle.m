function [E1,E2] = drawrectangle(O1,O2,length,path)
%以O1 O2为初始点，length为长度，画矩形，输出，另一侧坐标E1 E2(纵坐标形式)
%% 参量缺省 默认drawrectangle((0,0),(0,1),1,'rectangle.txt')
    if nargin < 4
        path = 'rectangle.txt';
    end
    if nargin < 3
        length = 1;
    end
    if nargin < 2
        O1 = [0;0];
        O2 = [0;1];
    end
    [E1,E2] = drawparallelogram(O1,O2,length,path,0)
end
