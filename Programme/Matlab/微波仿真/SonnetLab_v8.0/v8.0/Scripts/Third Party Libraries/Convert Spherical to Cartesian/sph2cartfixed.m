function [x,y,z] = sph2cartfixed(TH,PHI,R)
%SPH2CARTFIXED Transform spherical to Cartesian coordinates.
%   [X,Y,Z] = SPH2CARTFIXED(TH,PHI,R) transforms corresponding elements of
%   data stored in spherical coordinates (azimuth PHI, elevation TH [measured 
%   from the Z axis], radius R) to Cartesian coordinates X,Y,Z.  The arrays TH, PHI, and
%   R must be the same size (or any of them can be scalar).  TH and
%   PHI must be in radians.
%
%   PHI is the counterclockwise angle in the xy plane measured from the
%   positive x axis.  TH is the angle measured from the Z axis.
%
%   Class support for inputs TH,PHI,R:
%      float: double, single
%
%   See also CART2SPH, CART2POL, POL2CART.

%   Copyright 2009 Serhend Arvas.

z = R .* cos(TH);
rho = R .* sin(TH);
x = rho .* cos(PHI);
y = rho .* sin(PHI);
