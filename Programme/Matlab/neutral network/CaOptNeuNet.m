function target = CaOptNeuNet(path)

tic;
ParaNum = 7;
num = 12;
%%
fileID = fopen(path);
inputdata = textscan(fileID,'%f %f');
I = inputdata{1};
V = inputdata{2};
fclose(fileID);
[~,idx] = min(V);
Imin = I(idx);
len = length(I);
%%
input = zeros(num,len)';%输出的能级
output = zeros(num,ParaNum)';%输入的参数
parfor i = 1:num    %一组数据放在一列
    III = I;
    Ej = 70+rand(1)*230;    Ec = 1+rand(1)*8;   alpha = 0.5+rand(1)*0.5;    beta = 1+rand(1)*99;    Cc = 1+rand(1)*14;  Csh = 10+40*rand(1);
    k = rand()*10;
    output1 = [Ej,Ec,alpha,beta,Cc,Csh,k];
    output(:,i) = output1';
    input1 = zeros(len,1);
    for j = 1:len
        II = III(j);
        FluxBias = output1(7)*(II-Imin)+0.5;
        [EL,~] = CaFluxQubit(output1(1)*10^9,output1(2)*10^9,output1(3),output1(4)*10^(-6),0,0,output1(5)*10^(-15),777.51e-15,output1(6)*10^(-15),FluxBias,5,10,2,20);
        el02 = (EL(5)-EL(1))/10^9;
        input1(j) = el02;
    end
    input(:,i) = input1;
end
disp('初始化结束');
save('input.mat','input');
save('output.mat','output');
%%
[inputn,inputps] = mapminmax(input);
[outputn,outputps] = mapminmax(output);
net = fitnet(10);
net.trainFcn='trainlm'; %设置训练方法及参数 
net.trainParam.epochs=100; 
net.trainParam.lr = 0.1;
net.trainParam.goal=1e-6;
net = train(net,inputn,outputn);

inputV = mapminmax('apply',V,inputps);
targetMM = net(inputV);
target = mapminmax('reverse',targetMM,outputps);

save('TrainedNet', 'net');
%%
test = zeros(1,len);
parfor j = 1:len
        II = I(j);
        FluxBias = target(7)*(II-Imin)+0.5;
        [EL,~] = CaFluxQubit(target(1)*10^9,target(2)*10^9,target(3),target(4)*10^(-6),0,0,target(5)*10^(-15),777.51e-15,target(6)*10^(-15),FluxBias,5,10,2,20);
        el02 = (EL(5)-EL(1))/10^9;
        test(j) = el02;
end
figure();
plot(V,':og');hold on;
plot(test,'-*');
toc;

end