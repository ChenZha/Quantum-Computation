% data_taking.public.scripts.temp.LCS_3Q()
function LCS_3Q()
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.op.physical.*
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.util.getQSettings
    import sqc.util.setQSettings
    
    rAvg = 3000;
    setQSettings('r_avg',rAvg);

    qNames = {'q4','q5','q6'}; 
    dynamicPhases = data_taking.public.scripts.temp.LCS_3Q_phase(qNames);
    dynamicPhases = -(dynamicPhases-pi);
    qubits = cell(1,numel(qNames));
    for ii = 1:numel(qNames)
        qubits{ii} = qName2Obj(qNames{ii});
    end
    
    % XZXZ
    XZGateMat = {'Y2p', 'I', 'I';
              'CZ', 'CZ',  'I';
              'I',  'CZ',  'CZ';
               ['Z(',num2str(dynamicPhases(1)),')'],['Z(',num2str(dynamicPhases(2)),')'],['Z(',num2str(dynamicPhases(3)),')'];
               'Y2p', 'I',   'I';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZGateMat);
    R = resonatorReadout(qubits);
    R.delay = proc.length;

   proc.Run();
   XZData = R();
   
   XZGateMat = {'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I';
               'I',  'CZ',  'CZ';
               'Y2p','I',   'Y2p';
              };
   Pideal = sqc.op.physical.gateParser.parseLogicalProb(XZGateMat);
   hfxz = figure();bar([Pideal;XZData].');
   xlabel('|q3,q2,q1>:|000> -> |111>');
   ylabel('P');
   title('XZX');
   return;


    % XZXZ
    XZGateMat = {'Y2p', 'Y2p', 'Y2p';
              'CZ', 'CZ',  'I';
              'I(100)',   'I(100)',     'I(100)';
              'I',  'CZ',  'CZ';
               ['Rz(',num2str(dynamicPhases(1)),')'],['Rz(',num2str(dynamicPhases(2)),')'],['Rz(',num2str(dynamicPhases(3)),')'];
               'Y2p', 'I',   'Y2p';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZGateMat);
    R = resonatorReadout(qubits);
    R.delay = proc.length;

   proc.Run();
   XZData = R();
   
   XZGateMat = {'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I';
               'I',  'CZ',  'CZ';
               'Y2p','I',   'Y2p';
              };
   Pideal = sqc.op.physical.gateParser.parseLogicalProb(XZGateMat);
   hfxz = figure();bar([Pideal;XZData].');
   xlabel('|q3,q2,q1>:|000> -> |111>');
   ylabel('P');
   title('XZX');
   %% ZXZX
   ZXGateMat = {'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I';
               'I(100)',   'I(100)',     'I(100)';
               'I',  'CZ',  'CZ';
               ['Rz(',num2str(dynamicPhases(1)),')'],['Rz(',num2str(dynamicPhases(2)),')'],['Rz(',num2str(dynamicPhases(3)),')'];
               'I',   'Y2p', 'I';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,ZXGateMat);
    proc.Run();
    ZXData = R();
    ZXGateMat = {'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I';
               'I',  'CZ',  'CZ';
               'I',   'Y2p', 'I';
              };
    Pideal = sqc.op.physical.gateParser.parseLogicalProb(ZXGateMat);
    hfzx = figure();bar([Pideal;ZXData].');
    xlabel('|q3,q2,q1>:|000> -> |111>');
    ylabel('P');
    title('ZXZ');
    %% XZZ
   XZZGateMat = {'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I';
               'I(100)',   'I(100)',     'I(100)';
               'I',  'CZ',  'CZ';
               ['Rz(',num2str(dynamicPhases(1)),')'],['Rz(',num2str(dynamicPhases(2)),')'],['Rz(',num2str(dynamicPhases(3)),')'];
               'Y2p',   'I', 'I';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZZGateMat);
    proc.Run();
    XZZData = R();
    XZZGateMat = {'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I';
               'I',  'CZ',  'CZ';
               'Y2p',   'I', 'I';
              };
    Pideal = sqc.op.physical.gateParser.parseLogicalProb(XZZGateMat);
    hfxzz = figure();bar([Pideal;XZZData].');
    xlabel('|q3,q2,q1>:|000> -> |111>');
    ylabel('P');
    title('XZZ');
    %%

   QS = qes.qSettings.GetInstance();
   timeStamp = datestr(now,'_yymmddTHHMMSS_');
   rndNum = num2str(ceil(99*rand(1,1)),'%0.0f');
   datafile = fullfile(QS.loadSSettings('data_path'),...
            ['3QLCS',timeStamp,rndNum,'_.mat']);
   xzfigfile = fullfile(QS.loadSSettings('data_path'),...
            ['3QLCS',timeStamp,rndNum,'_xz.fig']);
   zxfigfile = fullfile(QS.loadSSettings('data_path'),...
            ['3QLCS',timeStamp,rndNum,'_zx.fig']);
   xzzfigfile = fullfile(QS.loadSSettings('data_path'),...
            ['3QLCS',timeStamp,rndNum,'_xzz.fig']);
   
   save(datafile,'XZData','ZXData','XZZData','qNames','XZGateMat','ZXGateMat','XZZGateMat');
   saveas(hfxz,xzfigfile);
   saveas(hfzx,zxfigfile);
   saveas(hfxzz,xzzfigfile);
end
