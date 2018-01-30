function [O1,E1,O2,E2] = drawarc(degree1,degree2,r1,r2,x0,y0,n,path)
%��Բ����������ʼ�Ƕȣ���ֹ�Ƕȣ��ڰ뾶����뾶��Բ��λ�ã�x0��y0��������n
%���Բ���ĸ��߽������
%% ����ȱʡ Ĭ��drawarc(0,90,1.0,2.0,0,0,100,'arccoordinate.txt')
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
%% ���� �ڻ�
    fp = fopen(path,'w'); %% 'w'�Ḳ��֮ǰ������ ��a��д��֮ǰ���ݺ��� 
    degree = linspace(degree1,degree2,n);
    x1 = r1*cosd(degree);
    y1 = r1*sind(degree);
    xy1 = [x1;y1];
    ab = [x0;y0];
%% �⻡
    degree = fliplr(degree);
    x2 = r2*cosd(degree);
    y2 = r2*sind(degree);
    xy2 = [x2;y2];
    xy = [xy1,xy2];
    filewrite(xy,path,ab);
    O1 = xy1(:,1);%r1��ʼ
    E1 = xy1(:,n);%r1ĩβ
    E2 = xy2(:,1);%r2ĩβ
    O2 = xy2(:,n);%r2��ʼ
end
