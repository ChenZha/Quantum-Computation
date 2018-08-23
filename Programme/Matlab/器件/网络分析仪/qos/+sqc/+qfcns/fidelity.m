function f = fidelity(rho, rhoIdeal)
% state fidelity, rho, rhoIdeal are density matrixes

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

%% I Nielsen & Chuang
%     
% 	r = sqrtm(rhoIdeal);
% 	f = trace(sqrtm(r*rho*r));

    
%% II
    m = rho*rhoIdeal;
    f = trace(m);
    f = sqrt(real(f));
    
end