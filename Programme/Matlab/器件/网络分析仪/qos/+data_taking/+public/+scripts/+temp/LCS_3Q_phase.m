% data_taking.public.scripts.temp.LCS_3Q_phase()
function dynamicPhases = LCS_3Q_phase(qNames)
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.op.physical.*
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.util.getQSettings
    import sqc.util.setQSettings
    
    rAvg = 5000;
    setQSettings('r_avg',rAvg);
    
    qubits = cell(1,numel(qNames));
    for ii = 1:numel(qNames)
        qubits{ii} = qName2Obj(qNames{ii});
    end
    
    dynamicPhases = zeros(1,3);
    %%
    XZGateMat = {'Y2p', 'I', 'I';
               'CZ', 'CZ',  'I';
               'I(100)',   'I(100)',     'I(100)';
               'I',  'CZ',  'CZ';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZGateMat);
    R = phase(qubits{1});
    R.setProcess(proc);

   dynamicPhases(1) = R();
   %%
   XZGateMat = {'I', 'Y2p', 'I';
               'CZ', 'CZ',  'I';
               'I(100)',   'I(100)',     'I(100)';
               'I',  'CZ',  'CZ';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZGateMat);
    R = phase(qubits{2});
    R.setProcess(proc);

   dynamicPhases(2) = R();
   
   %%
   XZGateMat = {'I', 'I', 'Y2p';
               'CZ', 'CZ',  'I';
               'I(100)',   'I(100)',     'I(100)';
               'I',  'CZ',  'CZ';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZGateMat);
    R = phase(qubits{3});
    R.setProcess(proc);

   dynamicPhases(3) = R();
end
