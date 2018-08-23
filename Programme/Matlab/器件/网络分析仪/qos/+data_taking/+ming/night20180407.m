cd('D:\QOS-v0.1\qos');
addpath('D:\QOSLib');
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
import data_taking.public.jpa.*

qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};%'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'
% try
%     setQSettings('r_avg',1000);
%     for ii = 1:numel(qubits)
%         q = qubits{ii};
%         tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
%     end
% end
%%
% setQSettings('r_avg',500);
% optParams=jpaOptimizeADDA('jpa','impa1',...
%     'signalAmp',[4e3],'signalFreq',[],...
%     'signalPower',20,'signalFc',6.50283e9,...
%     'signalLn',10000,'rAvg',500,...
%     'pumpAmp',[3e4],...
%     'pumpFreq',[1.3682e10,1.36817e10],'pumpPower',[13.66,17.45],...
%     'biasAmp',[1.4573e5,2.43439e5],...
%     'notes','','gui',true,'save',true)
% jpaGainADDA('jpa','impa1',...
%     'signalAmp',[4e3],'signalFreq',[],...
%     'signalPower',20,'signalFc',6.50283e9,...
%     'signalLn',10000,'rAvg',500,...
%     'biasAmp',optParams(3),'pumpAmp',[3e4],...
%     'pumpFreq',optParams(1),'pumpPower',optParams(2),... // 6.73563e+09 = (freq_q6 + freq_q7)/2
%     'notes','','gui',true,'save',true);

%%
% try
%     sqc.util.setQSettings('r_amp',4e3)
%     sqc.util.setQSettings('r_ln',5e3)
% for ii = 3:numel(qubits)
%     q = qubits{ii};
%     tuneup.optReadoutParam('qubits',q,'gui',true,'save',true,'optrange',0.7,'optnum',100)
% end
% end

%%
setQSettings('r_avg',1000);
tuneup.autoCalibration(qubits,0,1)
% tuneup.autoCalibration(qubits,0,1)
%%
%%
%%
for ii=[1 8 9]
setQSettings('r_avg',1000);
spectroscopy1_zpa_auto('qubit',qubits{ii},'biasAmp',-1.5e4:0.5e3:1.5e4,...
    'swpInitf01',[],'swpInitBias',[0],...
    'swpBandWdth',25e6,'swpBandStep',1e6,...
    'dataTyp','P','gui',true);
end
%%
% tuneup.autoCalibration(qubits,0,4)
%%
% for ii=1:12
%     q=qubits{ii};
%     f01=sqc.util.getQSettings('f01',q);
%     zp=sqc.util.f012zpa(q,f01-100e6:2.5e6:f01+100e6);
%     setQSettings('r_avg',1000);
%     T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:1000:30e3],... % [20:200:2.8e4]
%         'gui',true,'save',true,'fit',true);
% end
%%
for ii=[8 9]
    q=qubits{ii};
    f01=sqc.util.getQSettings('f01',q);
% f01=4.28e9;
    zp=sqc.util.f012zpa(q,f01-40e6:0.2e6:f01+40e6);
    setQSettings('r_avg',3000);
    T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[30e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);
end
% 
% for ii=2:2:12
%     q=qubits{ii};
%     f01=sqc.util.getQSettings('f01',q);
%     zp=sqc.util.f012zpa(q,f01-100e6:4e6:f01+100e6);
%     setQSettings('r_avg',1000);
%     T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:1000:38e3],... % [20:200:2.8e4]
%         'gui',true,'save',true,'fit',true);
% end
%%
% setQSettings('r_avg',1000);
% for ii = 1:numel(qubits)
%     q = qubits{ii};
%     tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
% end
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
%%
% try
% setQSettings('r_avg',5000);
% % tuneup.autoCalibration(qubits,0,1)
% data_taking.public.xmon.tuneup.T1_updater('qubits',qubits)
% end
%
try
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T2_updater('qubits',qubits)
end
%%
for jj=1:2
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
        end
    end
end
    try
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
        [Phase1,~,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
        [Phase0,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo_Q1_Q12(datafile);
    catch ME
        disp(ME)
    end
        for jj=1
        numtake=1;
        numpertake=10;
        try
            for ii=1:11
                data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2],1,1,numtake);
            end
        catch ME
            disp(ME)
        end
    end
%%
% try
%     for ii=9
% %         tuneup.autoCalibration(qubits,0,1)
% %         sqc.measure.gateOptimizer.xyGateOptWithDrag(qubits{ii},50,40,500,40);
%         
%         q = qubits{ii};
%         setQSettings('r_avg',1000);
%         tuneup.autoCalibration(qubits,0,0)
%         numGates = int16(unique(round(logspace(1,log10(150),30))));
%         [Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
%             'process','X/2','numGates',numGates,'numReps',40,...
%             'gui',true,'save',true);
%         [fidelity,hf] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'X/2');
%         QS = qes.qSettings.GetInstance();
%         dataSvName = fullfile(QS.loadSSettings('data_path'),...
%             ['RB_X_2_',q,'_',datestr(now,'yymmddTHHMMSS'),...
%             num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
%         try
%             saveas(hf,dataSvName);
%         catch
%             warning('saving figure failed.');
%         end
%     end
% end
% %%
% try
%     for ii=9
% %         tuneup.autoCalibration(qubits,0,1)
% %         sqc.measure.gateOptimizer.xyGateOptWithDrag(qubits{ii},50,40,500,40);
%         
%         q = qubits{ii};
%         setQSettings('r_avg',1000);
%         tuneup.autoCalibration(qubits,0,0)
%         numGates = int16(unique(round(logspace(1,log10(150),30))));
%         [Pref,Pgate] = randBenchMarking('qubit1',q,'qubit2',[],...
%             'process','Y/2','numGates',numGates,'numReps',40,...
%             'gui',true,'save',true);
%         [fidelity,hf] = toolbox.data_tool.randBenchMarking(numGates, Pref, Pgate, 1, 'Y/2');
%         QS = qes.qSettings.GetInstance();
%         dataSvName = fullfile(QS.loadSSettings('data_path'),...
%             ['RB_Y_2_',q,'_',datestr(now,'yymmddTHHMMSS'),...
%             num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
%         try
%             saveas(hf,dataSvName);
%         catch
%             warning('saving figure failed.');
%         end
%     end
% end
%%


%%
% try
%     setQSettings('r_avg',3000);
%     % delayTime = [[0:1:20],[21:2:50],[51:5:100],[101:10:500],[501:50:3000]];
%     delayTime = [0:50:5e3];
%     for ii=1
%         data_phase=zPulseRingingPhase('qubit',qubits{ii},...
%             'delayTime',delayTime,...
%             'zAmp',3e4,'gui',true,'save',true);
%         
%         phasedifference=sign(data_phase(1,1)-data_phase(2,1))*toolbox.data_tool.unwrap_plus(data_phase(1,:)-data_phase(2,:));
%         func=@(a,x)(a(1)*exp(-x/a(3))+a(2));
%         try
%             a=[phasedifference(2)-phasedifference(end),phasedifference(end),500];
%             b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
%         catch
%             a=[phasedifference(2)-phasedifference(end),phasedifference(end),50];
%             b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
%         end
%         f=abs(b(1));
%         td=round(b(3));
%         
%         % title([num2str(s.r) ' x' num2str(f)])
%         
%         figure();plot(delayTime,b(1)*exp(-delayTime/b(3))+b(2),delayTime,phasedifference,'.');title([num2str(ii) ' ' num2str(b)])
%         
%     end
% end
%%
% for ii=1:12
%     for jj=1:12
%         if ii~=jj
%             ramsey('qubit',qubits{ii},'biasqubit',qubits{jj},'mode','dz',... % available modes are: df01, dp and dz
%                 'time',[20:300:10000],'detuning',[-3e4 3e4],...
%                 'dataTyp','P','phaseOffset',0,'notes',[num2str(ii) ' & ' num2str(jj)],'gui',true,'save',true,'fit',true);
%         end
%     end
% end
%%
% setQSettings('qr_xy_uSrcPower',15)
% ZZ=NaN(12,12);
% for ii=3
%     for jj=2
%         if ii~=jj
%             f01=getQSettings('f01',qubits{ii});
%             varargout = spectroscopy111_zpa('biasQubit',qubits{jj},'biasAmp',[-3e4:1.5e4:3e4],'driveQubit',qubits{ii},'dataTyp','P',...
%                 'driveFreq',f01-15e6:0.5e6:f01+15e6,'readoutQubit',qubits{ii},'notes',[qubits{jj} ' -> ' qubits{ii}],'gui',true,'save',true);
%             x=varargout.sweepvals{1,1}{1,1};
%             y=varargout.sweepvals{1,2}{1,1};
%             z=varargout.data{1,1};
%             for kk=1:5
%                 [~,lo]=max(z(kk,:));
%                 [a, x0(kk), sigma, y0, varargout] = toolbox.data_tool.fitting.gaussianFit(y,z(kk,:),0.5,y(lo),1e6,min(z(kk,:)));
%             end
%             ff=polyfit(x,x0,1);
%             ZZ(ii,jj)=ff(1);
%             [~,lo]=max(z,[],2);
%             figure(77);plot(x,x0,x,y(lo))
%             disp([qubits{jj} '->' qubits{ii} ' ' num2str(ff(1)) 'Hz/bit'])
%         end
% %         save('E:\data\20180622_12bit\Z cross talk\ZZ.mat','ZZ')
%     end
% end
%%
%%
% sqc.util.setQSettings('r_avg',1000);
% for ii=1:12
%     xy_Rdelay('qubit',qubits{ii},'biasDelay',[-100:2:100],'dataTyp','P','gui',true)
% end
%%
% d=NaN(1,12);
% for jj=2:12
% sqc.util.setQSettings('r_avg',4000);
%     for ii=1:12
%         [~,dd]=zDelay('zQubit',qubits{ii},'xyQubit',qubits{ii},'zAmp',1e4,'zLn',[],'zDelay',[-100:2:100],...
%             'gui',true,'save',true,'notes',[qubits{ii} ' -> ' qubits{ii}]);
%         d(ii)=dd;
%         hold on;plot([-2*dd -2*dd],[0 1])
%     end
% end
%%
% try
% data_taking.ming.sampling.sampling_script()
% end

%%
% 
% allQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
% % czQSet: {'aczQ','otherQ','dynamicPhaseQ1','dynamicPhaseQ2',...} % 'aczQ'
% % and 'otherQ' dynamic phases are corrected by default, no need to add
% % them as dynamicPaseQs
% czQSets = {{'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'},...
%     {'q3','q2','q1','q4','q5','q6','q7','q8','q9','q10','q11','q12'},...
%     {'q3','q4','q1','q2','q5','q6','q7','q8','q9','q10','q11','q12'},...
%     {'q5','q4','q1','q2','q3','q6','q7','q8','q9','q10','q11','q12'},...
%     {'q5','q6','q1','q2','q3','q4','q7','q8','q9','q10','q11','q12'},...
%     {'q7','q6','q1','q2','q3','q4','q5','q8','q9','q10','q11','q12'},...
%     {'q7','q8','q1','q2','q3','q4','q5','q6','q9','q10','q11','q12'},...
%     {'q9','q8','q1','q2','q3','q4','q5','q6','q7','q10','q11','q12'},...
%     {'q9','q10','q1','q2','q3','q4','q5','q6','q7','q8','q11','q12'},...
%     {'q11','q10','q1','q2','q3','q4','q5','q6','q7','q8','q9','q12'},...
%     {'q11','q12','q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'},...
%     };
% numCZs = struct(); numCZs.q1 = 9; numCZs.q2 = 9; numCZs.q3 = 9;
% numCZs.q4 = 9; numCZs.q5 = 9; numCZs.q6 = 9; numCZs.q7 = 9;
% numCZs.q8 = 9; numCZs.q9 = 9;numCZs.q10 = 9; numCZs.q11 = 9; numCZs.q12 = 9;
% 
% setQSettings('r_avg',2000);
% for ii = 3
% %     try
%         czQSet = czQSets{ii};
%         tuneup.autoCalibration(qubits,0,1)
%         tuneup.simu_czAmplitude('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
%         tuneup.simu_czPhaseTomo('controlQ',czQSet{1},'targetQ',czQSet{2});
%         % sqc.measure.gateOptimizer.czOptPhase({czQSet{1},czQSet{2}},4,20,1500, 50);
% %         if ii<=3
% %         tuneup.simu_czDynamicPhase_parallel('controlQ',czQSet{1},'targetQ',czQSet{2},'dynamicPhaseQs',{czQSet{3:end}},...
% %                 'numCZs',numCZs.(czQSet{ii}),'PhaseTolerance',0.03,...
% %                 'gui','true','save',true);
% %         end
% %     end
% end
% 
% %%
% try
%     setQSettings('r_avg',1000);
%     for ii = 1:numel(czQSets)
%         try
%             czQSet = czQSets{ii};
%             numGates = [1:2:21];
%             [Pref,Pi] = randBenchMarking('qubit1',czQSet{1},'qubit2',czQSet{2},...
%                 'process','CZ','numGates',numGates,'numReps',40,...
%                 'gui',true,'save',true);
%             [fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, mean(Pref,1), mean(Pgate, 1),2, 'CZ');
%         end
%     end
% end


%%
% try
%     for ii = 2
%         q = qubits{ii};
%         setQSettings('r_avg',500);
%         spectroscopy1_zpa_auto('qubit',q,'biasAmp',[-3e4:300:3e4],...
%             'swpInitf01',[],'swpInitBias',0,...
%             'swpBandWdth',25e6,'swpBandStep',1e6,...
%             'notes','','dataTyp','P','r_avg',500,'gui',true);
%     end
% catch
%     disp('error')
% end

%%
% try
% setQSettings('r_avg',1000);
% for ii=1:numel(qubits)
%     q=qubits{ii};
% amp = logspace(log10(2000),log10(3e4),50);
% % amp = getQSettings('r_amp',q);
% rfreq = getQSettings('r_fr',q);
% freq = rfreq-0.8e6:0.04e6:rfreq+0.5e6;
% data1{ii}=s21_rAmp('qubit',q,'freq',freq,'amp',amp,...
%       'notes','','gui',true,'save',true);
% end
% end



% try
%     Untitled8
% catch
%     disp('error')
% end