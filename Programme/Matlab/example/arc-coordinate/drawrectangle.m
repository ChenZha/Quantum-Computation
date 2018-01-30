function [E1,E2] = drawrectangle(O1,O2,length,path)
%��O1 O2Ϊ��ʼ�㣬lengthΪ���ȣ������Σ��������һ������E1 E2(��������ʽ)
%% ����ȱʡ Ĭ��drawrectangle((0,0),(0,1),1,'rectangle.txt')
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
