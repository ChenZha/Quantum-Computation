% function para=T1_fit(x,y,beta0)
% modelfun=@(a,x)(a(1)*exp(-x/a(2))*sin(2*pi/a(3)*x+a(4))+a(5));
% 
% para=nlinfit(x,y,modelfun,beta0);
% 
% figure;
% scatter(x,y);
% hold on;
% plot(x,para(1)*exp(-x/para(2))*sin(2*pi/a(3)*x+a(4))+a(5));
% title(['t2:',num2str(para(2)/2000),'us'])
% end

function [fitresult, gof] = T2_fit(x, y, beta0)
%CREATEFIT(X,Y)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a*exp(-x/b)*sin(2*pi/c*x+d)+e', 'independent', 'x', 'dependent', 'y' );
% ft = fittype( 'a*exp(-x/b-(x/c)^2)*sin(2*pi/d*x+e)+f', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = beta0;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
% disp(fitresult.b);
% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'y vs. x', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel('time');
ylabel('P|1>');
title(['T2:',num2str(fitresult.b/2000),'us','       detuning:',num2str(1/(fitresult.c/2000)),'Mhz'])
grid on


