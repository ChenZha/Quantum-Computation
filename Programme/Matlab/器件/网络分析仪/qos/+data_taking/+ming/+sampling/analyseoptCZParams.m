function [thi,thf,lam2,lam3,fidelity]=analyseoptCZParams()
path='E:\data\20180216_12bit';
files=dir([path '\optCZParams*.mat']);

tags={'q1q2','q3q2','q3q4','q5q4','q5q6','q7q6','q7q8','q9q8','q9q10','q11q10','q11q12'};

lam2=cell(1,11);
lam3=cell(1,11);
thi=cell(1,11);
thf=cell(1,11);
fidelity=cell(1,11);
for ii=1:numel(files)
    filename=split(files(ii).name,'_');
    load([files(ii).folder '\' files(ii).name])
    [a,b]=ismember(filename(2),tags);
    if a
        lam2{b}=[lam2{b},x_trace(end,4)];
        lam3{b}=[lam3{b},x_trace(end,5)];
        thi{b}=[thi{b},x_trace(end,2)];
        thf{b}=[thf{b},x_trace(end,3)];
        if -y_trace(end)>=2
            fidelity{b}=[fidelity{b},-y_trace(end)/3];
        elseif -y_trace(end)>=1 && -y_trace(end)<2
            fidelity{b}=[fidelity{b},-y_trace(end)/2];
        elseif -y_trace(end)>=0 && -y_trace(end)<1
            fidelity{b}=[fidelity{b},-y_trace(end)];
        end
    end
end

for jj=1:11
    figure;subplot(2,2,1);plot(thi{jj},fidelity{jj},'o');title('thi')
    subplot(2,2,2);plot(thf{jj},fidelity{jj},'o');title('thf')
    subplot(2,2,3);plot(lam2{jj},fidelity{jj},'o');title('lam2')
    subplot(2,2,4);plot(lam3{jj},fidelity{jj},'o');title('lam3')
    [~,lo]=max(fidelity{jj});
    disp(sprintf('%s: maxFidelity %f , thi %f , thf %f , lam2 %f , lam3 %f \n',tags{jj},fidelity{jj}(lo),thi{jj}(lo),thf{jj}(lo),lam2{jj}(lo),lam3{jj}(lo)))
end

end