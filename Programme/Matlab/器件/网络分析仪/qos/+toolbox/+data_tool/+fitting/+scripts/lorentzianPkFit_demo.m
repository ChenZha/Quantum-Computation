% This is a script to test/demonstrate 'LorentzianPkFit'
import data_tool.fitting.lorentzianPkFitAdv

datafile = 'LorentzianPkFitTestData_Sim.mat';

clc;
fulldatafile = fullfile('testdata',datafile);
% load(fulldatafile);
[y0, k1, k2, A, w, x0] = LorentzianPkFit_Adv(x,y);
if ischar(y0)
    disp(y0);
else
    fprintf('y0 = %f   k1 = %f   k2 = %f   A = %f   FWHM = %f   x0 = %f\n ',y0, k1, k2, A, w, x0);
    figure();
    L = length(x);
    step = (x(end)-x(1))/L/20;       % 20 times sampling density
    xf = x(1):step:x(end);
    yf = lorentzianAdv([y0, k1, k2, A, w, x0],xf);
    plot(x,y,'bo',xf,yf,'r-');
    legend('data','fit');
    xlabel('x','FontSize',12);
    ylabel('y','FontSize',12);
    set(gcf,'Color',[1,1,1]);
end

%% y0 = 3.705964   k1 = 4.977326   k2 = -0.184167   A = 5.739207   FWHM = 0.660738   x0 = 6.995778