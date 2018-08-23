%% GHz
gateMat = {'Y2p','Y2m','I',  'I',  'I';
            'CZ','CZ',  'I',  'I',  'I';
            'I','Y2p','Y2m',  'I',  'I';
            'I','CZ',  'CZ',  'I', 'I';
            'I','I',  'Y2p','Y2m', 'I';
            'I','I',  'CZ',  'CZ', 'I';
            'I','I',  'I',  'Y2p','Y2m';
            'I','I',  'I',   'CZ','CZ';
            'I','I',  'I',    'I','Y2p'};
p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
figure();bar(p);
%%
gateMat = {'Y2p','Y2p', 'Y2p', 'Y2p','Y2p';
            'CZ','CZ',  'I',  'I',  'I';
            'I','CZ',  'CZ',  'I',  'I';
            'I','I',  'CZ',  'CZ',  'I';
            'I','I',  'I',   'CZ',  'CZ';
            'Y2p','I', 'Y2p', 'I', 'Y2p'};
p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
figure();bar(p);

gateMat = {'Y2p','Y2p', 'Y2p', 'Y2p','Y2p';
            'CZ','CZ',  'I',  'I',  'I';
            'I','CZ',  'CZ',  'I',  'I';
            'I','I',  'CZ',  'CZ',  'I';
            'I','I',  'I',   'CZ',  'CZ';
            'I','Y2p', 'I', 'Y2p', 'I'};
p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
figure();bar(p);

%% 11 Qs
gateMat = {'Y2p', 'Y2p', 'Y2p', 'Y2p','Y2p','Y2p','Y2p', 'Y2p', 'Y2p','Y2p','Y2p';
            'CZ', 'CZ',  'I',   'CZ', 'CZ', 'I',  'I',   'CZ',  'CZ', 'I',  'I';
            'I',  'CZ',  'CZ',  'I',  'I',  'CZ', 'CZ',  'I',   'I',  'CZ', 'CZ';
            'I',  'I',   'CZ',  'CZ', 'I',  'I',  'CZ',  'CZ',  'I',  'I',  'I';
            'Y2p','I',   'Y2p', 'I',  'Y2p','I',  'Y2p', 'I',   'Y2p','I',  'Y2p';
            };
p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
figure();bar(p);
%%
gateMat = {'Y2p', 'Y2p', 'Y2p', 'Y2p','Y2p','Y2p','Y2p', 'Y2p', 'Y2p','Y2p','Y2p';
            'CZ', 'CZ',  'I',   'CZ', 'CZ', 'I',  'I',   'CZ',  'CZ', 'I',  'I';
            'I',  'CZ',  'CZ',  'I',  'I',  'CZ', 'CZ',  'I',   'I',  'CZ', 'CZ';
            'I',  'I',   'CZ',  'CZ', 'I',  'I',  'CZ',  'CZ',  'I',  'I',  'I';
            'I',  'Y2p', 'I',   'Y2p','I',  'Y2p','I',   'Y2p', 'I',  'Y2p','I';
            };
p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
figure();bar(p);