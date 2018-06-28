%% 计算耦合腔的频率
g1 = 40;% 第一个耦合强度（MHz）
g2 = 40;% 第二个耦合强度（MHz）
g = 0.68;% 需求的等效耦合强度(MHz)
w1 = 5580;% Frequency of qubit 1(MHz)
w2 = 5410;% Frequency of qubit 2(MHz)

fun = @(x)0.5*g1*g2*(1/(x-w1)+1/(x-w2))-g;

tem = 2*g/g1/g2;
% 第一个腔频解
wr1 = 1/(2*tem)*(tem*(w1+w2)+2+sqrt((tem*(w1+w2)+2)^2-4*tem*(tem*w1*w2+w1+w2)));
X = ['Frequency of resonator = ',num2str(wr1)];
disp(X);
Y = ['Diff = ',num2str(fun(wr1))];
disp(Y);
% 第二个腔频解
wr2 = 1/(2*tem)*(tem*(w1+w2)+2-sqrt((tem*(w1+w2)+2)^2-4*tem*(tem*w1*w2+w1+w2)));
X = ['Frequency of resonator = ',num2str(wr2)];
disp(X);
Y = ['Diff = ',num2str(fun(wr2))];
disp(Y);






%% 计算给定结两端电容Cq，qubit频率wq，非简谐性anham下，所需的结电阻
Cq = 86e-15;%给定的结两端电容Cq(F)
wq = 5.24;%给定的qubit频率wq(GHz)
anham = -0.25; %给定的非简谐性 f12-f01 (GHz)

hbar=1.054560652926899e-034;
h = 1.054560652926899e-034*2*pi;
e = 1.60217662e-19; 
Ec = e^2/2/Cq/h/10^9;
Ej = (wq+Ec)^2/8/Ec;
I = Ej*10^9*h*2*e/hbar;
R0 = 1000*(280e-9)/I;%初始猜测的R

[OptEc,OptEj,OptCq,OptR,OptE01,Optanham] = find_opt(Cq,R0,anham,wq);
X = ['结电阻=',num2str(OptR)];
disp(X);


