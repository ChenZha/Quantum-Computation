function filewrite(xy,path,ab)
%输出xy到path，偏移ab
%% 参量缺省,默认偏移（0，0）；输出路径‘output.txt’；位置（0，0）
    if nargin < 3
        ab = [0;0];
    end
    if nargin < 2
        path = 'output.txt';
    end
    if nargin == 0
        xy=[0;0];
    end

%% 输出
    fp = fopen(path,'w');
    xy(1,:) = xy(1,:)+ab(1);
    xy(2,:) = xy(2,:)+ab(2);
    fprintf(fp,'%g\t%g\n',xy)
    fclose(fp);
        
end
