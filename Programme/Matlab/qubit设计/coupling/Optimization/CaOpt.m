function [x,fval] = CaOpt(path)
tic;
% option = optimoptions(@fmincon,'Algorithm','sqp','Display','iter');
% problem = createOptimProblem('fmincon',...
%     'objective',@(x)CaVari(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),path),...
%     'x0',[274,1.39,0.4783,10,12.19,30,0.006,23],'options',...
%     option,'lb',[50,0,0.3,1,1,5,0.001,15],'ub',[400,10,0.9,1000,20,50,0.02,30]);
% gs = GlobalSearch('Display','iter');
% rng(14,'twister'); % for reproducibility
% [x,fval] = run(gs,problem);



ObjectiveFunction = @(x)CaVari(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),path);
nvars = 8;    % Number of variables
LB = [50,0,0.3,1,1,5,0.001,15];   % Lower bound
UB = [400,10,0.9,1000,20,50,0.02,30];  % Upper bound
% option = optimoptions(@ga,'Display','iter');
rng(1,'twister') % for reproducibility
[x,fval] = ga(ObjectiveFunction,nvars,...
    [],[],[],[],LB,UB);

% ObjectiveFunction = @(x)CaVari(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),path);
% x0 = [274,1.40,0.4783,10,12.19,39.8,0.006,23];
% options = optimset('Display','iter','MaxIter',1000);
% [x,fval] = fminsearch(ObjectiveFunction,x0,options);

toc;
end
