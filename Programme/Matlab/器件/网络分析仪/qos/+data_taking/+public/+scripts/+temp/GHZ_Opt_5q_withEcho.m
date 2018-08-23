function GHZ_Opt_5q_withEcho()
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.op.physical.*
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    rAvg = 20000;

    qNames = {'q9','q8','q7','q6','q5'};          

   qubits = cell(1,numel(qNames));
   for ii = 1:numel(qNames)
        qubits{ii} = qName2Obj(qNames{ii});
        qubits{ii}.r_avg = rAvg;
   end

   X_q9 = gate.X(qubits{1});
   Y2p_q9 = gate.Y2p(qubits{1});

   X_q8 = gate.X(qubits{2});
   Y2p_q8 = gate.Y2p(qubits{2});
   Y2m_q8 = gate.Y2m(qubits{2});
   
   X_q7 = gate.X(qubits{3});
   Y2p_q7 = gate.Y2p(qubits{3});
   Y2m_q7 = gate.Y2m(qubits{3});
   
   X_q6 = gate.X(qubits{4});
   Y2p_q6 = gate.Y2p(qubits{4});
   Y2m_q6 = gate.Y2m(qubits{4});
   
   X_q5 = gate.X(qubits{5});
   Y2p_q5 = gate.Y2p(qubits{5});
   Y2m_q5 = gate.Y2m(qubits{5});
   
   CZ = gate.CZ(qubits{3},qubits{2});
   CZLn = CZ.length;
   Xln = X_q5.length;
   
   q9ILn = 3*(CZLn + Y2p_q9.length) + Y2p_q9.length;
   Iln = floor((q9ILn - 2*Xln)/4);
   I_ = gate.I(qubits{1});
   I_.ln = Iln;
   Iie_q9 = I_*X_q9*I_*I_*X_q9;

   q8ILn = 2*(CZLn + Y2p_q9.length) + Y2p_q9.length;
   Iln = floor((q8ILn - 2*Xln)/4);
   I_ = gate.I(qubits{2});
   I_.ln = Iln;
   Iie_q8 = I_*X_q8*I_*I_*X_q8;
   
   Iln = floor((CZLn - 2*Xln)/4);
   I_ = gate.I(qubits{1});
   I_.ln = Iln;
   Icze_q5 = I_*X_q5*I_*I_*X_q5;
   
   p1 = (Y2p_q9.*Y2m_q8)*gate.CZ(qubits{1},qubits{2});
   p2 = (Y2p_q8.*Y2m_q7)*gate.CZ(qubits{3},qubits{2});
   p3 = (Y2p_q7.*Y2m_q6)*gate.CZ(qubits{3},qubits{4});
   p4 = (Y2p_q6.*Y2m_q5)*gate.CZ(qubits{5},qubits{4})*Y2p_q5;
       
   p = Iie_q8.*(p3*p4);
   p = Iie_q9.*(p2*p);
   p = p1*p;
       
   Rtomo = stateTomography(qubits);
   Rtomo.setProcess(p);
   tomoData = Rtomo();
   
   rhoIdeal = zeros(32,32);
   rhoIdeal(1,1) = 0.5;
   rhoIdeal(32,1) = 0.5;
   rhoIdeal(32,32) = 0.5;
   rhoIdeal(1,32) = 0.5;
   
   ax = qes.util.plotfcn.Rho(tomoData,[],1,true);
   qes.util.plotfcn.Rho(rhoIdeal,ax,0,false);
   
   rho = sqc.qfcns.stateTomoData2Rho(tomoData);
   fidelity = sqc.qfcns.fidelity(rho, rhoIdeal);
   title(ax(1),['fidelity: ', num2str(real(fidelity),'%0.3f')]);

   QS = qes.qSettings.GetInstance();
   timeStamp = datestr(now,'_yymmddTHHMMSS_');
   rndNum = num2str(ceil(99*rand(1,1)),'%0.0f');
   datafile = fullfile(QS.loadSSettings('data_path'),...
            ['5QGHZ_echo',timeStamp,rndNum,'_.mat']);
   figfile = fullfile(QS.loadSSettings('data_path'),...
            ['5QGHZ_echo',timeStamp,rndNum,'_.fig']);
        
   save(datafile,'tomoData','qubits');
   if ishghandle(ax(1))
       saveas(get(ax(1),'Parent'),figfile);
   end

end
