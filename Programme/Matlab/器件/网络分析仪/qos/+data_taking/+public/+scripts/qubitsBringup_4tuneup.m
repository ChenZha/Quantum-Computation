% bring up qubits - tuneup
% Yulin Wu, 2017/3/11
q = 'q4';
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save','askMe');
tuneup.optReadoutFreq('qubit',q,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save','askMe');
%tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save','askMe','doCorrection',true,'iter',true);
%tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save','askMe');
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',41,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save','askMe');
%%
q = 'q8';
setQSettings('r_avg',1000);
tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'gui',true,'save',true,'doCorrection',true,'iter',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',true,'AENumPi',15,'gui',true,'save',true);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
%%
qubits = {'q2','q4','q6','q8','q10','q12'};%'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'
for ii = 6:numel(qubits)
    q = qubits{ii};
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X/2','AE',false,'AENumPi',31,'gui',true,'save',true);
end
%% fully auto callibration
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};%'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'
for ii = 1:12
    q = qubits{ii};
%     setQSettings('r_avg',500);
        tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
%         tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
%     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'doCorrection',true,'gui',true,'save',true);
%     tuneup.correctf01byPhase('qubits',q,'delayTime',1e-6,'doCorrection',false,'gui',true,'save',true);
%     %     tuneup.iq2prob_01('qubits',q,'numSamples',1e4,'gui',true,'save',true);
%         AENumPi=21;
%         tuneup.xyGateAmpTuner_parallel('qubits',q,'gateTyp','X/2','AENumPi',AENumPi,...
%                 'tuneRange',0.04,'gui',true,'save',true,'logger',[]);
%         tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
end
%%
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
AENumPi=21;
tuneup.xyGateAmpTuner_parallel('qubits',qubits,'gateTyp','X/2','AENumPi',AENumPi,...
    'tuneRange',0.03,'gui',true,'save',true,'logger',[]);
tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',true,'save',true);
%%
tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',true,'save',true);
%%
% qubits = {'q2'};%'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'
for ii = 12
    q = qubits{ii};
    tuneup.optReadoutParam('qubits',q,'gui',true,'save',true,'optrange',0.7,'optnum',100)
end
%%
tuneup.correctf01byPhase('qubits',qubits,'delayTime',1e-6,'doCorrection',true,'gui',true,'save',true);
AENumPi=21;
tuneup.xyGateAmpTuner_parallel('qubits',qubits,'gateTyp','X/2','AENumPi',AENumPi,...
    'tuneRange',0.05,'gui',true,'save',true,'logger',[]);
tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',true,'save',true);
%%
tuneup.APE('qubit',q,...
    'phase',-pi:pi/40:pi,'numI',4,...
    'gui',true,'save',true);
%%
for ii=6
    q=qubits{ii};
    setQSettings('r_avg',1000);
    data=tuneup.DRAGAlphaAPE('qubit',q,'alpha',[3:0.1:5],...
        'phase',0,'numI',[10,20,30,40],...
        'gui',false,'save',true);
    xval=data.sweepvals{1,1}{1,1};
    numI=data.sweepvals{1,2}{1,1};
    ddata=data.data{1,1};
    figure;imagesc(numI,xval,ddata);
    xlabel('numI')
    ylabel('\alpha')
    title(q)
end
%%
photonNumberCal('qubit','q1',...
    'time',[-500:100:2.5e3],'detuning',[0:1e6:25e6],...
    'r_amp',2500,'r_ln',[],...
    'ring_amp',5000,'ring_w',200,...
    'gui',true,'save',true);
%%
for ii=1:12
zDelay('zQubit',qubits{ii},'xyQubit',qubits{ii},'zAmp',1e4,'zLn',[],'zDelay',[-100:2:100],...
    'gui',true,'save',true);
end
%%
sqc.util.setQSettings('r_avg',1000);
for ii=1:12
    xy_Rdelay('qubit',qubits{ii},'biasDelay',[-100:2:100],'dataTyp','P','gui',true)
end
%% single qubit correction

data_taking.public.xmon.tuneup.autoCalibration(qubits,1,0)
% data_taking.public.xmon.tuneup.autoCalibration({'q6','q7','q8'},1,4)
% phase_best=data_taking.fusheng.optGhzPhase(3,[-0.5166])
%%
setQSettings('r_avg',3000);
% delayTime = [[0:1:20],[21:2:50],[51:5:100],[101:10:500],[501:50:3000]];
delayTime = [0:50:2e3];
zPulseRingingPhase('qubit','q2',...
    'delayTime',delayTime,...
    'zAmp',1e4,'gui',true,'save',true);
%%
r={};
td={};
r{1}=[0.0159 0.0078 0.016];
td{1}=[1528 542 62];

r{2} = [0.013 0.0015 0.017 0.045];
td{2} = [3291 1886 622 41];

% r{3} = [0.022 0.01 0.01];
r{3} = [0.0022 0.021 0.022 0.0];
td{3} = [3000 1018 64 50];

r{4} = [0.0055 0.0155 0.0065 0.017 0.02];
td{4} =[4500 1250 512 60 30];

r{5} = [0.0205 0.0025 0.022];
td{5} = [1184 264 64];

r{6} = [0.0 0.0245 -0.008 0.018];
td{6} = [1552 870 358 127];

r{7} = [0.0175 0.0051 0.025];
td{7} = [1081 185 46];

r{8} = [0.019 0.015 -0.005 -0.01];
td{8} = [1030 104 85 22];

r{9}= [0.0176 0.015 0];
td{9}=[1026 123 30];

r{10} = [0.0177 0.0075 0.0170 -0.01];
td{10} =[1222 336 54 20];

r{11} = [0.0111 0.018 0.0175];
td{11} = [3800,540,44];

r{12} =[0.0212 0.005 0.019];% [0.0215 0.0059 0.0199 0.0185]
td{12} = [1101 296 56];


ii=8;
delayTime = unique(round(linspace(sqrt(2),sqrt(100),20).^2));
setQSettings('r_avg',2000);


s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;
q = qubits{ii};
s.r=r{ii};
s.td=td{ii};

xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

data_phase=zPulseRingingPhase('qubit',q,'delayTime',delayTime,...
    'xfrFunc',[xfrFunc_f],'zAmp',3e4,'s',s,...
    'notes','','gui',true,'save',true);
grid on

phasedifference=sign(data_phase(1,1)-data_phase(2,1))*toolbox.data_tool.unwrap_plus(data_phase(1,:)-data_phase(2,:));
func=@(a,x)(a(1)*exp(-x/a(3))+a(2));
try
    a=[phasedifference(2)-phasedifference(end),phasedifference(end),500];
    b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
catch
    a=[phasedifference(2)-phasedifference(end),phasedifference(end),50];
    b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
end
f=abs(b(1));

title([num2str(s.r) ' x' num2str(f)])

figure(199);plot(delayTime,b(1)*exp(-delayTime/b(3))+b(2),delayTime,phasedifference,'.');title(num2str(b))
%%
[ra,td] = fminzPulseRipplePhase('qubit','q1','delayTime',[0:200:6000],'zAmp',-3e4,'MaxIter',20,...
    'r',[0.0220],'td',[1509],'notes','','gui',true,'save',true)
%%
data_phase=toolbox.fit_ztail.zPulseRingingPhase1('qubit','q4','delayTime',delayTime,'Z_ln',30000,...
    'xfrFunc',[],'zAmp',3e4,'s',s,'integral_phase_time',1000,...
    'notes','','gui',true,'save',true);

%% Auto
try
for ii=3:12
        file=['E:\data\20180622_12bit\tailZ\' qubits{ii} '_Xfunc.mat'];
        if exist(file,'file')
            ss=load(file);
        else
            ra=r{ii}
            tda=td{ii}
            q=qubits{ii};
            setQSettings('r_avg',3000);
            [ra,tda] = fminzPulse('qubit',qubits{ii},'delayTime',5000,'zAmp',3e4,'MaxIter',30,...
                'Paras',5,'r',ra,'td',tda,'notes','','gui',true,'save',true);
            s = struct();
            s.type = 'function';
            s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
            s.bandWidht = 0.25;
            s.r = ra;
            s.td = tda;
            xfrFunc = qes.util.xfrFuncBuilder(s);
            xfrFunc_inv = xfrFunc.inv();
            xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
            xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
            sqc.util.setZXfrFunc(q,xfrFunc_f);
            save(file,'s')
            ss=load(file);
        end
        [ra,tda] = fminzPulse('qubit',qubits{ii},'delayTime',500,'zAmp',3e4,'MaxIter',20,...
            'Paras',5,'r',ss.s.r,'td',ss.s.td,'notes','','gui',true,'save',true);
%         [ra,td] = data_taking.public.xmon.tuneup.optzPulse('qubit',qubits{ii},'delayTime',3000,'zAmp',3e4,'MaxIter',20,...
%             'Paras',5,'r',ss.s.r,'td',ss.s.td,'notes','','gui',true,'save',true);
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        s.r = ra;
        s.td = tda;
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
        sqc.util.setZXfrFunc(q,xfrFunc_f);
        save(file,'s')
end
end
%% Check s
for ii=1:12
%     try
    setQSettings('r_avg',2000);
    ss=load(['E:\data\20180216_12bit\' qubits{ii} '_Xfunc.mat']);
    xfrFunc = qes.util.xfrFuncBuilder(ss.s);
    xfrFunc_inv = xfrFunc.inv();
    xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
    xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
%     sqc.util.setZXfrFunc(q,xfrFunc_f);
    delayTime = round(linspace(0,600,30));
    zPulseRingingPhase('qubit',qubits{ii},'delayTime',delayTime,...
        'xfrFunc',[xfrFunc_f],'zAmp',3e4,'s',s,...
        'notes','','gui',true,'save',true);
%     zPulseRinging('qubit',qubits{ii},'delayTime',delayTime,...
%         'xfrFunc',[xfrFunc_f],'zAmp',3e4,'s',s,...
%         'notes','','gui',true,'save',true);
%     catch ME
%         disp(ME)
%     end
end

%%
[sOpt,LPFBW] = zPulseXfrFunc('qubit','q1','delayTime',[30,100,300,700,1500],...
    'maxFEval',50,'numTerms',1,'rAmp0',[0.01],'td0',[700],'zAmp',-3e4);
%%
sqc.util.setZXfrFunc(q,xfrFunc_f);
%%
s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;

% s.r = [0.0130]; % q8
% s.td = [464]; % q8

s.r = [0.0130]; % q6
s.td = [260];  % q6

xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

q = 'q6';
sqc.util.setZXfrFunc(q,xfrFunc_f);
%%
sqc.measure.gateOptimizer.czOptPulseCal_2({'q9','q8'},false,4,15,1500, 40);
%%
q = 'q1';
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);
sqc.measure.gateOptimizer.xyGateOptWithDrag(q,100,20,1000,30);
setQSettings('r_avg',2000);
tuneup.iq2prob_01('qubits',q,'numSamples',2e4,'gui',true,'save',true);

%% xy drive crosstalk
% tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',true,'save',true);
opQs = qubits;
measureQs = qubits;
stats = 2000;
measureType = 'Mzj'; % default 'Mzj', z projection
numPi = 10;
for kk=1:12
    for jj=4
        if ~strcmp(opQs{kk},measureQs{jj})
            data = nan(1,numPi);
            x = 1:numPi;
            %  tuneup.iq2prob_01('qubits',measureQs{1},'numSamples',2e4,'gui',true,'save',true);
            figure();
            circuit = {};
            results=NaN(numPi,1);
            for ii = 1:numPi
                circuit = [circuit;'X'];
                [result, ~, ~, ~] = sqc.util.runCircuit(circuit,opQs(kk),measureQs(jj),stats,measureType);
                results(ii)=result(2);
                data(ii) = result(2);
                plot(x,data,'-s');
                xlabel('number of \pi pulses');
                ylabel('P|1>');
                title([opQs{kk},' -> ', measureQs{jj}, ' xy cross talk']);
                drawnow;
            end
            if max(abs(results))>0.05
                disp([opQs{kk},' ',measureQs{jj},' ',num2str(max(abs(results)))])
            else
                close
            end
        end
    end
end
%%
Rc=NaN(12,12);
for ll=1:12
    figure(212);cla;
    legendlabel={};
    for jj=1:12
        if abs(ll-jj)<12 && ll~=jj
            legendlabel=[legendlabel,qubits{jj}];
            measureQs = {qubits{ll}};
            opQs = [measureQs,{qubits{jj}}];
            r_amp0=sqc.util.getQSettings('r_amp',measureQs{1});
%             r_amp=linspace(1000,1600,21);
%             r_amp=round(r_amp0*linspace(0.8,1.2,11));
            r_amp=r_amp0;
            stats = 20000;
            measureType = 'MzjRaw'; % default 'Mzj', z projection
            circuit = {{'',''},{'','X'},{'X',''},{'X','X'}};%
            dist=[];
            for kk=1:numel(r_amp)
                sqc.util.setQSettings('r_amp',r_amp(kk),measureQs{1})
                results=nan(1,numel(circuit));
                for ii=1:numel(circuit)
                    [result, ~, ~, ~] = sqc.util.runCircuit(circuit{ii},opQs,measureQs,stats,measureType);
                    results(ii)=result;
                end
                dd0=results(3)-results(1);
                dd1=results(2)-results(1);
                dd2=results(4)-results(3);
                dist(kk)=(abs([real(dd1),imag(dd1)]*[real(dd0),imag(dd0)]')+abs([real(dd2),imag(dd2)]*[real(dd0),imag(dd0)]'))/abs(dd0)^2;
                if numel(r_amp0)==1
                    Rc(ll,jj)=dist(kk);
                end
                hf=figure(210);plot(r_amp(1:kk),dist,'-o')
                title(['R: ' opQs{1} '-' opQs{2} ]);
                ylabel('Distance percentage')
                xlabel(['r amp of ' measureQs{1}])
                figure(211);plot(results,'-o')
                title([num2str(r_amp(kk)) ' ' num2str(dist(kk))])
                drawnow
            end
%             datafile=['E:\data\20180216_12bit\readout cross talk\' 'R ' opQs{1} '-' opQs{2} '.fig'];
%             saveas(hf,datafile)
            hf=figure(212);hold on;plot(r_amp,dist,'-o');
            title(['R: ' opQs{1} ]);
            legend(legendlabel);
            ylabel('Distance percentage')
            xlabel(['r amp of ' measureQs{1}])
            sqc.util.setQSettings('r_amp',r_amp0,measureQs{1})
            disp('Done')
        end
    end
    datafile=['E:\data\20180622_12bit\readout cross talk\' 'R ' opQs{1} ' cross talk',datestr(now,'hhmmss'),'.fig'];
    saveas(hf,datafile)
end
hf=figure;imagesc(Rc);xlabel('Q1-Q12');ylabel('Q1-Q12');
datafile=['E:\data\20180622_12bit\readout cross talk\' 'R cross talk',datestr(now,'hhmmss'),'.fig'];
saveas(hf,datafile)
save(replace(datafile,'.fig','.mat'),'Rc','stats')
%% check readout cross talk
fids=nan(1,12);
for ii=1:12
    [~,~,fids(ii)]=tuneup.iq2prob_01('qubits',qubits{ii},'numSamples',2e4,'gui',true,'save',true);
end
tuneup.iq2prob_01('qubits',qubits,'numSamples',2e4,'gui',true,'save',true);
fidd=sqc.util.getQSettings('r_iq2prob_fidelity');fids2=fidd(:,1)+fidd(:,2)-1;
hf=figure;plot(1:12,fids2,'-or',1:12,fids,'-*b');legend('Joint Readout','Individually')
xlabel('qubit Index')
ylabel('Readout Fidelity')
datafile=['E:\data\20180622_12bit\readout cross talk\' 'all Q readout cross talk',datestr(now,'hhmmss'),'.fig'];
saveas(hf,datafile)