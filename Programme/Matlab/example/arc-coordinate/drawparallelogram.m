function [E1,E2] = drawparallelogram(O1,O2,length,path,degree)
%��O1 O2Ϊ��ʼ�㣬lengthΪ���ȣ���ƽ���ı��Σ��������һ������E1 E2(��������ʽ)
%% ����ȱʡ Ĭ��drawparallelogram((0,0),(0,1),1,'parallelogram.txt',0)
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
%% ���
    E1 = [O1(1)+length*cosd(degree);O1(2)+length*sind(degree)];
    E2 = [O2(1)+length*cosd(degree);O2(2)+length*sind(degree)];
    filewrite([O1,E1,E2,O2],path,[0;0]);
end
