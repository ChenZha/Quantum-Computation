function autoCalibration(qubits,gui,level,samples)
% data_taking.public.xmon.tuneup.autoCalibration(qubits,1,1)
% Lv0, only readout
% Lv0.5, update f01 and Lv0
% Lv0.9, update X/2 gate amp and Lv0.5
% Lv1, correct f01 and Lv0.9
% Lv2, rabi amp initial and Lv1
% Lv3, Drag Alpha and Lv2
% Lv4, Drag alpha in large range and Lv2

% GM, 20180422
import data_taking.public.xmon.*

if nargin<4
    samples=1000;
end
if nargin<3
    level=1;
end
if nargin<2
    gui=1;
end
if ischar(qubits)
    qubits={qubits};
end

sqc.util.setQSettings('r_avg',samples);

if level>=2
    tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',gui,'save',true);
end
if level>=1
    tuneup.correctf01byPhase('qubits',qubits,'delayTime',0.5e-6,'doCorrection',true,'gui',gui,'save',true);
    tuneup.correctf01byPhase('qubits',qubits,'delayTime',0.5e-6,'doCorrection',true,'gui',gui,'save',true);
    tuneup.correctf01byPhase('qubits',qubits,'delayTime',0.5e-6,'doCorrection',false,'gui',gui,'save',true);
    tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',gui,'save',true);
end
if level>0 && level<1
    tuneup.correctf01byPhase('qubits',qubits,'delayTime',0.5e-6,'doCorrection',false,'gui',gui,'save',true);
end
if level==3
    for ii = 1:numel(qubits)
        tuneup.DRAGalpha_auto('qubit',qubits{ii},'alpha',[],...
            'phase',0,'numI',[11,16,21,26],...
            'gui',false,'save',true,'update',true);
    end
end
if level==4
    for ii = 1:numel(qubits)
        tuneup.DRAGalpha_auto('qubit',qubits{ii},'alpha',[-1:0.1:5],...
            'phase',0,'numI',[6,9,13,16],...
            'gui',false,'save',true,'update',true);
    end
end
if level>=2
    for ii = 1:numel(qubits)
        q = qubits{ii};
        amp = [0e4:200:3.2e4];
        tuneup.rabiamp_auto('qubit',q,'biasAmp',0,'biasLonger',20,...
            'xyDriveAmp',amp,'detuning',[0],'driveTyp','X/2','numPi',1,...
            'dataTyp','P','gui',gui,'save',true,'fit',true,'update',true);
    end
end
if level>=0.9
    AENumPi=25;
    tuneup.xyGateAmpTuner_parallel('qubits',qubits,'gateTyp','X/2','AENumPi',AENumPi,...
        'tuneRange',0.04,'gui',gui,'save',true,'logger',[]);
end
if level>=0
    tuneup.iq2prob_01('qubits',qubits,'numSamples',5e4,'gui',gui,'save',true);
end
qRegs = sqc.qobj.qRegisters.GetInstance();
qRegs.reloadAllQubits();
disp(['LV' num2str(level) ' autoCalibration Done!'])
fidd=sqc.util.getQSettings('r_iq2prob_fidelity');fids=fidd(:,1)+fidd(:,2)-1;
if ~isempty(find(fids<0.6))
    sprintf('q%s error happened',num2str(find(fids<0.6)))
end
end