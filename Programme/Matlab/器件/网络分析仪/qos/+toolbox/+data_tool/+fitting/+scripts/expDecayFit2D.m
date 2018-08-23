%% data: x, y, z
time = y;
bias = x;
z = abs(z);
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
for ii = 1:nb
%     A0 = mean(z(ii,end));
%     B0 = mean(z(ii,1)) - A0;
    A0 = 0.05;
    B0 = 0.7;
    td0 = 10;
    lb = [A0-0.3*B0, 0.6*B0, 0.2*td0];
    ub = [A0+0.3*B0, B0/0.6, 2*td0];
    
    [A_,B_,td_,temp] = toolbox.data_tool.fitting.expDecayFit(time,z(ii,:),A0,B0,td0,lb,ub);
    
%     [A_,B_,td_,temp] = ExpDecayFit(time,z(ii,:));
    
    clc;
    wci(ii,:) = temp(3,:); %
    A(ii) = A_;
    B(ii) = B_;
    td(ii) = td_;
    zf = toolbox.data_tool.fitting.expDecay([A_,B_,td_],tf);
    if plotfit
        plot(ax, time,z(ii,:));
        hold on;
        plot(ax,tf,zf,'r');
        plot(ax,temp(3,:),[zf(end),zf(end)],'g-+');
        plot(ax,td_,zf(end),'r+');
        hold off;
        drawnow;
    end
end

time = time/1e3;
td = td/1e3;
wci = wci/1e3;

figure();
imagesc(bias,time,z');
hold on;
errorbar(bias,td,td-wci(:,1)',wci(:,2)'-td,'ro-','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
set(gca,'YDir','normal');
xlabel('Z Bias');
ylabel('Time (us)');
colormap(haxby)

