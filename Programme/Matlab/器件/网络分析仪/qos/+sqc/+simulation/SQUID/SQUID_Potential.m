Ic = 1e-6;        % critical current of each junction
L = 785e-12;        % loop inductance
                    % Ic = 0.5e-6;  L = 200e-12; BetaL = 0.0967;
FluxQuantum  = 2.0678e-15;
Ibias = 0*2*Ic;     % current bias
FluxBias=0*FluxQuantum;
BetaL = 2*Ic*L/FluxQuantum;
E_LdbE_J = FluxQuantum/(2*Ic*L*pi)  % E_L/E_J
      % E_L =2/L * (FluxQuantum/(2*pi))^2; E_J = 2 * I_c*FluxQuantum/(2*pi)
            
Phase1=-0.6*pi:0.02:0.8*pi;            % Phase1:      Phi+ = (phi_1 + phi_2)/2
Phase2=-0.5:0.2:2.5*pi;               % Phase2:      Phi- = (phi_1 - phi_2)/2       
U = ones(length(Phase1),length(Phase2));
for k=1:length(Phase2)
    U(:,k) = (Phase1- pi*FluxBias/FluxQuantum).^2/(pi*BetaL) - cos(Phase1)*cos(Phase2(k)) - Ibias*Phase2(k)/(2*Ic);
    % Divided by 2Ej. 
end
figure(85);
surf(Phase2/pi,Phase1/pi,U);
xlabel('\phi_-   (\pi)');
ylabel('\phi_+   (\pi)');
zlabel('U/2E_J');
title('dcSQUID Potential');
view(60,45);