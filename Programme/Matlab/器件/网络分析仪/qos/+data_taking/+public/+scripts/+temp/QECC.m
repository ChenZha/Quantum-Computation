function QECC()
    import sqc.measure.*
    import sqc.util.qName2Obj
    
    import sqc.op.physical.*
    import sqc.measure.*
    import sqc.util.qName2Obj
    import sqc.util.setQSettings
    QS = qes.qSettings.GetInstance();
    
    rAvg = 20000;
    maxFEval = 150;

    qubits = {'q9','q8','q7','q6','q5'};
    S='S';H='H';CZ='CZ';I='I';Sd='Sd';
    mX='Y2p';mY='X2m';mZ='I';mI='I';

    Y2p='Y2p';Y2m='Y2m';
    % circuit 2
%     gateMat = { S,  H,  H,  H,  H;...
%                 H,  CZ, CZ, I,  I;...
%                 I,  I,  I,  CZ, CZ;...
%                 CZ, CZ, I,  I,  S;...
%                 I,  I,  CZ, CZ, I;...
%                 H,  S,  S,  H,  I;...
%                 S,  I,  H,  Sd, I;...
%                 H,  I,  CZ, CZ, I;...
%                 I,  I,  H,  H,  I;...
%                 I,  I,  CZ, CZ, I;...
%                 I,  I,  H,  H,  I;...
%                 I,  I,  CZ, CZ, I;...
%                 I,  CZ, CZ, I,  I;...
%                 I,  H,  H,  I,  I;...
%                 I,  CZ, CZ, I,  I;...
%                 I,  H,  H,  I,  I;...
%                 CZ, CZ, I,  I,  I;...
%                 H,  Sd, I,  I,  I;...
%                 I,  H,  I,  I,  I;...
%                 I,  CZ, CZ, I,  I;...
%                 I,  H,  Sd, I,  I;...
%                 I,  S,  H,  I,  I;...
%                 I,  H,  I,  I,  I};


    gateMat = { S,  mX, mX, mX, mX;...
                mX, CZ, CZ, I,  I;...
                I,  I,  I,  CZ, CZ;...
                CZ, CZ, I,  I,  S;...
                I,  I,  CZ, CZ, I;...
                mX, S,  S,  mX,  I;...
                S,  I,  mX, Sd, I;...
                H,  I,  CZ, CZ, I;...
                I,  I,  mX, mX,  I;...
                I,  I,  CZ, CZ, I;...
                I,  I,  mX, mX,  I;...
                I,  I,  CZ, CZ, I;...
                I,  CZ, CZ, I,  I;...
                I,  mX, mX, I,  I;...
                I,  CZ, CZ, I,  I;...
                I,  mX, H,  I,  I;...
                CZ, CZ, I,  I,  I;...
                H,  Sd, I,  I,  I;...
                I,  mX, I,  I,  I;...
                I,  CZ, CZ, I,  I;...
                I,  mX, Sd, I,  I;...
                I,  S,  H,  I,  I;...
                I,  H,  I,  I,  I};
            
    g1={mX,mI,mZ,mX,mZ};
    g2={mI,mX,mX,mZ,mZ};
    g3={mX,mZ,mI,mZ,mX};
    g4={mZ,mZ,mX,mX,mI};
    Xbar={mX,mX,mX,mX,mX};
    Ybar={mY,mY,mY,mY,mY};
    Zbar={mZ,mZ,mZ,mZ,mZ};


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
   
   aczSettings4 = sqc.qobj.aczSettings('q5_q6');
   aczSettings4.load();
   qubits{4}.aczSettings(end+1) = aczSettings3;
   qubits{5}.aczSettings(end+1) = aczSettings3;
   
   phase989 = qes.expParam(aczSettings1,'dynamicPhase(1)');
   phase988 = qes.expParam(aczSettings1,'dynamicPhase(2)');
   
   phase787 = qes.expParam(aczSettings2,'dynamicPhase(1)');
   phase788 = qes.expParam(aczSettings2,'dynamicPhase(2)');
   phase786 = qes.expParam(aczSettings2,'dynamicPhase(3)');
   
   phase767 = qes.expParam(aczSettings3,'dynamicPhase(1)');
   phase766 = qes.expParam(aczSettings3,'dynamicPhase(2)');
   phase768 = qes.expParam(aczSettings3,'dynamicPhase(3)');
   
   phase565 = qes.expParam(aczSettings4,'dynamicPhase(1)');
   phase566 = qes.expParam(aczSettings4,'dynamicPhase(2)');

   p = sqc.op.physical.gateParser.parse(qubits,gateMat);
   R = resonatorReadout(qubits);
   R.delay = p.length;
   
   function procFactory()
       p = sqc.op.physical.gateParser.parse(qubits,gateMat);
       p.Run();
   end
   
   R.preRunFcns = {@(x)procFactory()};
%    R.datafcn = @(x) sum(x(2:end-1))-x(1)-x(end);
   R.datafcn = @(x) sum(abs(x(2:end-1)))-x(1)-x(end)+abs(x(1)-x(end));

   %%
   f = qes.expFcn([phase989,phase988,...
                   phase787,phase788,phase786,...
                   phase767,phase766,phase768,...
                   phase565,phase566],R);
   
   x0 = [0,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3;...
         0,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3, pi/3;...
         0,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3, pi/3, pi/3;...
         0,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3, pi/3, pi/3, pi/3;...
         0,-pi/3,-pi/3,-pi/3,-pi/3,-pi/3, pi/3, pi/3, pi/3, pi/3;...
         0,-pi/3,-pi/3,-pi/3,-pi/3, pi/3, pi/3, pi/3, pi/3, pi/3;...
         0,-pi/3,-pi/3,-pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3;...
         0,-pi/3,-pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3;...
         0,-pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3;...
         0, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3;...
      pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3, pi/3];
     
   tolX = ones(1,10)*pi/2e3;
   tolY = [5e-3];

   h = qes.ui.qosFigure(sprintf('GHZ CZ DetuneQ phase Opt | '),false);
   axs(11) = subplot(3,4,[11,12],'Parent',h);
   axs(10) = subplot(3,4,10);
   axs(9) = subplot(3,4,9);
   axs(8) = subplot(3,4,8);
   axs(7) = subplot(3,4,7);
   axs(6) = subplot(3,4,6);
   axs(5) = subplot(3,4,5);
   axs(4) = subplot(3,4,4);
   axs(3) = subplot(3,4,3);
   axs(2) = subplot(3,4,2);
   axs(1) = subplot(3,4,1);
   [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
   fval = y_trace(end);
   fval0 = y_trace(1);
   
   [~,ind] = min(y_trace);

   phase989.val = x_trace(ind,1);
   phase988.val = x_trace(ind,2);
   
   phase787.val = x_trace(ind,3);
   phase788.val = x_trace(ind,4);
   phase786.val = x_trace(ind,5);
   
   phase767.val = x_trace(ind,6);
   phase766.val = x_trace(ind,7);
   phase768.val = x_trace(ind,8);
   
   phase565.val = x_trace(ind,9);
   phase566.val = x_trace(ind,10);
   %%
%    phase989.val = 0.4421;
%    phase988.val = 0.2250;
%    
%    phase787.val = 2.1881;
%    phase788.val = 1.9644;
%    phase786.val = 2.4353;
%    
%    phase767.val = 1.4327;
%    phase766.val = 1.2448;
%    phase768.val = 2.1008;
%    
%    phase565.val = 1.3016;
%    phase566.val = 1.8239;
   

   procFactory();
   R.datafcn = [];
   data = R();
   h1 = qes.ui.qosFigure(sprintf('GHZ CZ DetuneQ phase Opt | '),false);
   ax1 = axes(h1);
   bar(ax1,data);
   xlabel(ax1,'|0...0>,|0...1>,...,|1...1>');
   ylabel(ax1,'P');
   title(ax1,num2str(x_trace(ind,:),'%0.3f'));
   grid(ax1,'on');
   return;

end
