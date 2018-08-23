CPBEL calculats the lowest energy levels of a  Cooper Pair Box (CPB), Transmon and Xmon qubit.


EnergyLevels=CPBEL(Ec,Ej);			% Transmon or Xmon
EnergyLevels=CPBEL(Ec,Ej,Ng);		% Charge qubit, Transmon or Xmon
EnergyLevel=CPBEL(Ec,Ej,Ng,phi);		% Junction substituted by a SQUID
EnergyLevel=CPBEL(Ec,Ej,Ng,phi, dEj);		% Junction substituted by a SQUID, SQUID with asymmetry
EnergyLevel=CPBEL(Ec,Ej,Ng,phi, dEj,M);		% Junction substituted by a SQUID, SQUID with asymmetry. expand to M order in charge bases.


Hamiltonian	H = Ec*(N-Ng)^2 + Ej*cos(phi)

Ec=(2e)^2/(2C), 	cooper pair charge energy;
Ej, 		Josephson Energy, Ej=Ej1+Ej2 for split CPB(junction substituted by a SQUID);
Ng=CgVg/2e, 	Charge Bias, for Transmon and Xmon, energy level is charge insensative, Ng can be any value.
dEj=Ej1-Ej2, 	dEj=0 for single junction CPB;

Note: in J. Koch's paper, Ec=e^2/(2C), Hamiltonian H = 4*Ec*(N-Ng)^2 + Ej*cos(phi)


