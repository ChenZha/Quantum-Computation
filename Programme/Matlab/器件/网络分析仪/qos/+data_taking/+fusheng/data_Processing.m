
Nlist=[2,3,5,7,9];
n=length(Nlist);

raw_data=zeros(n,10);
fdllist=zeros(1,n);
stdlist=zeros(1,n);

% raw data
raw_data(1,:)=ones(1,10);

raw_data(2,:)=[0.9329    0.9637    0.9718    0.9951    0.9385...
    0.9926   0.9801    0.9684    0.9343    0.9327];

raw_data(3,:)=[0.9300    0.9550    0.9731    0.9141    0.9568...
     0.9304    0.9556    0.9495    0.9516    0.9342];
raw_data(4,:)=[0.8496    0.9094    0.9554    0.8918    0.9274...
    0.9766    1.0038    0.9189    0.9127    0.9359];
raw_data(5,:)=[0.6787    0.6974    0.6649    0.6723    0.6202...
    0.6626    0.7095    0.6170    0.6889    0.6166];

% raw_data(6,:)=[0.4382    0.4345    0.3679   0.4382    0.4345...
%     0.3679    0.3476    0.3500    0.2960    0.4856];

% processing
fdllist=mean(raw_data');
stdlist=std(raw_data');

% plot
figure();
plot(Nlist,fdllist);
xlabel('N');
ylabel('Ghz fidelity');
% todo : add  std errorbar