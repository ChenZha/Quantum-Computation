
% Initialization and run of differential evolution optimizer
% a more complex version with more explicit parameters is in run.m
%
% Here for Rosenbrock's function
% Change relevant entries to adapt to your personal applications
%
% The file ofunc.m must also be changed, 
% to return the objective function
%

% VTR		"Value To Reach" (stop when ofunc < VTR)
		VTR = 1.e-6; 

% D		number of parameters of the objective function 
		D = 2; 

% XVmin,XVmax   vector of lower and upper bounds of initial population
%    		the algorithm seems to work well only if [XVmin,XVmax] 
%    		covers the region where the global minimum is expected
%               *** note: these are no bound constraints!! ***
		XVmin = [-2 -2]; 
		XVmax = [2 2];

[x,f,nf] = devec3('rosen',VTR,D,XVmin,XVmax)

