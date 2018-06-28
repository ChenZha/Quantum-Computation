%% �������ǻ��Ƶ��
g1 = 40;% ��һ�����ǿ�ȣ�MHz��
g2 = 40;% �ڶ������ǿ�ȣ�MHz��
g = 0.68;% ����ĵ�Ч���ǿ��(MHz)
w1 = 5580;% Frequency of qubit 1(MHz)
w2 = 5410;% Frequency of qubit 2(MHz)

fun = @(x)0.5*g1*g2*(1/(x-w1)+1/(x-w2))-g;

tem = 2*g/g1/g2;
% ��һ��ǻƵ��
wr1 = 1/(2*tem)*(tem*(w1+w2)+2+sqrt((tem*(w1+w2)+2)^2-4*tem*(tem*w1*w2+w1+w2)));
X = ['Frequency of resonator = ',num2str(wr1)];
disp(X);
Y = ['Diff = ',num2str(fun(wr1))];
disp(Y);
% �ڶ���ǻƵ��
wr2 = 1/(2*tem)*(tem*(w1+w2)+2-sqrt((tem*(w1+w2)+2)^2-4*tem*(tem*w1*w2+w1+w2)));
X = ['Frequency of resonator = ',num2str(wr2)];
disp(X);
Y = ['Diff = ',num2str(fun(wr2))];
disp(Y);






%% ������������˵���Cq��qubitƵ��wq���Ǽ�г��anham�£�����Ľ����
Cq = 86e-15;%�����Ľ����˵���Cq(F)
wq = 5.24;%������qubitƵ��wq(GHz)
anham = -0.25; %�����ķǼ�г�� f12-f01 (GHz)

hbar=1.054560652926899e-034;
h = 1.054560652926899e-034*2*pi;
e = 1.60217662e-19; 
Ec = e^2/2/Cq/h/10^9;
Ej = (wq+Ec)^2/8/Ec;
I = Ej*10^9*h*2*e/hbar;
R0 = 1000*(280e-9)/I;%��ʼ�²��R

[OptEc,OptEj,OptCq,OptR,OptE01,Optanham] = find_opt(Cq,R0,anham,wq);
X = ['�����=',num2str(OptR)];
disp(X);


