function filewrite(xy,path,ab)
%���xy��path��ƫ��ab
%% ����ȱʡ,Ĭ��ƫ�ƣ�0��0�������·����output.txt����λ�ã�0��0��
    if nargin < 3
        ab = [0;0];
    end
    if nargin < 2
        path = 'output.txt';
    end
    if nargin == 0
        xy=[0;0];
    end

%% ���
    fp = fopen(path,'w');
    xy(1,:) = xy(1,:)+ab(1);
    xy(2,:) = xy(2,:)+ab(2);
    fprintf(fp,'%g\t%g\n',xy)
    fclose(fp);
        
end
