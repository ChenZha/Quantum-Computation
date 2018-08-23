function [dipFreqs, pkWithd] = qubitDips()
% automatic measurement: finds all qubitDips
    
    % Yulin Wu, 2017/6/2
    
    import data_taking.public.xmon.s21_rAmp
    
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_autoMeasurement_readoutResonator:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
	qubits = sqc.util.loadQubits();
    if isempty(qubits)
        throw(MException('QOS_autoMeasurement_readoutResonator:noQubits',...
			'No qubits! If there is not qubits, how could there be any readout resonators!'));
    end
    
    try
        autoConfig = QS.loadSSettings({'public','autoConfig'});
    catch
        throw(MException('QOS_autoMeasurement_readoutResonator:atuoConfigNotExist',...
			sprintf('settings key autoConfig not found in settings_root/%s/%s/public/',...
            QS.user, QS.session)));
    end
    if ~isfield(autoConfig,'readoutResonators')
        throw(MException('QOS_autoMeasurement_readoutResonator:atuoConfigNotExist',...
			sprintf('settings key readoutResonators not found in settings_root/%s/%s/public/autoConfig/',...
            QS.root, QS.user, QS.session)));
    end
    autoConfig_r = autoConfig.readoutResonators;
    if ~isfield(autoConfig_r,'freqRange')
        throw(MException('QOS_autoMeasurement_readoutResonator:keyNotExist',...
			sprintf('settings key freqRange not found in settings_root/%s/%s/public/autoConfig/readoutResonator',...
            QS.root, QS.user, QS.session)));
    end
    if ~isfield(autoConfig_r,'numDips')
        throw(MException('QOS_autoMeasurement_readoutResonator:keyNotExist',...
			sprintf('settings key numDips not found in settings_root/%s/%s/public/autoConfig/readoutResonator',...
            QS.root, QS.user, QS.session)));
    end
    if ~isfield(autoConfig_r,'freqRange')
        autoConfig_r.freqStep = 0.15e6;
    end
    if ~isfield(autoConfig_r,'rAmp')
        autoConfig_r.rAmp = (1-da.dynamicReserve)*da.vpp/2;
    end
    if ~isfield(autoConfig_r,'minDipSep')
        autoConfig_r.minDipSep = 10e6;
    end
    
    amp = autoConfig_r.rAmp;
    freq = autoConfig_r.freqRange{1}:autoConfig_r.freqStep:autoConfig_r.freqRange{2};
    e = s21_rAmp('qubit',qubits{1},'freq',freq,'amp',amp,...
        'gui',true,'save',true);
    
    s21 = abs(cell2mat(e.data{1}));
    
    s21inDb = -20*log10(s21./smooth(s21,51));
    
   [pks,locs,w,p] = findpeaks(s21inDb,freq,'SortStr','none','NPeaks',autoConfig_r.numDips,...
        'MinPeakDistance',ceil(autoConfig_r.minDipSep/autoConfig_r.freqStep),...
        'MinPeakHeight',max(s21inDb)/10,...
        'WidthReference','halfheight'); % 'WidthReference': 'halfheight'/'halfprom';
    
    [locs, ind] = sort(locs);
    pks = pks(ind);
    w = w(ind);
     
    h = qes.ui.qosFigure('Readout Resonator Dips',true);
    ax = axes('parent',h);
    plot(ax,freq,-s21inDb,'-b');
    hold(ax,'on');
    plot(ax,locs,-pks,'^r');
    xlabel(ax,'frequency(Hz)');
    ylabel(ax,'s21(dB)');
    drawnow;
    
    dipFreqs = locs;
    pkWithd = w;
end
