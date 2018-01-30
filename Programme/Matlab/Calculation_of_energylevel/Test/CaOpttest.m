function [x,fval] = CaOpttest(path)
tic;
% option = optimoptions(@fmincon,'Algorithm','sqp','Display','iter');
% problem = createOptimProblem('fmincon',...
%     'objective',@(x)CaVari(x(1),x(2),x(3),x(4),x(5),x(6),x(7),path),...
%     'x0',[148,3.29,0.513,10,12.19,30,2],'options',...
%     option,'lb',[70,1,0.4,1,1,10,0]],'ub',[300,8,0.9,1000,15,50,10]);
% gs = GlobalSearch('Display','iter');
% rng(14,'twister'); % for reproducibility
% [x,fval] = run(gs,problem);



% ObjectiveFunction = @(x)CaVari(x(1),x(2),x(3),x(4),x(5),x(6),x(7),path);
% nvars = 7;    % Number of variables
% LB = [70,1,0.4,1,1,10,0];   % Lower bound
% UB = [300,8,0.9,1000,15,50,10];  % Upper bound
% rng(1,'twister') % for reproducibility
% [x,fval] = ga(ObjectiveFunction,nvars,...
%     [],[],[],[],LB,UB);
ObjectiveFunction = @(x)CaVari(x(1),x(2),x(3),x(4),x(5),x(6),x(7),x(8),path);
x0 = [150,3.29,0.813,10,12.19,40,2,1.93];
options = optimset('Display','iter','MaxIter',600);
[x,fval] = fminsearch(ObjectiveFunction,x0,options);

toc;
end
