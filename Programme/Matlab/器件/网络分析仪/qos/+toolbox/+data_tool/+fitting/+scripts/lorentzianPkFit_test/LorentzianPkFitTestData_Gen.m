% Generate test data for 'LorentzianPkFit_main'
clc;
x = 5:0.02:11;
x1 = x(1):(x(end)-x(1))/1000:x(end);

    y0 = 3;
    k1 = 5.2;
    k2 = -0.2;
    A = 5;
    w = 0.6;
    x0 = x(1)+(x(end) - x(1))*2/6;
    
y = LorPkfun([y0, k1, k2, A, w, x0],x);
y = y + 0.2*A*randn(size(x));
y1 = LorPkfun([y0, k1, k2, A, w, x0],x1);
figure();
plot(x1,y1,'r-',x,y,'bo');
xlabel('x','FontSize',12);
ylabel('y','FontSize',12);
legend('Embedded signal','Signal corrupted by zero-mean random noise')
set(gcf,'Color',[1,1,1]);
save('LorentzianPkFitTestData_Sim.mat');
    