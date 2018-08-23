% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,2)
%%
aczSettingsKey = sprintf('%s_%s','q3','q2');
QS = qes.qSettings.GetInstance();
scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});

detune=60e6:3e6:90e6;

for ii=1:numel(detune)
    scz.detuneFreq(1)=detune(ii);
    QS.saveSSettings({'shared','g_cz',aczSettingsKey,'detuneFreq'},...
        scz.detuneFreq);
    sqc.util.setQSettings('r_avg',1000);
    data_taking.public.xmon.tuneup.scanCZparams2('controlQ','q3','targetQ','q2','czln',[-15:2:15],'gui',true,'save',true);
end
%%
for jj=1:2
    for ii = 2
        czQSet = czQSets{ii};
        sqc.util.setQSettings('r_avg',1000);
        %     data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
        data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-20:2:20],'gui',true,'save',true);
    end
end
%%
for jj=1
    for ii = 2
%         try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
%         catch ME
%             disp(ME)
%         end
    end
end