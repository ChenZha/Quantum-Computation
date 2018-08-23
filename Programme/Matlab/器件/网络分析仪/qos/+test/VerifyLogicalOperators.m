import sqc.op.logical.*
%%
%% Fig 1.1
% let the first 3 bits be data bits, the last 2 bits be measure bits:
% '|measure_bit_1,measure_bit_2,databit_3,databit_2,databit_1>'
% disp('|measure_bit_2, measure_bit_1, databit_3, databit_2, databit_1>');
InputS = QState('|00000>+|00111>');
% InputS = QState('|00001>+|00110>');
% InputS = QState('|00010>+|00101>');
% InputS = QState('|00100>+|00011>');

I = gate.I;
CXi = gate.CXi;
CIXi = CXi.SpanOver(I);
U1_1 = I.*CIXi.*I;
U1_2 = CIXi.*I.*I;
U1 = U1_2*U1_1; % step 1 is seperated in to two sub steps U1_1 and U1_2
CIIXi = CIXi.SpanOver(I);
U2_1 = I.*CIIXi;
U2_2 = CIIXi.*I;
U2 = U2_2*U2_1; % step 2 is seperated in to two sub steps U2_1 ans U2_2
U = U2*U1; % U.PlotReal; U.PlotImag
OutputS = U*InputS;
disp(['Input state: ',InputS.s]);
disp(['Output state: ',OutputS.s]);
%%
% check each measure qubit equivalent to measuring the ZZ
% operator of the two data qubits.

I = gate.I;
CXi = gate.CXi;
CIXi = CXi.SpanOver(I);
Pz0 = qops.Pz0; % the projection operator |0><0|
Pz1 = qops.Pz1; % the projection operator |1><1|
Z2Z1_ = (Pz1.*I.*I)*CIXi*(CXi.*I)*(Pz0.*I.*I); % (Pz0.*I.*I) prepares the measure qubit at |0>,
                                               % (Pz1.*I.*I) measures the data qubit
Z2Z1_.PlotReal(); % <

%% Figure 1.2
% top measure qubit:bit3; bottom measure qubit: bit4
% InputS = QState('|0000>+|1100>');
InputS = QState('|1000>+(-0.3+0.75i)|0100>');

I = gate.I;
CX = gate.CX;
CXi = gate.CXi;
H = gate.H;
% let the first 3 bits be data bits, the last 2 bits be measure bits
U1 = I.*I.*H.*I;
CIXi = CXi.SpanOver(I);
U2 = CIXi.*I;
U3 = I.*CXi.*I;
U4 = CX.SpanOver({I,H});
U5 = I.*CX.SpanOver(I);
U = U5*U4*U3*U2*U1; % U.PlotReal; U.PlotImag
OutputS = U*InputS
%%
CX = gate.CX;
CIX = CX.SpanOver(I);
H = gate.H;
Pz0 = qops.Pz0; % the projection operator |0><0|
Pz1 = qops.Pz1; % the projection operator |1><1|
X1X2_ = (Pz1.*I.*I)*(H.*I.*I)*CIX*(CX.*I)*(H.*I.*I);
% X1X2_ = (P1.*I.*I)*(H.*I.*I)*CIX*(CX.*I)*(H.*I.*I)*(P0.*I.*I);
% X1X2_ = (I.*I.*H)*CIXi*(I.*CXi)*(I.*I.*H);
X1X2_.PlotReal();

X  = gate.X;
X1X2 = X.*X;
X1X2.PlotReal;
%% Figure 4.5
InputS = QState('|00000>');

I = gate.I;
CZ = gate.CZ;
Y2 = gate.Y2;
GHZ2 = (Y2.*I)*CZ*(inv(Y2).*I);

U0 = I.*I.*I.*I.*Y2;
U1 = I.*I.*I.*GHZ2;
U2 = I.*I.*GHZ2.*I;
U3 = I.*GHZ2.*I.*I;
U4 = GHZ2.*I.*I.*I;

OutputS1 = U1*U0*InputS;
OutputS1.PlotReal;
OutputS2 = U2*U1*U0*InputS;
OutputS2.PlotReal;
OutputS3 = U3*U2*U1*U0*InputS;
OutputS3.PlotReal;
OutputS4 = U4*U3*U2*U1*U0*InputS;
OutputS4.PlotReal;

%%


