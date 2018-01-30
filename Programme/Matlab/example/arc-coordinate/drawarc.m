function [O1,E1,O2,E2] = drawarc(degree1,degree2,r1,r2,x0,y0,n,path)
%画圆弧，输入起始角度，终止角度，内半径，外半径，圆心位置（x0，y0），点数n
%输出圆弧四个边界点坐标
%% 参量缺省 默认drawarc(0,90,1.0,2.0,0,0,100,'arccoordinate.txt')
    if nargin < 8
        path = 'arc.txt';
    end
    if nargin < 7
        n = 10;
    end
    if nargin < 6
        x0 = 0;
        y0 = 0;
    end
    if nargin < 4
        r1 = 1.0;
        r2 = 2.0;
    end
    if nargin < 2
        degree1 = 0;
        degree2 = 90;
    end
%% 输入 内弧
    fp = fopen(path,'w'); %% 'w'会覆盖之前的数据 ‘a’写在之前数据后面 
    degree = linspace(degree1,degree2,n);
    x1 = r1*cosd(degree);
    y1 = r1*sind(degree);
    xy1 = [x1;y1];
    ab = [x0;y0];
%% 外弧
    degree = fliplr(degree);
    x2 = r2*cosd(degree);
    y2 = r2*sind(degree);
    xy2 = [x2;y2];
    xy = [xy1,xy2];
    filewrite(xy,path,ab);
    O1 = xy1(:,1);%r1初始
    E1 = xy1(:,n);%r1末尾
    E2 = xy2(:,1);%r2末尾
    O2 = xy2(:,n);%r2初始
end
