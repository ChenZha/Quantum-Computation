function orgMultiClusterData(path)
if nargin<1
    path='E:\data\20180622_12bit\sampling\180809\cluster';
end
firstag='q12';

files=dir(path);
[~, ind] = sort([files(:).datenum], 'ascend');
files = files(ind);
numfiles=numel(files)-2;
lo=[];
for ii=1:numfiles
    if ismember({'q1',firstag,'L1'},split(files(ii).name,'_'))
        lo=[lo,ii];
    end
end
if ~isempty(lo)
    lo=[lo(1:2:end) numfiles+1];
    for ii=1:numel(lo)-1
        cfolder=[path '\' num2str(ii)];
        mkdir(cfolder);
        for jj=lo(ii):(lo(ii+1)-1)
            movefile([path '\' files(jj).name],cfolder)
        end
    end
end
end