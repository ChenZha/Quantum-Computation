
% Initialization and run of differential evolution optimizer.
% A simpler version with fewer explicit parameters is in run0.m
%
% Here for Rosenbrock's function
% Change relevant entries to adapt to your personal applications
%
% The file ofunc.m must also be changed 
% to return the objective function
%

% VTR		"Value To Reach" (stop when ofunc < VTR)
		VTR = 1.e-6; 

% D		number of parameters of the objective function 
		D = 2; 

% XVmin,XVmax   vector of lower and bounds of initial population
%    		the algorithm seems to work well only if [XVmin,XVmax] 
%    		covers the region where the global minimum is expected
%               *** note: these are no bound constraints!! ***
		XVmin = [-2 -2]; 
		XVmax = [2 2];

% y		problem data vector (remains fixed during optimization)
		y=[]; 

% NP            number of population members
		NP = 15; 

% itermax       maximum number of iterations (generations)
		itermax = 200; 

% F             DE-stepsize F ex [0, 2]
		F = 0.8; 

% CR            crossover probabililty constant ex [0, 1]
		CR = 0.8; 

% strategy       1 --> DE/best/1/exp           6 --> DE/best/1/bin
%                2 --> DE/rand/1/exp           7 --> DE/rand/1/bin
%                3 --> DE/rand-to-best/1/exp   8 --> DE/rand-to-best/1/bin
%                4 --> DE/best/2/exp           9 --> DE/best/2/bin
%                5 --> DE/rand/2/exp           else  DE/rand/2/bin

		strategy = 7

% refresh       intermediate output will be produced after "refresh"
%               iterations. No intermediate output will be produced
%               if refresh is < 1
		refresh = 10; 

[x,f,nf] = devec3('rosen',VTR,D,XVmin,XVmax,y,NP,itermax,F,CR,strategy,refresh)

