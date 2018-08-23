% SQUID Circulating Current
Ic = 0.5e-6;        % critical current of each junction
L = 200e-12;        % loop inductance
                    % Ic = 0.5e-6;  L = 200e-12; BetaL = 0.0967;
FluxQuantum  = 2.0678e-15;
Ibias = 0*2*Ic;     % current bias
N = 600;            % calculate N dots to plot the curve
FluxBias = linspace(-1.2,1.2,N)*FluxQuantum;
                    % linspace(?,?,N), Flux Bias Range.
BetaL = 2*Ic*L/FluxQuantum;
for kk = 1:N
Potential = @(x)x(1)^2/(pi*BetaL) - cos(x(1) + pi*FluxBias(kk)/FluxQuantum)*cos(x(2)) - Ibias*x(2)/(2*Ic);
    % Divided by 2Ej. 
    % x(1) = PhiMinus - pi*FluxBias(kk)/FluxQuantum; x(2):PhiPlus;
    % PhiMinus = (Phi1 - Phi2)/2; PhiPlus  = (Phi1 + Phi2)/2;
temp = fminsearch(Potential,[0,0]); 
    % fminsearch(Potential,[?,?]);
S(kk) = temp(1);
end
IcircD2Ic = 2*S*FluxQuantum/(2*pi*L*2*Ic);
figure(3653);
plot(FluxBias/FluxQuantum,IcircD2Ic);
xlabel('Flux Bias (\Phi_0)');
ylabel('I_{circ.}/I_{c-squid}');
title('SQUID Circulating Current');
hold on;
