function result = rosen(x,y);
% Objective function for Differential Evolution
%
% Input Arguments:   
% ---------------
% x                  : parameter vector to be optimized
% y                  : data vector (remains fixed during optimization)
%
% Output Arguments:
% ----------------
% result              : objective function value
%


%-----Rosenbrock's saddle------------------
 result = 100*(x(2)-x(1)^2)^2+(1-x(1))^2;
