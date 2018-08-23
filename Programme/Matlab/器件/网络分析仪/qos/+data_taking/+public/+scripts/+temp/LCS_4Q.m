% data_taking.public.scripts.temp.LCS_4Q()
function LCS_4Q()
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.op.physical.*
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.util.getQSettings
    import sqc.util.setQSettings
    
    rAvg = 5000;
    setQSettings('r_avg',rAvg);
    
    qNames = {'q1','q2','q3','q4'}; 
    qubits = cell(1,numel(qNames));
    for ii = 1:numel(qNames)
        qubits{ii} = qName2Obj(qNames{ii});
    end
    %% XZXZ
    XZGateMat = {'Y2p', 'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I',   'I';
               'I',  'CZ',  'CZ',  'I';
               'I',  'I',   'CZ',  'CZ';
               'Y2p','I',   'Y2p', 'I';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,XZGateMat);
    R = resonatorReadout(qubits);
    R.delay = proc.length;

   proc.Run();
   XZData = R();
   Pideal = sqc.op.physical.gateParser.parseLogicalProb(XZGateMat);
   hfxz = figure();bar([Pideal;XZData].');
   xlabel('|q4,q3,q2,q1>:|0000> -> |1111>');
   ylabel('P');
   title('XZXZ');
   %% ZXZX
   ZXGateMat = {'Y2p', 'Y2p', 'Y2p', 'Y2p';
               'CZ', 'CZ',  'I',   'I';
               'I',  'CZ',  'CZ',  'I';
               'I',  'I',   'CZ',  'CZ';
               'I','Y2p',   'I', 'Y2p';
              };
    proc = sqc.op.physical.gateParser.parse(qubits,ZXGateMat);
    proc.Run();
    ZXData = R();
    Pideal = sqc.op.physical.gateParser.parseLogicalProb(ZXGateMat);
    hfzx = figure();bar([Pideal;ZXData].');
    xlabel('|q4,q3,q2,q1>:|0000> -> |1111>');
    ylabel('P');
    title('ZXZX');
    %%

   QS = qes.qSettings.GetInstance();
   timeStamp = datestr(now,'_yymmddTHHMMSS_');
   rndNum = num2str(ceil(99*rand(1,1)),'%0.0f');
   datafile = fullfile(QS.loadSSettings('data_path'),...
            ['4QLCS',timeStamp,rndNum,'_.mat']);
   xzfigfile = fullfile(QS.loadSSettings('data_path'),...
            ['4QLCS',timeStamp,rndNum,'_xz.fig']);
   zxfigfile = fullfile(QS.loadSSettings('data_path'),...
            ['4QLCS',timeStamp,rndNum,'_zx.fig']);
   
   save(datafile,'XZData','ZXData','qNames','XZGateMat','ZXGateMat');
   saveas(hfxz,xzfigfile);
   saveas(hfzx,zxfigfile);

end
