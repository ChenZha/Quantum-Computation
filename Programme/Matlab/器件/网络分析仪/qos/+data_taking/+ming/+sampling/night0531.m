% Tonight I need to calibrate all T1 and T2 of new working points,
% calibrate the zpa_auto,
%%
% try
setQSettings('r_avg',500);
optParams=jpaOptimizeADDA('jpa','impa1',...
    'signalAmp',[4e3],'signalFreq',[],...
    'signalPower',20,'signalFc',6.50283e9,...
    'signalLn',10000,'rAvg',500,...
    'pumpAmp',[3e4],...
    'pumpFreq',[1.3682e10,1.36819e10],'pumpPower',[13.66,17.82],...
    'biasAmp',[1.4573e4,1.3839e4],...
    'notes','','gui',true,'save',true)
jpaGainADDA('jpa','impa1',...
    'signalAmp',[4e3],'signalFreq',[],...
    'signalPower',20,'signalFc',6.50283e9,...
    'signalLn',10000,'rAvg',500,...
    'biasAmp',optParams(3),'pumpAmp',[3e4],...
    'pumpFreq',optParams(1),'pumpPower',optParams(2),... // 6.73563e+09 = (freq_q6 + freq_q7)/2
    'notes','','gui',true,'save',true);
% end
%%
try
    data_taking.public.xmon.tuneup.autoCalibration(qubits,1,4)
end
%%
try
    setQSettings('r_avg',3000);
    % tuneup.autoCalibration(qubits,0,1)
    data_taking.public.xmon.tuneup.T1_updater('qubits',qubits)
end
%%
try
    setQSettings('r_avg',3000);
    % tuneup.autoCalibration(qubits,0,1)
    data_taking.public.xmon.tuneup.T2_updater('qubits',qubits)
end
%%
try
    for ii=[11 1 6 9]
        setQSettings('r_avg',500);
        spectroscopy1_zpa_auto('qubit',qubits{ii},'biasAmp',-10e3:500:10e3,...
            'swpInitf01',[],'swpInitBias',[0],...
            'swpBandWdth',25e6,'swpBandStep',1e6,...
            'dataTyp','P','r_avg',500,'gui',true);
    end
end
%%
try
    for ll=1:12
        figure(212);cla;
        legendlabel={};
        for jj=1:12
            if abs(ll-jj)<12 && ll~=jj
                legendlabel=[legendlabel,qubits{jj}];
                measureQs = {qubits{ll}};
                opQs = [measureQs,{qubits{jj}}];
                r_amp0=sqc.util.getQSettings('r_amp',measureQs{1});
                %             r_amp=linspace(1500,1700,11);
                %             r_amp=round(r_amp0*linspace(0.95,1.05,6));
                r_amp=r_amp0;
                stats = 10000;
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
                    hf=figure(210);plot(r_amp(1:kk),dist,'-o')
                    title(['R: ' opQs{1} '-' opQs{2} ]);
                    ylabel('Distance percentage')
                    xlabel(['r amp of ' measureQs{1}])
                    figure(211);plot(results,'-o')
                    title([num2str(r_amp(kk)) ' ' num2str(dist(kk))])
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
        datafile=['E:\data\20180216_12bit\readout cross talk\' 'R ' opQs{1} ' cross talk',datestr(now,'hhmmss'),'.fig'];
        saveas(hf,datafile)
    end
end
%%
try
    for ii=1:12
        q=qubits{ii};
        f01=sqc.util.getQSettings('f01',q);
        zp=sqc.util.f012zpa(q,f01-10e6:2e6:f01+10e6);
        % zp=-1000:100:1000;
        setQSettings('r_avg',1000);
        data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:2000:38e3],... % [20:200:2.8e4]
            'gui',true,'save',true,'fit',true);
    end
end
%%
% try
    for ii = 1:11
        czQSet = czQSets{ii};
        sqc.util.setQSettings('r_avg',1000);
        data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',true,'repeatIfOutOfBoundButClose',true,'gui',true);
        %         data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-20:2:20],'gui',true,'save',true);
    end
% end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,4)
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1)

for ii = 1:11
    try
        czQSet = czQSets{ii};
        sqc.util.setQSettings('r_avg',1000);
        data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-10:1:10],'gui',true,'save',true);
    catch ME
        disp(ME)
    end
end
for jj=1:2
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',2000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
        catch ME
            disp(ME)
        end
    end
end
%%
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.9)
for ii=1:12
    q=qubits{ii};
    f01=sqc.util.getQSettings('f01',q);
    zp=[];
    for jj=1:numel(freqr{ii})
        zp=[zp, sqc.util.f012zpa(q,freqr{ii}(jj)-10e6:2e6:freqr{ii}(jj)+10e6)];
    end
    setQSettings('r_avg',1000);
    data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:1000:38e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);
end