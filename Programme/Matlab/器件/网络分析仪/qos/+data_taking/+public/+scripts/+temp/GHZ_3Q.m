% data_taking.public.scripts.temp.GHZ_3Q()
function GHZ_3Q()
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.op.physical.*
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.util.getQSettings
    import sqc.util.setQSettings
    
    rAvg = 5000;
    setQSettings('r_avg',rAvg);
    qNames = {'q1','q2','q3'};          
    gateMat = {'Y2p','Y2m','I';
               'CZ','CZ',  'I';
               'I','Y2p','Y2m';
               'I','CZ',  'CZ';
               'I','I',  'Y2p';};

   qubits = cell(1,numel(qNames));
   for ii = 1:numel(qNames)
        qubits{ii} = qName2Obj(qNames{ii});
   end

   Rtomo = stateTomography(qubits);
   Rtomo.setProcess(sqc.op.physical.gateParser.parse(qubits,gateMat));
   numReps = 4;
   tomoData = cell(1,numReps);
   for ii = 1:numReps
       tomoData{ii} = Rtomo();
   end
   
   tomoData_m = tomoData{1};
   for ii = 2:numReps
       tomoData_m = tomoData_m + tomoData{ii};
   end
   tomoData_m = tomoData_m/numReps;
   
   rhoIdeal = zeros(8,8);
   rhoIdeal(1,1) = 0.5;
   rhoIdeal(8,1) = 0.5;
   rhoIdeal(8,8) = 0.5;
   rhoIdeal(1,8) = 0.5;
   
   ax = qes.util.plotfcn.Rho(tomoData_m,[],1,true);
   qes.util.plotfcn.Rho(rhoIdeal,ax,0,false);
   
   rho = sqc.qfcns.stateTomoData2Rho(tomoData_m);
   fidelity = sqc.qfcns.fidelity(rho, rhoIdeal);
   title(ax(1),['fidelity: ', num2str(real(fidelity),'%0.3f')]);

   QS = qes.qSettings.GetInstance();
   timeStamp = datestr(now,'_yymmddTHHMMSS_');
   rndNum = num2str(ceil(99*rand(1,1)),'%0.0f');
   datafile = fullfile(QS.loadSSettings('data_path'),...
            ['3QGHZ',timeStamp,rndNum,'_.mat']);
   figfile = fullfile(QS.loadSSettings('data_path'),...
            ['3QGHZ',timeStamp,rndNum,'_.fig']);
        
   save(datafile,'tomoData','qubits','gateMat');
   if ishghandle(ax(1))
       saveas(get(ax(1),'Parent'),figfile);
   end

end
