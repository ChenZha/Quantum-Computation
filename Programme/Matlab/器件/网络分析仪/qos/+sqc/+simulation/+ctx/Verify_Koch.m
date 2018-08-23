% J. Koch. Phys. Rev. A 76, 042319(2007)
import sqc.simulation.ctx.CPBEL

% (a) Ej/Ec = 1,
Ej = 1;
Ec = Ej/1;
Ng= -2:0.1:2;
NumNg = length(Ng);
EL = NaN*ones(3,NumNg);
for ii = 1:NumNg
    el=CPBEL(4*Ec,Ej,Ng(ii));
    EL(:,ii) = el(1:3);
end
idx = find(Ng == 0.5,1);
y = EL - min(EL(1,:));
y = y/(y(2,idx)-y(1,idx));
figure();
subplot(2,2,1)
plot(Ng,y(1,:),Ng,y(2,:),Ng,y(3,:));

% (b) Ej/Ec = 5,
Ej = 1;
Ec = Ej/5;
Ng= -2:0.1:2;
NumNg = length(Ng);
EL = NaN*ones(3,NumNg);
for ii = 1:NumNg
    el=CPBEL(4*Ec,Ej,Ng(ii));
    EL(:,ii) = el(1:3);
end
idx = find(Ng == 0.5,1);
y = EL - min(EL(1,:));
y = y/(y(2,idx)-y(1,idx));
subplot(2,2,2)
plot(Ng,y(1,:),Ng,y(2,:),Ng,y(3,:));

% (c) Ej/Ec = 10,
Ej = 1;
Ec = Ej/10;
Ng= -2:0.1:2;
NumNg = length(Ng);
EL = NaN*ones(3,NumNg);
for ii = 1:NumNg
    el=CPBEL(4*Ec,Ej,Ng(ii));
    EL(:,ii) = el(1:3);
end
idx = find(Ng == 0.5,1);
y = EL - min(EL(1,:));
y = y/(y(2,idx)-y(1,idx));
subplot(2,2,3)
plot(Ng,y(1,:),Ng,y(2,:),Ng,y(3,:));

% (d) Ej/Ec = 50,
Ej = 1;
Ec = Ej/50;
Ng= -2:0.1:2;
NumNg = length(Ng);
EL = NaN*ones(3,NumNg);
for ii = 1:NumNg
    el=CPBEL(4*Ec,Ej,Ng(ii));
    EL(:,ii) = el(1:3);
end
idx = find(Ng == 0.5,1);
y = EL - min(EL(1,:));
y = y/(y(2,idx)-y(1,idx));
subplot(2,2,4)
plot(Ng,y(1,:),Ng,y(2,:),Ng,y(3,:));
