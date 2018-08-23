function CZPhaseCalibrationByGHz2Q(qubits,numCNOT,rAvg,maxFEval,save)
    import sqc.measure.*
    import sqc.util.qName2Obj
    import sqc.op.physical.*
    
    if nargin < 5
        save = false;
    end
    
    numCNOT = round(numCNOT);
    assert(2*floor(numCNOT/2) ~= numCNOT && numCNOT > 0); % positive odd
%     
%     % setQSettings('r_avg',50000);
%     rAvg = 10000;
%     maxFEval = 50;
    
    for ii = 1:numel(qubits)
        qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        qubits{ii}.r_avg = rAvg;
    end
    
   aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
   aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
   try
       aczSettings.load();
   catch
       qubits = qubits([2,1]);
       aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
       aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
       aczSettings.load();
   end
   qubits{1}.aczSettings(end+1) = aczSettings;
   qubits{2}.aczSettings(end+1) = aczSettings;
   
   phaseQ1 = qes.expParam(aczSettings,'dynamicPhase(1)');
   phaseQ2 = qes.expParam(aczSettings,'dynamicPhase(2)');
   
   R = resonatorReadout(qubits);
   
   Y2m = gate.Y2m(qubits{1});
   function procFactory()
       CNOT = sqc.op.physical.gate.CNOT(qubits{1},qubits{2});
       p = Y2m*CNOT^numCNOT;
       p.Run();
       R.delay = p.length;
   end
   
   Pideal = [0.5,0,0,0.5];
   
   R.preRunFcns = {@(x)procFactory()};
   R.datafcn = @(x) norm(x - Pideal);
   
   f = qes.expFcn([phaseQ1,phaseQ2],R);
   
   x0 = [0,-pi/3;...
         -pi/3,pi/3;...
         pi/3,pi/3];
   tolX = [pi,pi]/1e3;
   tolY = [5e-3];

   h = qes.ui.qosFigure(sprintf('GHZ CZ phase Opt | '),false);
   axs(1) = subplot(3,1,3,'Parent',h);
   axs(2) = subplot(3,1,2);
   axs(3) = subplot(3,1,1);
   [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
   fval = y_trace(end);
   fval0 = y_trace(1);
   
   [~,ind] = min(y_trace);
   phaseQ1.val = x_trace(ind,1);
   phaseQ2.val = x_trace(ind,2);
   
   if save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},...
								aczSettings.dynamicPhase);
   end

   procFactory();
%    CNOT_t = sqc.op.physical.gate.CNOT(qubits{1},qubits{2});
%    p = Y2m*CNOT_t;
%    p.Run();
   
   R.datafcn = [];
   data = R();
   h1 = qes.ui.qosFigure(sprintf('GHZ CZ phase Opt | '),false);
   ax1 = axes(h1);
   bar(ax1,data);
   xlabel(ax1,sprintf('|%s,%s>',qubits{1}.name, qubits{2}.name));
   ylabel(ax1,'P');
   set(ax1,'XTick',[1,2,3,4],'XTickLabel',{'|00>','|01>','|10>','|11>'});
   title(ax1,sprintf('%s phase: %0.3f, %s phase: %0.3f',qubits{1}.name, x_trace(ind,1),qubits{2}.name,x_trace(ind,2)));
   grid(ax1,'on');
   
end
