% bring up qubits - spectroscopy
% Yulin Wu, 2017/3/11
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};%'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'
for ii = 7
    q = qubits{ii};
    amp = 0:1e2:32e3;
    % amp = 1.85e4;
    varargout{1} = rabi_amp1('qubit',q,'biasAmp',[0],'biasLonger',20,...
        'xyDriveAmp',amp,'detuning',[0],'driveTyp','X/2','numPi',1,...
        'dataTyp','P','gui',true,'save',true);
%     f=@(a,x) a(1)+a(2)*sin(2*pi*x/a(3)+a(4));
%     data=varargout{1,1}.data{1,1};
%     x=varargout{1,1}.sweepvals{1,2}{1,1};
%     [~,locs]=max(data);
%     a=[(max(data)+min(data))/2,(max(data)-min(data))/2,2*x(locs),-pi/2];
%     [b,r,J]=nlinfit(x,data,f,a);
%     [~,se] = toolbox.data_tool.nlparci(b,r,J,0.05);
%     amp=round((pi/2-b(4))/2/pi*b(3));
%     amp_err=round(sqrt(se(4)^2*b(3)^2+se(3)^2*b(4)^2)/2/pi);
%     title(['\pi amp = ' num2str(amp,'%d') ' \pm ' num2str(amp_err, '%d')])
%     sqc.util.setQSettings('g_XY2_amp',amp,q)
end
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
for ii = [12]
        q = qubits{ii};
        amp = [0e4:500:3.2e4];
        tuneup.rabiamp_auto('qubit',q,'biasAmp',0,'biasLonger',20,...
            'xyDriveAmp',amp,'detuning',[0],'driveTyp','X/2','numPi',1,...
            'dataTyp','P','gui',1,'save',true,'fit',true,'update',true);
    end
%%
q=qubits{4};
rabi_long1_amp('qubit',q,'biasAmp',0,'biasLonger',20,...
      'xyDriveAmp',[20000],'xyDriveLength',[10:2:500],...
      'dataTyp','P','gui',true,'save',true);
%%
rabi_long1_freq('qubit','q6','biasAmp',0,'biasLonger',5,...
      'xyDriveAmp',8000,'xyDriveLength',[1:4:2000],...
      'detuning',[-10:1:10]*1e6,...
      'dataTyp','P','gui',true,'save',true);
  %%
      T1_1('qubit','q8','biasAmp',0,'biasDelay',0,'time',[100:1000:60e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);
    %%
    for ii=[7 8]
    q=qubits{ii};
    f01=sqc.util.getQSettings('f01',q);
% f01=4.28e9;
    zp=sqc.util.f012zpa(q,f01-40e6:0.2e6:f01+40e6);
    setQSettings('r_avg',3000);
    T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[30e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);
end

  %%
for ii=1:12
    q=qubits{ii};
    f01=sqc.util.getQSettings('f01',q);
%     zp=sqc.util.f012zpa(q,f01-700e6:10e6:f01e6);
    if mod(ii,2)
    zp=sqc.util.f012zpa(q,4.3e9:5e6:5.15e9);
    else
    zp=sqc.util.f012zpa(q,3.8e9:5e6:4.5e9);
    end
% zp=0;
    setQSettings('r_avg',1000);
    T1_1('qubit',q,'biasAmp',zp,'biasDelay',0,'time',[100:2000:60e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);

end
%%
for ii = [8]
    q = qubits{ii};
    setQSettings('r_avg',1000);
    [data,T2]=ramsey('qubit',q,'mode','dp',... % available modes are: df01, dp and dz
        'time',[0:20:8000],'detuning',-4*1e6,...
        'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true,'fit',true);
    sqc.util.setQSettings('T2',T2,q);
end

%%
for ii = 2
    q = qubits{ii};
setQSettings('r_avg',2000);
ramsey('qubit',q,'mode','dz',... % available modes are: df01, dp and dz
      'time',[20:100:10000],'detuning',[-1500:200:1500],...
      'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true,'fit',true);
end
%%
spin_echo('qubit','q9','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:20:4000],'detuning',[2]*1e6,...
      'notes','','gui',true,'save',true);
%%
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};%'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'
for ii = 8
    q = qubits{ii};
    setQSettings('r_avg',3000);
    [data,T1]=T1_1('qubit',q,'biasAmp',0,'biasDelay',20,'time',[20:1000:50e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);
    sqc.util.setQSettings('T1',T1,q);
end

%%
resonatorT1('qubit','q2',...
      'swpPiAmp',1.8e3,'biasDelay',16,'swpPiLn',28,'time',[0:10:2000],...
      'gui',true,'save',true)
%%
qqSwap('qubit1','q5','qubit2','q6',...
      'biasAmp1',[2.75e4:30:2.85e4],'biasAmp2',[0],'biasDelay1',1,'biasDelay2',1,...
      'q1XYGate','X','q2XYGate','I',...
      'swapTime',[11:10:300],'readoutQubit','q1',...
      'notes','','gui',true,'save',true);
  %% cross talk
  amp = [0e4:500:3.2e4];
%   tuneup.iq2prob_01('qubits','q1','numSamples',2e4,'gui',true,'save',true);
  rabi_amp111('biasQubit','q1','driveQubit','q1','readoutQubit','q2',...
      'biasAmp',[0],'biasLonger',20,...
        'xyDriveAmp',amp,'detuning',[0],'driveTyp','X/2','numPi',1,...
        'notes','','dataTyp','P','gui',true,'save',true);
%%
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T1_updater('qubits',{qubits{[9,10]}})
%%
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T2_updater('qubits',{qubits{[9,10]}})