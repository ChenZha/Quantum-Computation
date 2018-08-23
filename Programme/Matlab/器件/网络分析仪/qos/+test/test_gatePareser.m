
circuit={'S','X','X2m','X2p','Z';...
        'H','CZ','CZ','I','I';...
        'X2m','Y2p','I','CZ','CZ';...
        };
    
qubits = {'q9','q8','q7','q6','q5'};

p = sqc.op.physical.gateParser.parse(qubits,circuit);
p.Run();
%%
circuit = {'Y2p','Y2m';
    'CZ','CZ';
    'Rz(0)','Rz(3.1415)';
    '','Y2p'};
p = sqc.op.physical.gateParser.parseLogical(circuit);
P = p*[1;0;0;0];
figure();bar(conj(P).*P);