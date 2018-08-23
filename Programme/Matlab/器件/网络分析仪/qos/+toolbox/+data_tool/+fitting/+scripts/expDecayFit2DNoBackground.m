% %% load data
% load('F:\data\matlab\20161221\_170104T16111910_.mat')
% Data = Data{1};
% sz = size(Data);
% P = zeros(sz);
% P0 = zeros(sz);
% for ii = 1:sz(1)
%     for jj = 1:sz(2)
%         P(ii,jj) = Data{ii,jj}(1);
%         P0(ii,jj) = Data{ii,jj}(2);
%     end
% end
% x = SweepVals{1}{1};
% y = SweepVals{2}{1}/2e3;
% z = P-P0;
% z = z';
% figure();
% imagesc(x,y,z); set(gca,'YDir','normal'); colormap(jet);
%% data: x, y, z
time = y;
bias = x;
z = z;
nb = length(bias);

plotfit = true;

%% data: zpa, t, P, Pb
% td_estimation = 15;
% x = unique(t);
% y = unique(zpa);
% nt = length(x);
% ny = length(bias);
% p = reshape(P,[nt,ny]);
% pb = reshape(Pb,[nt,ny]);
% z = p - pb;

%%
A = NaN*ones(1,nb);
B = NaN*ones(1,nb);
td = NaN*ones(1,nb);
tf = linspace(time(1),time(end),100);
if plotfit
    figure();
    plot(NaN);
    ax = gca;
    drawnow;
end
B0 = 1; % amplitude estimation
td0 = 40000; % decay time estimation
lb = [0.8*B0, 0.05*td0];
ub = [B0/0.8, 3*td0];
for ii = 1:nb
    
    
    [B_,td_,temp] = toolbox.data_tool.fitting.expDecayFitNoBackground(time,z(ii,:),B0,td0,lb,ub);
    
    wci(ii,:) = temp(2,:); %
    B(ii) = B_;
    td(ii) = td_;
    zf = toolbox.data_tool.fitting.expDecayNoBackground([B_,td_],tf);
    if plotfit
        plot(ax, time,z(ii,:));
        hold on;
        plot(ax,tf,zf,'r');
        plot(ax,temp(2,:),[zf(end),zf(end)],'g-+');
        plot(ax,td_,zf(end),'r+');
        hold off;
        drawnow;
    end
end

%%
time = time/2/1000;
td = td/2/1000;
wci = wci/2/1000;
%%
bias2f01 = @(x)x*1e9; % in case of no bias2f01 transformation needed.
bias2f01 = @(x) polyval([-0.35328,-3.23823e4,3.99771e9],x);

figure();
h = pcolor(bias2f01(bias)/1e9,time,z'); set(h,'EdgeColor','none');
hold on;
errorbar(bias2f01(bias)/1e9,td,td-wci(:,1)',wci(:,2)'-td,'ro-','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
xlabel('f01 (GHz)');
ylabel('Time (us)');
colormap(jet);

f01 = bias2f01(bias)/1e9;
df = diff(f01);
df = [df(1),df];

mTd = mean(td);
stdTd = std(td);
ind = abs(td - mTd) < 2*stdTd;
td_ = td(ind);
df_ = df(ind);
tdAvg = sum(td_.*abs(df_))/sum(abs(df));
% tdAvg = mean(td_);
disp(['average T1: ',num2str(tdAvg)]);

