function varargout = iqChnl(varargin)
    % run this function to calibrate iq channels
    % 
    % iqChnl('awgName',_c_,'chnlSet',_c_,'maxSbFreq',_f_,'sbFreqStep',_f_...
	%		'loFreqStart',_f_,'loFreqStop',_f_,'loFreqStep',_f_,'spcAvgNum',<_i_>,...
    %       'notes',<_c_>,'gui',<_b_>,'save',<_b_>);
	% awgName: name of the awg to calibrate
	% chnlSet: channel set to calibrate, it is a settings group in:
	% settingsRoot\calibration\awgName\
	% sideband frequency: -maxSbFreq:sbFreqStep:maxSbFreq
	% lo frequency: loFreqStart:loFreqStep:loFreqStop

% Yulin Wu, 2017

    fcn_name = 'data_taking.public.calibration.iqChnl'; % this and args will be saved with data
    args = qes.util.processArgs(varargin,{'notes','','spcAvgNum',1,'gui',false,'save',true});
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_calibration_iqChnl:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    s = qes.util.loadSettings(QS.root,{'calibration',args.awgName,'iq',args.chnlSet});

    awgObj = qes.qHandle.FindByClassProp('qes.hwdriver.sync.awg','name',args.awgName);
    awgchnls = s.chnls;
    spcAnalyzer = qes.qHandle.FindByClassProp('qes.hwdriver.sync.spectrumAnalyzer','name',s.spc_analyzer);
    spcAmpObj = qes.measurement.specAmp(spcAnalyzer);
    spcAmpObj.avgnum = args.spcAvgNum;
    
    mwSrc = qes.qHandle.FindByClassProp('qes.hwdriver.sync.mwSource','name',s.lo_source);
    loSource = mwSrc.GetChnl(s.lo_chnl);
    Calibrator = qes.measurement.iqMixerCalibrator(awgObj,awgchnls,spcAmpObj,loSource);
    Calibrator.lo_power = s.lo_power;
    Calibrator.pulse_ln = s.pulse_ln;
    if args.gui
        Calibrator.showProcess = true;
    end
    
    x = qes.expParam(Calibrator,'lo_freq');
    y = qes.expParam(Calibrator,'sb_freq');
    y_s = qes.expParam(Calibrator,'pulse_ln');
    loFreq=args.loFreqStart:args.loFreqStep:args.loFreqStop;
    sbFreq=-args.maxSbFreq:args.sbFreqStep:args.maxSbFreq;

    sbFreq(abs(sbFreq)<3.5e4)=[];
    s1 = qes.sweep(x);

    s1.vals = loFreq;
    s2 = qes.sweep({y_s,y});
    ln = awgObj.samplingRate./abs(sbFreq);
    ln = ceil(ln);
%     for ii = 1:ln
%         d = ceil(ln(ii)) - ln(ii);
%         if d ~= 0
%             N = 1/d;
%             ln(ii) = ln(ii)*N;
%         end
%     end
    ln(ln>30e3) = 30e3;
    s2.vals = {ln,sbFreq};
    e = qes.experiment();
    e.sweeps = [s1,s2];

    e.measurements = Calibrator;
    e.datafileprefix = 'iqChnlCal';
    e.savedata = true;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.plotfcn = [];
    e.Run();
    data = cell2mat(e.data{1});
    iZeros = [data.iZeros];
    qZeros = [data.qZeros];
    sbCompensation = [data.sbCompensation];
    iZeros=iZeros(1:numel(loFreq));
    qZeros=qZeros(1:numel(loFreq));
    sbCompensation = reshape(sbCompensation,[numel(loFreq),numel(sbFreq)]); % Row is loFreq, Column is sbFreq
    iqAmp = data(1).iqAmp;
    loPower = data(1).loPower;
    
    if args.save
        dataFileDir = fullfile(QS.root,'calibration',args.awgName,'iq',args.chnlSet,'_data');
        if isempty(dir(dataFileDir))
            mkdir(dataFileDir);
        end
        filename=fullfile(dataFileDir,datestr(now,'yymmDDTHHMMSS'));
        notes = args.notes;
        save(filename,...
            'iZeros','qZeros','sbCompensation','iqAmp','loPower','loFreq','sbFreq','notes');
        figure;plot(loFreq,iZeros,'-o',loFreq,qZeros,'-o','linewidth',2);
        legend('iZeros','qZeros');
        xlabel('LoFreq');
        ylabel('Amp');
        saveas(gcf,[filename '_Zeros.fig']);
        figure;
        subplot(2,1,1);
        surface(sbFreq,loFreq,real(sbCompensation),'edgecolor','none');
        ylabel('LoFreq');xlabel('SbFreq');title('Real');colorbar;
        subplot(2,1,2);
        surface(sbFreq,loFreq,imag(sbCompensation),'edgecolor','none');
        ylabel('LoFreq');xlabel('SbFreq');title('Image');colorbar;
        saveas(gcf,[filename '_Sb.fig']);
    end
    varargout{1} = e.data{1};
end