function CZPhaseCalibrationByGHz()
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    % setQSettings('r_avg',50000);
    rAvg = 10000;
    maxFEval = 20;

    qubits = {'q9','q8','q7','q6'};
    gateMat = {'Y2p','Y2m','I','I';
            'CZ','CZ','I','I';
            'I','Y2p','I','I';
            'I','I','Y2m','I';
            'I','CZ','CZ','I';
            'I','I','Y2p','I';
            'I','I','I','Y2m';
            'I','I','CZ','CZ';
            'I','I','I','Y2p'};
        
   for ii = 1:numel(qubits)
        qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        qubits{ii}.r_avg = rAvg;
   end
   
   aczSettings1 = sqc.qobj.aczSettings('q9_q8');
   aczSettings1.load();
   qubits{1}.aczSettings(end+1) = aczSettings1;
   qubits{2}.aczSettings(end+1) = aczSettings1;
   
   aczSettings2 = sqc.qobj.aczSettings('q7_q8');
   aczSettings2.load();
   qubits{2}.aczSettings(end+1) = aczSettings2;
   qubits{3}.aczSettings(end+1) = aczSettings2;
   
   aczSettings3 = sqc.qobj.aczSettings('q7_q6');
   aczSettings3.load();
   qubits{3}.aczSettings(end+1) = aczSettings3;
   qubits{4}.aczSettings(end+1) = aczSettings3;
   
   phaseQ6 = qes.expParam(aczSettings2,'dynamicPhase(3)');
   phaseQ8 = qes.expParam(aczSettings3,'dynamicPhase(3)');
   
   p = sqc.op.physical.gateParser.parse(qubits,gateMat);
   R = resonatorReadout(qubits);
   R.delay = p.length;
   
   function procFactory()
       p = sqc.op.physical.gateParser.parse(qubits,gateMat);
       p.Run();
   end
   
   R.preRunFcns = {@(x)procFactory()};
   R.datafcn = @(x) sum(x(2:end-1))-x(1)-x(end);
   
   f = qes.expFcn([phaseQ6,phaseQ8],R);
   
   x0 = [0,-pi/3;...
         -pi/3,pi/3;...
         pi/3,pi/3];
   tolX = [pi,pi]/1e3;
   tolY = [5e-3];

   h = qes.ui.qosFigure(sprintf('GHZ CZ DetuneQ phase Opt | '),false);
   axs(1) = subplot(3,1,3,'Parent',h);
   axs(2) = subplot(3,1,2);
   axs(3) = subplot(3,1,1);
   [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
   fval = y_trace(end);
   fval0 = y_trace(1);
   
   [~,ind] = min(y_trace);
   phaseQ6.val = x_trace(ind,1);
   phaseQ8.val = x_trace(ind,2);

   procFactory();
   R.datafcn = [];
   data = R();
   h1 = qes.ui.qosFigure(sprintf('GHZ CZ DetuneQ phase Opt | '),false);
   ax1 = axes(h1);
   bar(ax1,data);
   xlabel(ax1,'|0...0>,|0...1>,...,|1...1>');
   ylabel(ax1,'P');
   title(ax1,sprintf('Q6 phase: %0.3f, Q8 phase: %0.3f',x_trace(end,1),x_trace(end,2)));
   grid(ax1,'on');
   
end
