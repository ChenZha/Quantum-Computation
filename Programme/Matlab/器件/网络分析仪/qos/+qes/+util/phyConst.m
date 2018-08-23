classdef (Sealed = true) phyConst < handle
% Physical constants

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (Constant = true)
        c = 299792458       % speed of light in vacuum
        h = 6.62606957e-34;      % Planck constant
        hbar = 1.054571726e-34;  % reduced Planck constant
        e = 1.602176565e-19;	% elementary charge
        phi_0 = 2.067833758e-15;               % magnetic flux quantum
        k_b = 1.3806488e-23;                 % Boltzmann constant
        mu_0 = 1.256637061e-6;              % magnetic constant
        mu_b = 9.27400968e-24;               % Bohr magneton
        eps_0 = 8.854187817e-12;               % electric constant
        z_0 = 376.730313461;        % impedance of vacuum
    end
end